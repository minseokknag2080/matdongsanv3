import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/providers/profile/profile_state.dart';
import 'package:sns_clonecode/widgets/feed_card_widget.dart';

class ProfileFeedScreen extends StatefulWidget {
  final int index;
  const ProfileFeedScreen({super.key, required this.index});

  @override
  State<ProfileFeedScreen> createState() => ProfileFeedScreenState();
}

class ProfileFeedScreenState extends State<ProfileFeedScreen> {
  @override
  Widget build(BuildContext context) {
    List<FeedModel> feedList = context.watch<ProfileState>().feedList;

    return Scaffold(
      body: SafeArea(
          child: FeedCardWidget(
        feedModel: feedList[widget.index],
        isProfile: true,
      )),
    );
  }
}
