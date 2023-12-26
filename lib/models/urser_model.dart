// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final int feedCount;
  final int matdongsan;
  final List<String> followers;
  final List<String> following;
  final List<String> likes;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.feedCount,
    required this.matdongsan,
    required this.followers,
    required this.following,
    required this.likes,
  });

  factory UserModel.init() {
    return UserModel(
      uid: '',
      name: '',
      email: '',
      profileImage: null,
      feedCount: 0,
      matdongsan: 0,
      followers: [],
      following: [],
      likes: [],
    );
  }

//usermodle 이 가지고 있는 filed 변수로 가지고 있는 데이터들을 가지고 map 형태 데이터를 만들어 준다.
  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'name': this.name,
      'email': this.email,
      'profileImage': this.profileImage,
      'feedCount': this.feedCount,
      'matdongsan': this.matdongsan,
      'followers': this.followers,
      'following': this.following,
      'likes': this.likes,
    };
  }

//map 형태 데이터를 인자값을 전달 받아 usermolde 객체를 만들어 준다.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
      feedCount: map['feedCount'],
      matdongsan: map['matdongsan'],
      followers: List<String>.from(map['followers']),
      following: List<String>.from(map['following']),
      likes: List<String>.from(map['likes']),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImage,
    int? feedCount,
    int? matdongsan,
    List<String>? followers,
    List<String>? following,
    List<String>? likes,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      feedCount: feedCount ?? this.feedCount,
      matdongsan: matdongsan ?? this.matdongsan,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      likes: likes ?? this.likes,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, profileImage: $profileImage, feedCount: $feedCount, followers: $followers, following: $following, likes: $likes, matdongsan: $matdongsan)';
  }
}
