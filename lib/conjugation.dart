import 'package:flutter/material.dart';

class Conjugation extends StatefulWidget {

  @override
  ConjugationState createState() => new ConjugationState();
}

class ConjugationState extends State<Conjugation> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.5),
      body: Container(
        margin: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            bottom: 15.0,
            top: 60.0
        ),
        color: Colors.blueGrey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 45.0,
                  height: 45.0,
                ),
                Expanded(
                    child: Center(
                      child: Text(
                        "Conjugaison",
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[700]
                        ),
                      ),
                    )
                ),
                Container(
                  child: CloseButton(),
                ),
              ],
            ),
            Times()
          ],
        ),
      ),
    );
  }
}

class Times extends StatefulWidget {
  @override
  TimesState createState() => new TimesState();
}

class TimesState extends State<Times> {
  int time = 1;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(
            title: Text("Present"),
            value: 1,
            groupValue: time,
            onChanged: (value) {
              setState(() {
                time = value;
              });
            }
        ),
        RadioListTile(
            title: Text("Future"),
            value: 2,
            groupValue: time,
            onChanged: (value) {
              setState(() {
                time = value;
              });
            }
        ),
      ],
    );
  }
}