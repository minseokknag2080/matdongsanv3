import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sns_clonecode/exceptions/custom_exception.dart';
import 'package:sns_clonecode/providers/auth/auth_provider.dart';
import 'package:sns_clonecode/providers/user/user_provider.dart';
import 'package:sns_clonecode/screens/feed_screen.dart';
import 'package:sns_clonecode/screens/feed_upload_screen.dart';
import 'package:sns_clonecode/screens/home_screen.dart';
import 'package:sns_clonecode/screens/like_screen.dart';
import 'package:sns_clonecode/screens/profile_screen.dart';
import 'package:sns_clonecode/utils/logger.dart';
import 'package:sns_clonecode/widgets/error_dialog_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
//SingleTickerProviderStateMixin   애니매이션을 부드럽게 처리하는 요소

//children에 들어가는 화면의 갯수 / vsync 화면 전환 애니매이션을 부드럽게 처리하는 요소
//filed 변수 선언 시점에는 class의 객체가 생성되기 이전이기 때문에 this 사용 불가
  late TabController tabController;

  @override
  void initState() {
    //생성자 (class의 객체를 생성할 때 호출되는 함수 )

    super.initState();

    tabController = TabController(length: 5, vsync: this);
    //객체를 전달한다.
    _getProfile();
  }

  void bottomNavigationItemOnTab(int index) {
    setState(() {
      tabController.index = index;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _getProfile() async {
    try {
      await context.read<UserProvider>().getUserInfo();
    } on CustomException catch (e) {
      errorDialogWidget(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: TabBarView(
            controller: tabController,

            //스크롤 금지
            physics: NeverScrollableScrollPhysics(),
            children: [
              home_screen(),
              FeedScreen(),
              FeedUploadScreen(
                onFeedUploaded: () {
                  setState(() {
                    tabController.index = 0;
                  });
                },
              ),
              LikeScreen(),
              ProfileScreen(
                uid: context.read<User>().uid,
              ),
            ]),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromRGBO(44, 106, 245, 1.0),
          //shifting - 애니메이션
          //fixed 애니메이션 삭제 색만 들어간다.
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          //선택된 레이블 숨긴다.
          showUnselectedLabels: false,
          //아이템이 클릭되면 그 아이템의 index를 전달해주면, pointing 된다.

          // onTap: (value) {
          //   //value에는 선택된 아이템의 index값 전달된다.

          //   //선택된 아이템의 index 출력
          //   //logger.d(value);

          //   // //filed 변수로 tabcontroller 생성
          //   // tabController.index = value;
          // },
          onTap: bottomNavigationItemOnTab,
          currentIndex: tabController.index,

          //선택되지 않은 레이블 숨긴다.
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feed),
              label: 'feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'upload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'profile',
            ),
          ],
          selectedItemColor: Color(0xFFFFCD47),
        ),
      ),
    );
  }
}
