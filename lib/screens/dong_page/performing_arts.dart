import 'package:flutter/material.dart';
import 'package:sns_clonecode/screens/dong_page/home_page/OMG.dart';
import 'package:sns_clonecode/screens/dong_page/home_page/asd.dart';
import 'package:sns_clonecode/screens/dong_page/home_page/oesol.dart';

class performing_arts extends StatefulWidget {
  const performing_arts({super.key});

  @override
  State<performing_arts> createState() => _performing_artsState();
}

class _performing_artsState extends State<performing_arts> {
  // List<bool> switchValues = List.generate(20, (index) => false);
  List<String> switchValues = [
    '비상',
    '외솔',
    'OMG',
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
                        switch (index) {
                          case 0:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Asd()),
                            );
                            break;
                          case 1:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => oesol()),
                            );
                            break;
                          case 2:
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => OMG()),
                            );
                            break;
                          default:
                            break;
                        }
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
