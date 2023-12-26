import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/providers/user/user_state.dart';
import 'package:sns_clonecode/repositories/profile_repository.dart';

class UserProvider extends StateNotifier<UserState> with LocatorMixin {
  UserProvider() : super(UserState.init());

//유저의 데이터를 파이어 스토어에서 가져오는 함수
  Future<void> getUserInfo() async {
    try {
      String uid = read<User>().uid;
      UserModel userModel =
          await read<ProfileRepository>().getProfile(uid: uid);
      state = state.copyWith(userModel: userModel);
    } on CustomException catch (_) {
      rethrow;
    }
  }
}
