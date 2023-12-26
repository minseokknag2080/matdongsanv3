import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:sns_clonecode/models/urser_model.dart';
import 'package:sns_clonecode/screens/profile_screen.dart';

class AvatarWidget extends StatelessWidget {
  final UserModel userModel;

  const AvatarWidget({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    //////////////////////////////////////////////////////////////////////////////
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                uid: userModel.uid,
              ),
            ));
      },
      child: CircleAvatar(
        backgroundImage: userModel.profileImage == null
            ? ExtendedAssetImageProvider('assets/images/profile.png')
                as ImageProvider
            : ExtendedNetworkImageProvider(userModel.profileImage!),
        radius: 18,
      ),
    );
  }
}
