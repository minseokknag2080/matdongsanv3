import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/urser_model.dart';

class ProfileRepository {
  final FirebaseFirestore firebaseFirestore;

  const ProfileRepository({
    required this.firebaseFirestore,
  });

  //접속중인 유저의 정보를 얻는 함수도 선언하겠다 .

//   Future<UserModel> getProfile({
// //데이터를 가져오려고 하는 유저 아이디를 전달 받겠다.
//     required String uid,
//   }) async {
//     // //파이어스토어에 접근하여 uid와 동일한 return을 가져오면 되는 것이다.
//     // DocumentSnapshot<Map<String, dynamic>> snapshot =
//     //     await firebaseFirestore.collection('users').doc(uid).get();

//     // //유저모델 객체 반환
//     // return UserModel.fromMap(snapshot.data()!);

//     DocumentSnapshot<Map<String, dynamic>> snapshot =
//         await firebaseFirestore.collection('users').doc(uid).get();
//     return UserModel.fromMap(snapshot.data()!);
//   }

  Future<UserModel> followUser({
    required String currentUserId,
    required String followId,
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> currentUserDocRef =
          firebaseFirestore.collection('users').doc(currentUserId);
      DocumentReference<Map<String, dynamic>> followUserDocRef =
          firebaseFirestore.collection('users').doc(followId);

      // DocumentSnapshot<Map<String, dynamic>> currentUserSnapshot = await currentUserDocRef.get();
      // List<String> following = List<String>.from(currentUserSnapshot.data()!['following']);

      List<String> following = await currentUserDocRef
          .get()
          .then((value) => List<String>.from(value.data()!['following']));

      WriteBatch batch = firebaseFirestore.batch();

      if (following.contains(followId)) {
        batch.update(currentUserDocRef, {
          'following': FieldValue.arrayRemove([followId])
        });
        batch.update(followUserDocRef, {
          'followers': FieldValue.arrayRemove([currentUserId])
        });
      } else {
        batch.update(currentUserDocRef, {
          'following': FieldValue.arrayUnion([followId])
        });
        batch.update(followUserDocRef, {
          'followers': FieldValue.arrayUnion([currentUserId])
        });
      }

      batch.commit();

      Map<String, dynamic> map =
          await followUserDocRef.get().then((value) => value.data()!);
      return UserModel.fromMap(map);
    } catch (e) {
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }
  }

  Future<UserModel> getProfile({
    required String uid,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firebaseFirestore.collection('users').doc(uid).get();
      return UserModel.fromMap(snapshot.data()!);
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
}
