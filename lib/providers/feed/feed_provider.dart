import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/providers/feed/fedd_state.dart';
import 'package:sns_clonecode/providers/user/user_state.dart';
import 'package:sns_clonecode/repositories/feed_repository.dart';

class FeedProvider extends StateNotifier<FeedState> with LocatorMixin {
  FeedProvider() : super(FeedState.init());

  Future<void> deleteFeed({
    required FeedModel feedModel,
  }) async {
    state = state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      await read<FeedRepository>().deleteFeed(feedModel: feedModel);

      List<FeedModel> newFeedList = state.feedList
          .where((element) => element.feedId != feedModel.feedId)
          .toList();

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: newFeedList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);
      rethrow;
    }
  }

  Future<FeedModel> likeFeed({
    required String feedId,
    required List<String> feedLikes,
  }) async {
    state = state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      UserModel userModel = read<UserState>().userModel;

      FeedModel feedModel = await read<FeedRepository>().likeFeed(
        feedId: feedId,
        feedLikes: feedLikes,
        uid: userModel.uid,
        userLikes: userModel.likes,
      );

      List<FeedModel> newFeedList = state.feedList.map((feed) {
        return feed.feedId == feedId ? feedModel : feed;
      }).toList();

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: newFeedList,
      );

      return feedModel;
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);
      rethrow;
    }
  }

  Future<void> getFeedList() async {
    try {
      state = state.copyWith(feedStatus: FeedStatus.fetching);

      List<FeedModel> feedList = await read<FeedRepository>().getFeedList();

      state =
          state.copyWith(feedList: feedList, feedStatus: FeedStatus.success);
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);

      rethrow;
    }
  }

  Future<void> uploadFeedd({
    required List<String> files,
    required String desc,
  }) async {
    try {
      state = state.copyWith(feedStatus: FeedStatus.submitting);

      String uid = read<User>().uid;
      FeedModel feedModel = await read<FeedRepository>().uploadFeed(
        files: files,
        desc: desc,
        uid: uid,
      );

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: [feedModel, ...state.feedList],
      );
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);

      rethrow;
    }
  }
}
