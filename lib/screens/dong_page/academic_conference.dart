import 'package:flutter/material.dart';
import 'package:sns_clonecode/screens/dong_page/home_page/asd.dart';

class academic_conference extends StatefulWidget {
  const academic_conference({super.key});

  @override
  State<academic_conference> createState() => _academic_conferenceState();
}

class _academic_conferenceState extends State<academic_conference> {
  // List<bool> switchValues = List.generate(20, (index) => false);
  List<String> switchValues = [
    '소리마을',
    '열광',
    'ASC',
    'KALPA',
    '무형서재',
    'WION',
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height * 1 / 9;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(44, 106, 245, 1.0),
        title: Text(
          '학술연구',
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
                        Navigator.push(
                            context, MaterialPageRoute(builder: (_) => Asd()));
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
