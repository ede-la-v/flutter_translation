import 'package:flutter/material.dart';
import 'package:flutter_tensoring/services/database.dart';
import 'package:meta/meta.dart';

import 'package:flutter_tensoring/BlocProvider.dart';
import 'package:flutter_tensoring/widgets/recorderPlayer.dart';

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
      body: Card(
        margin:
            EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0, top: 60.0),
        color: Colors.grey,
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
                        //color: Colors.blueGrey[700]
                    ),
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

class TimesState extends State<Times> with SingleTickerProviderStateMixin {
  TranslationDatabase db;
  TabController _tabController;
  List times = ["present", "future"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: times.length);
    _tabController.addListener(changeTime);
    //getConjugation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getConjugation();
  }

  void changeTime() {
    BlocProvider.of2(context).newTime.add(_tabController.index);
  }

  void getConjugation() async {
    BlocProvider.of2(context).newConjugations.add(widget.name);
  }

  List<dynamic> findConjugation(Map conjugation, int place) {
    var activeList = conjugation[times[_tabController.index]];
    return [
      place,
      activeList.length > 0 && place < activeList.length ?
      activeList[place] :
        ""
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of2(context);
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: times.map((time) {
            return Text(time);
          }).toList(),
        ),
        Expanded(
          child: StreamBuilder(
            stream: bloc.conjugation,
            initialData: {"present": [], "future": []},
            builder: (context, snapshot) {
              print(snapshot.data);
              print("snapshot");
              return TabBarView(
                controller: _tabController,
                children: times.map((time) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 20.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int index) {
                        return Time(
                          conjugation: findConjugation(snapshot.data, index),
                          spanish: widget.name,
                          time: time,
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            }
          ),
          )
      ],
    );
  }
}

class Time extends StatefulWidget {
  final conjugation;
  final spanish;
  final time;

  Time(
      {Key key,
        @required this.conjugation,
        @required this.spanish,
        @required this.time,
        localFileSystem
      })
      : assert(conjugation != null),
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

  String getPath() {
    return widget.spanish + widget.time.toString().toLowerCase() + widget.conjugation[0].toString();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of2(context);
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
                  print(string);
                  bloc.changeConjugations.add([widget.conjugation[0], string]);
                },
                controller: controller,
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
                decoration: const InputDecoration.collapsed(hintText: null)),
          )),
          RecorderPlayer(getPath()),
        ],
      ),
    );
  }
}
