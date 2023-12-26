import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/providers/profile/profile_state.dart';
import 'package:sns_clonecode/repositories/feed_repository.dart';
import 'package:sns_clonecode/repositories/profile_repository.dart';

class ProfileProvider extends StateNotifier<ProfileState> with LocatorMixin {
  ProfileProvider() : super(ProfileState.init());
  //profilestate 도 동시에 객체 생성

  void deleteFeed({
    required String feedId,
  }) {
    state = state.copyWith(profileStatus: ProfileStatus.submitting);

    try {
      List<FeedModel> newFeedList =
          state.feedList.where((element) => element.feedId != feedId).toList();

      UserModel userModel = state.userModel;
      UserModel newUserModel = userModel.copyWith(
        feedCount: userModel.feedCount - 1,
      );

      state = state.copyWith(
        profileStatus: ProfileStatus.success,
        feedList: newFeedList,
        userModel: newUserModel,
      );
    } on CustomException catch (_) {
      state = state.copyWith(profileStatus: ProfileStatus.error);
      rethrow;
    }
  }

  void likeFeed({
    required FeedModel newFeedModel,
  }) {
    state = state.copyWith(profileStatus: ProfileStatus.submitting);

    try {
      List<FeedModel> newFeedList = state.feedList.map((feed) {
        return feed.feedId == newFeedModel.feedId ? newFeedModel : feed;
      }).toList();

      state = state.copyWith(
        profileStatus: ProfileStatus.success,
        feedList: newFeedList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(profileStatus: ProfileStatus.error);
      rethrow;
    }
  }

  Future<void> followUser({
    required String currentUserId,
    required String followId,
  }) async {
    state = state.copyWith(profileStatus: ProfileStatus.submitting);

    try {
      UserModel userModel = await read<ProfileRepository>()
          .followUser(currentUserId: currentUserId, followId: followId);

      state = state.copyWith(
        profileStatus: ProfileStatus.success,
        userModel: userModel,
      );
    } on CustomException catch (_) {
      state = state.copyWith(profileStatus: ProfileStatus.error);
      rethrow;
    }
  }

  Future<void> getProfile({
    required String uid,
  }) async {
    state = state.copyWith(profileStatus: ProfileStatus.fetching);

    try {
      UserModel userModel =
          await read<ProfileRepository>().getProfile(uid: uid);
      List<FeedModel> feedList =
          await read<FeedRepository>().getFeedList(uid: uid);

      state = state.copyWith(
        profileStatus: ProfileStatus.success,
        feedList: feedList,
        userModel: userModel,
      );
    } on CustomException catch (_) {
      state = state.copyWith(profileStatus: ProfileStatus.error);
    }
  }
}
