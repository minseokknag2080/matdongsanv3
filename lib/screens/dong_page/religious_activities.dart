import 'package:flutter/material.dart';
import 'package:sns_clonecode/screens/dong_page/home_page/asd.dart';

class religious_activities extends StatefulWidget {
  const religious_activities({super.key});

  @override
  State<religious_activities> createState() => _religious_activitiesState();
}

class _religious_activitiesState extends State<religious_activities> {
  // List<bool> switchValues = List.generate(20, (index) => false);
  List<String> switchValues = [
    '새노래로찬양단',
    '태멘',
    'CCC',
    'DFC',
    'IVF',
    'JDM',
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.height * 1 / 9;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(44, 106, 245, 1.0),
        title: Text(
          '종교활동',
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
