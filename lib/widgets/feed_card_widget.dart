import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/models/feed_model.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/providers/feed/fedd_state.dart';
import 'package:sns_clonecode/providers/feed/feed_provider.dart';
import 'package:sns_clonecode/providers/like/like_provider.dart';
import 'package:sns_clonecode/providers/profile/profile_provider.dart';
import 'package:sns_clonecode/providers/user/user_provider.dart';
import 'package:sns_clonecode/providers/user/user_state.dart';
import 'package:sns_clonecode/screens/comment_scrren.dart';
import 'package:sns_clonecode/utils/logger.dart';
import 'package:sns_clonecode/widgets/avatar_widget.dart';
import 'package:sns_clonecode/widgets/error_dialog_widget.dart';
import 'package:sns_clonecode/widgets/heart_animation_widget.dart';

class FeedCardWidget extends StatefulWidget {
  final FeedModel feedModel;
  final bool isProfile;

  const FeedCardWidget(
      {super.key, required this.feedModel, this.isProfile = false});

  @override
  State<FeedCardWidget> createState() => _FeedCardWidgetState();
}

class _FeedCardWidgetState extends State<FeedCardWidget> {
  final CarouselController carouselController = CarouselController();
  int _indicatorIndex = 0;
  bool isAnimating = false;

  Widget _imageZoomInOutWidget(String imageUrls) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) {
            return InteractiveViewer(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: ExtendedImage.network(imageUrls),
              ),
            );
          },
        );
      },
      child: ExtendedImage.network(
        imageUrls,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _imageSliderWidget(List<String> imageUrls) {
    return GestureDetector(
      onDoubleTap: () async {
        await _likeFeed();
      },
      child: Stack(alignment: Alignment.center, children: [
        CarouselSlider(
          carouselController: carouselController,
          items: imageUrls.map((url) => _imageZoomInOutWidget(url)).toList(),
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              //현재 표시되고 있는 사진의 index값
              setState(() {
                _indicatorIndex = index;
              });
            },
            viewportFraction: 1.0,
            height: MediaQuery.of(context).size.height * 0.35,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              //tolist함수 반환 자체가 리스트가 반환 된 것이므로.
              children: imageUrls.asMap().keys.map((e) {
                return Container(
                  width: 8,
                  height: 8,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withOpacity(_indicatorIndex == e ? 0.9 : 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Opacity(
            opacity: isAnimating ? 1 : 0,
            child: HeartAnimationWidget(
              isAnimating: isAnimating,
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 100,
              ),
              onEnd: () => setState(() {
                isAnimating = false;
              }),
            )),
      ]),
    );
  }

  Future<void> _likeFeed() async {
    if (context.read<FeedState>().feedStatus == FeedStatus.submitting) {
      return;
    }
    try {
      isAnimating = true;
      FeedModel newFeedModel = await context.read<FeedProvider>().likeFeed(
            feedId: widget.feedModel.feedId,
            feedLikes: widget.feedModel.likes,
          );

      if (widget.isProfile) {
        context.read<ProfileProvider>().likeFeed(newFeedModel: newFeedModel);
      }

      context.read<LikeProvider>().likeFeed(newFeedModel: newFeedModel);

      await context.read<UserProvider>().getUserInfo();
    } on CustomException catch (e) {
      errorDialogWidget(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = context.read<UserState>().userModel.uid;

    FeedModel feedModel = widget.feedModel;
    UserModel userModel = feedModel.writer;
    bool isLike = feedModel.likes.contains(currentUserId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 1, // Adjust the height of the line as needed
              color: Colors.grey, // Adjust the color of the line as needed
              margin: EdgeInsets.symmetric(horizontal: 5),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                AvatarWidget(userModel: userModel),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    userModel.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (currentUserId == feedModel.uid)
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: TextButton(
                                child: Text(
                                  '삭제',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  //삭제로직
                                  try {
                                    await context
                                        .read<FeedProvider>()
                                        .deleteFeed(feedModel: feedModel);

                                    context
                                        .read<LikeProvider>()
                                        .deleteFeed(feedId: feedModel.feedId);

                                    if (widget.isProfile) {
                                      context
                                          .read<ProfileProvider>()
                                          .deleteFeed(feedId: feedModel.feedId);
                                      Navigator.pop(context);
                                    }

                                    Navigator.pop(context);
                                  } on CustomException catch (e) {
                                    errorDialogWidget(context, e);
                                  }
                                },
                              ),
                            );
                          });
                    },
                    icon: Icon(Icons.more_vert),
                  )
              ],
            ),
          ]),
        ),
        _imageSliderWidget(feedModel.imageUrls),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () async {
                    await _likeFeed();
                  },
                  child: HeartAnimationWidget(
                      child: isLike
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                            ),
                      isAnimating: isAnimating)),
              SizedBox(
                width: 5,
              ),
              Text(
                feedModel.likeCount.toString(),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CommentScreen(feedId: feedModel.feedId)));
                },
                child: Icon(
                  Icons.comment_outlined,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                feedModel.commentCount.toString(),
                style: TextStyle(fontSize: 16),
              ),

              //차지할 수 있는 가장 많은 공간 차지
              Spacer(),

              //분리가 될 기준을 정해주고 분리 후 list<string>이 반환되기 때문에 0번째 index만 가져와서 사용
              Text(
                feedModel.createAt.toDate().toString().split(' ')[0],
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            feedModel.desc,
            style: TextStyle(fontSize: 16),
          ),
        )
      ]),
    );
    ;
  }
}
