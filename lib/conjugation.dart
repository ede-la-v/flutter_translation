import 'package:flutter/material.dart';
import 'package:flutter_tensoring/database.dart';

List type = ["Je", "Tu", "Il, elle, on", "Nous", "vous", "Ils, elles"];

class Conjugation extends StatefulWidget {
  final french;
  final spanish;

  const Conjugation({Key key, @required this.french, @required this.spanish})
      : assert(french != null),
        assert(spanish != null),
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
        margin:
            EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0, top: 60.0),
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
                    widget.french,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey[700]),
                  ),
                )),
                Container(
                  child: CloseButton(),
                ),
              ],
            ),
            Expanded(
              child: Times(widget.spanish),
            )
          ],
        ),
      ),
    );
  }
}

class Times extends StatefulWidget {
  final name;

  Times(this.name);

  @override
  TimesState createState() => new TimesState();
}

class TimesState extends State<Times> {
  int time = 1;
  Map conjugation = {"present": [], "future": []};
  TranslationDatabase db;

  @override
  void initState() {
    super.initState();
    db = TranslationDatabase();
    getConjugation();
  }

  void getConjugation() async {
    conjugation = await db.getConjugation(widget.name);
    print("conjugation");
    print(conjugation);
    setState(() {});
  }

  List<dynamic> findConjugation(int place) {
    print(place);
    print(time);
    switch (time) {
      case 1:
        {
          return [
            place,
            conjugation["present"].length > 0 &&
                    place < conjugation["present"].length
                ? conjugation["present"][place]
                : ""
          ];
        }
        break;
      case 2:
        {
          return [
            place,
            conjugation["future"].length > 0 &&
                    place < conjugation["future"].length
                ? conjugation["future"][place]
                : ""
          ];
        }
        break;
      default:
        {
          return [place, ""];
        }
    }
  }

  void changeConjugation(int place, String newConj) {
    print(place);
    print(newConj);
    switch (time) {
      case 1:
        {
          conjugation["present"][place] = newConj.toLowerCase();
          db.changeTranslation(newConj.toLowerCase(),
              "present" + (place + 1).toString(), widget.name);
        }
        break;
      case 2:
        {
          conjugation["future"][place] = newConj.toLowerCase();
          db.changeTranslation(newConj.toLowerCase(),
              "future" + (place + 1).toString(), widget.name);
        }
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      style: ListTileStyle.drawer,
      child: Column(
        children: <Widget>[
          Container(
            height: 30.0,
            child: RadioListTile(
                title: Text("Present"),
                value: 1,
                groupValue: time,
                onChanged: (value) {
                  setState(() {
                    time = value;
                  });
                }),
          ),
          Container(
            height: 30.0,
            child: RadioListTile(
                title: Text("Future"),
                value: 2,
                groupValue: time,
                onChanged: (value) {
                  setState(() {
                    time = value;
                  });
                }),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 6,
              itemBuilder: (BuildContext context, int index) {
                return Time(
                  changeConjugation: changeConjugation,
                  conjugation: findConjugation(index),
                );
              },
            ),
          ))
        ],
      ),
    );
  }
}

class Time extends StatefulWidget {
  final conjugation;
  final changeConjugation;

  const Time(
      {Key key, @required this.conjugation, @required this.changeConjugation})
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
    if (widget.conjugation != null && widget.conjugation[1] != null) {
      controller.text = widget.conjugation[1];
    } else {
      controller.text = "";
    }

    super.initState();
  }

  @override
  void didUpdateWidget(Time oldWidget) {
    print(widget.conjugation);
    if (widget.conjugation != null && widget.conjugation[1] != null) {
      controller.text = widget.conjugation[1];
    } else {
      controller.text = "";
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
            child: Text(type[widget.conjugation[0]]),
          ),
          Expanded(
              child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0), color: Colors.white),
            padding: EdgeInsets.all(5.0),
            child: TextField(
                onChanged: (string) {
                  print("change");
                  widget.changeConjugation(widget.conjugation[0], string);
                },
                controller: controller,
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
                decoration: const InputDecoration.collapsed(hintText: null)),
          ))
        ],
      ),
    );
  }
}
