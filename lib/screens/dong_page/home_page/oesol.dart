import 'package:flutter/material.dart';

class oesol extends StatefulWidget {
  const oesol({Key? key}) : super(key: key);

  @override
  State<oesol> createState() => _oesolState();
}

class _oesolState extends State<oesol> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭의 개수
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(44, 106, 245, 1.0),
          title: Text(
            "외솔",
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: '동아리 정보'),
              Tab(text: '게시판'),
              Tab(text: '달력'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Text('첫 번째 탭'),
            ),
            Center(
              child: Text('두 번째 탭'),
            ),
            Center(
              child: Text('세 번째 탭'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: oesol(),
    );
  }
}
