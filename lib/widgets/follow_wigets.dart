import 'package:flutter/material.dart';

class follow_list extends StatefulWidget {
  const follow_list({super.key});

  @override
  State<follow_list> createState() => _follow_listState();
}

class _follow_listState extends State<follow_list> {
  // List<bool> switchValues = List.generate(20, (index) => false);
  List<String> switchValues = [
    '아스키',
    '유스호스텔',
    '청춘공방',
    '스날',
    '한아울',
    '칼파',
    '매치포인트'
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height * 1 / 9;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(44, 106, 245, 1.0),
        title: Text(
          '공연예술',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white), //전체아이콘색깔
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: List.generate(switchValues.length, (index) {
                    return InkWell(
                      onTap: () {
                        // Perform actions when a club is clicked
                        print('$index 동아리 클릭됨');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              'assets/images/app_logo.png', // Image path here
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            switchValues[index], // Use club name from the list
                            style: TextStyle(fontSize: 30),
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            //
          ],
        ),
      ),

      //
    );
  }
}
