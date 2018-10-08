import 'package:flutter/material.dart';

class Conjugation extends StatefulWidget {
  final name;

  const Conjugation({
    Key key,
    @required this.name
  })
      : assert(name != null),
        super(key: key);

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
                        widget.name,
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
  Map conjugation = {
    "Present" : {"Je":"truce", "Il, elle, on": "otro"},
    "Future" : {"Nous":"truc", "Vous": "chose"}
  };

  List<String> findConjugation(String place) {
    switch (time) {
      case 1: {
        return [place, conjugation["Present"][place] != null ? conjugation["Present"][place] : ""];
      }
      break;
      case 2: {
        return [place, conjugation["Future"][place] != null ? conjugation["Future"][place] : ""];
      }
      break;
      default: {
        return [place, ""];
      }
    }

  }

  void changeConjugation(String place, String newConj) {
    print(place);
    print(newConj);
    switch(time) {
      case 1: {
        conjugation["Present"][place] = newConj.toLowerCase();
      }
      break;
      case 2: {
        conjugation["Future"][place] = newConj.toLowerCase();
      }
      break;
    }
    setState(() {});
  }
  
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
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Time(
                    conjugation: findConjugation("Je"),
                    changeConjugation: changeConjugation,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Time(
                        conjugation: findConjugation("Nous"),
                        changeConjugation: changeConjugation,
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Time(
                      conjugation: findConjugation("Tu"),
                      changeConjugation: changeConjugation,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Time(
                        conjugation: findConjugation("Vous"),
                        changeConjugation: changeConjugation,
                    ),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Time(
                      conjugation: findConjugation("Il, elle, on"),
                      changeConjugation: changeConjugation,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Time(
                        conjugation: findConjugation("Ils, elles"),
                        changeConjugation: changeConjugation,
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class Time extends StatefulWidget {
  final conjugation;
  final changeConjugation;

  const Time({
    Key key,
    @required this.conjugation,
    @required this.changeConjugation
  })
      : assert(conjugation != null),
        assert(changeConjugation != null),
        super(key: key);

  @override
  TimeState createState() => new TimeState();
}

class TimeState extends State<Time> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    if (widget.conjugation != null) {
      controller.text = widget.conjugation[1];
    }

    super.initState();
  }

  @override
  void didUpdateWidget(Time oldWidget) {
    if (widget.conjugation != null) {
      controller.text = widget.conjugation[1];
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      child: Row(
        children: <Widget>[
          Container(
            width: 50.0,
            child: Text(widget.conjugation[0]),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.white
            ),
            padding: EdgeInsets.all(5.0),
            width: 100.0,
            child: TextField(
                onChanged: (string) {
                  widget.changeConjugation(widget.conjugation[0], string);
                },
                controller: controller,
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
                decoration: const InputDecoration.collapsed(
                  hintText: null
                )
            ),
          )
        ],
      ),
    );
  }
}