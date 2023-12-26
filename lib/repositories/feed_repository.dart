import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/utils/logger.dart';
import 'package:uuid/uuid.dart';

class FeedRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const FeedRepository({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  Future<void> deleteFeed({
    required FeedModel feedModel,
  }) async {
    try {
      WriteBatch batch = firebaseFirestore.batch();
      DocumentReference<Map<String, dynamic>> feedDocRef =
          firebaseFirestore.collection('feeds').doc(feedModel.feedId);
      DocumentReference<Map<String, dynamic>> writerDocRef =
          firebaseFirestore.collection('users').doc(feedModel.uid);

      // 해당 게시물에 좋아요를 누른 users 문서의 likes 필드에서 feedId 삭제
      List<String> likes = await feedDocRef
          .get()
          .then((value) => List<String>.from(value.data()!['likes']));

      likes.forEach((uid) {
        batch.update(firebaseFirestore.collection('users').doc(uid), {
          'likes': FieldValue.arrayRemove([feedModel.feedId]),
        });
      });

      // 해당 게시물의 comments 컬렉션의 docs 를 삭제
      QuerySnapshot<Map<String, dynamic>> commentQuerySnapshot =
          await feedDocRef.collection('comments').get();
      for (var doc in commentQuerySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // feeds 컬렉션에서 문서 삭제
      batch.delete(feedDocRef);

      // 게시물 작성자의 users 문서에서 feedCount 1 감소
      batch.update(writerDocRef, {
        'feedCount': FieldValue.increment(-1),
      });

      // storage 의 이미지 삭제
      feedModel.imageUrls.forEach((element) async {
        await firebaseStorage.refFromURL(element).delete();
      });

      batch.commit();
    } on FirebaseException catch (e) {
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }

  Future<FeedModel> likeFeed({
    required String feedId,
    required List<String> feedLikes,
    required String uid,
    required List<String> userLikes,
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> userDocRef =
          firebaseFirestore.collection('users').doc(uid);
      DocumentReference<Map<String, dynamic>> feedDocRef =
          firebaseFirestore.collection('feeds').doc(feedId);
      // 게시물을 좋아하는 유저 목록에 uid 가 포함되어 있는지 확인
      // 포함되어 있다면 좋아요 취소
      // 게시물의 likes 필드에서 uid 삭제
      // 게시물의 likeCount 를 1 감소
      // 유저가 좋아하는 게시물 목록에 feedId 가 포함되어 있는지 확인
      // 포함되어 있다면 좋아요 취소
      // 유저의 likes 필드에서 feedId 삭제
      await firebaseFirestore.runTransaction((transaction) async {
        bool isFeedContains = feedLikes.contains(uid);

        transaction.update(feedDocRef, {
          'likes': isFeedContains
              ? FieldValue.arrayRemove([uid])
              : FieldValue.arrayUnion([uid]),
          'likeCount': isFeedContains
              ? FieldValue.increment(-1)
              : FieldValue.increment(1),
        });

        transaction.update(userDocRef, {
          'likes': userLikes.contains(feedId)
              ? FieldValue.arrayRemove([feedId])
              : FieldValue.arrayUnion([feedId]),
        });
      });

      Map<String, dynamic> feedMapData =
          await feedDocRef.get().then((value) => value.data()!);

      DocumentReference<Map<String, dynamic>> writerDocRef =
          feedMapData['writer'];
      Map<String, dynamic> userMapData =
          await writerDocRef.get().then((value) => value.data()!);
      UserModel userModel = UserModel.fromMap(userMapData);
      feedMapData['writer'] = userModel;
      return FeedModel.fromMap(feedMapData);
    } on FirebaseException catch (e) {
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }

  //
  Future<List<FeedModel>> getFeedList({
    String? uid,
    //유저 아이디 전달
  }) async {
    try {
      //firesotre feed collection에 접근해서 저장되어 있는 모든 문서들을 가져온다.

      //문서를 가져올 때 가장 최근에 만들어진 문서가 앞에 오게 정렬
      //저장한 시간 날짜를 가지고 있는 filed가 createAt이다.

      //firestore의 feeds collection에 저장된 정보들 feed_model에 저장할 것이다. //리스트로 만들어서 반환할 것이다.
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('feeds')
          .where('uid', isEqualTo: uid)
          //우리가 매개변수로 전달받은 uid와 같은 값
          .orderBy('createAt', descending: true)
          .get();

      //게시글을 map 형태로 반환
      return await Future.wait(snapshot.docs.map((e) async {
        Map<String, dynamic> data = e.data();
        DocumentReference<Map<String, dynamic>> writerDocRef = data['writer'];
        DocumentSnapshot<Map<String, dynamic>> writerSnapshot =
            await writerDocRef.get();
        UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
        data['writer'] = userModel;
        return FeedModel.fromMap(data);
      }).toList());
    } on FirebaseException catch (e) {
      //firebase 관련 예외

      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      //그 밖의 예외
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }

  Future<FeedModel> uploadFeed({
    required List<String> files,
    required String desc,
    required String uid,

//feeds 컬렉션에 저장
//피드 각각이 문서
//이미지는 storage에 직접 저장하고 firestore에 접근할 수 있는 url 문자열로 받을 것이다.
//좋아요 수
//이 게시글에 달린 댓글의 수
//게시글을 작성한 날짜
//feeds에서 user의 정보를 바로 가져올 수 있게 reference 타입의 데이터를 저장한다.
  }) async {
    List<String> imageUrls = [];

    try {
      WriteBatch batch = firebaseFirestore.batch();

//파이어스토어에 데이터 저장하기위해서
//문서 아이디는 겹치지 않는 고유한 값으로 만들어야 한다.

//a-z 알파벳
//0~9 숫자
//이 두가지를 조합해서 32글자의 고유한 값을 만들어 준다.
//32글자에 - 4개씩 들어가서 36글자가 된다.
//고유한 값을 만드는 방법 여러가지 version1 ....
//우리는 version1을 사용 (현재 시간을 기준으로 random값을 만들어 준다.)

      String feedId = Uuid().v1();

      //firestore 문서 참조
      DocumentReference<Map<String, dynamic>> feedDocRef =
          firebaseFirestore.collection('feeds').doc(feedId);

      DocumentReference<Map<String, dynamic>> userDocRef =
          firebaseFirestore.collection('users').doc(uid);

      //storage 참조
      Reference ref = firebaseStorage.ref().child('feeds').child(feedId);

      //fire storage에다가 데이터를 저장하는 작업
      imageUrls = await Future.wait(files.map((e) async {
        //문자열 e는 이미지 파일에 접근할 수 있는 경로
        String imageId = Uuid().v1();
        TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
        return await taskSnapshot.ref.getDownloadURL();
      }).toList());

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await userDocRef.get();

      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      FeedModel feedModel = FeedModel.fromMap({
        'uid': uid,
        'feedId': feedId,
        'desc': desc,
        'imageUrls': imageUrls,
        'likes': [],
        'likeCount': 0,
        'commentCount': 0,
        'createAt': Timestamp.now(),
        'writer': userModel,
      });

      //firestore에 feedcollection에 data를 저장하는 작업
      //await feedDocRef.set(feedModel.toMap(userDocRef: userDocRef));

      batch.set(feedDocRef, feedModel.toMap(userDocRef: userDocRef));

      //here2

      // await feedDocRef.set({
      //   'uid': uid,
      //   'feedId': feedId,
      //   'desc': desc,
      //   'imageUrls': imageUrls,
      //   'likes': [],
      //   'commentCount': 0,
      //   'likeCount': 0,
      //   'createAt': Timestamp.now(),
      //   'writer': userDocRef,
      // });

      //firestore의 유저 collection에 feedcount를 1 증가시키는 작업
      // await userDocRef.update({
      //   'feedCount': FieldValue.increment(1),
      // });

      batch.update(userDocRef, {
        'feedCount': FieldValue.increment(1),
      });

      //commit 해야지 일괄적으로 저장과 수정이 수행된다.
      batch.commit();
      return feedModel;
    } on FirebaseException catch (e) {
      _deleteImage(imageUrls);

      //firebase 관련 예외

      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      _deleteImage(imageUrls);
      //그 밖의 예외
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }

  void _deleteImage(List<String> imageUrls) {
    imageUrls.forEach((element) async {
      //저장한 이미지 오류가 발생했을 때 삭제

      await firebaseStorage.refFromURL(element).delete();
    });
  }
}
