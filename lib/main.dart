import 'package:flutter/material.dart';
import 'dart:async';
import 'package:throttle_debounce/throttle_debounce.dart';

import 'package:flutter_tensoring/addTranslation.dart';
import 'package:flutter_tensoring/database.dart';
import 'package:flutter_tensoring/Translation.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Dictionnary",
      home: new Dictionary(),
    );
  }
}

class Dictionary extends StatefulWidget {
  @override
  DictState createState() => new DictState();
}

class DictState extends State<Dictionary> with TickerProviderStateMixin {
  List translationData = [];
  List translationDataTemp = [];
  double iconOpacity = 0.5;
  String hintText = "Chercher un mot, une expression ou un verbe";
  FocusNode _focus = FocusNode();
  TextEditingController searchController = TextEditingController();
  Widget searchIcon = Icon(
    Icons.search,
    color: Colors.blueGrey.withOpacity(0.5),
  );
  AnimationController _controller;
  AnimationController _controllerList;
  Animation<double> numberList;
  var debouncer;
  TranslationDatabase db;

  @override
  void initState() {
    super.initState();
    db = TranslationDatabase();
    db.initDB();
    debugPrint("heloooooo");
    init();
    //translationDataTemp = translationData.where((test) => true).toList();
    print(translationDataTemp);
    _focus.addListener(_onFocusChange);
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _controllerList = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    reinitializeAnimatedList();
    debouncer = new Debouncer(const Duration(milliseconds: 250), callback, []);
  }

  init() async {
    translationData = await db.getTranslations();
    translationDataTemp = translationData.where((test) => true).toList();
    reinitializeAnimatedList();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controllerList?.dispose();
    super.dispose();
  }

  Future _startAnimation() async {
    debugPrint("heloooooo");
    _controller.value = 0.0;
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {
      print('Animation Failed');
    }
  }

  Future _startAnimationList() async {
    _controllerList.value = 0.0;
    try {
      await _controllerList.forward().orCancel;
    } on TickerCanceled {
      print('Animation Failed');
    }
  }

  reinitializeAnimatedList() {
    numberList = Tween(
      begin: 1.0,
      end: translationDataTemp.length + .0,
    ).animate(CurvedAnimation(
        parent: _controllerList,
        curve: Interval(
          0.0,
          0.4,
          curve: Curves.linear,
        )));
    _startAnimationList();
  }

  void _onFocusChange() {
    if (searchController.text == "") {
      if (_focus.hasFocus) {
        setState(() {
          searchIcon = Icon(
            Icons.search,
            color: Colors.blueGrey.withOpacity(1.0),
          );
          hintText = "";
        });
      } else {
        setState(() {
          searchIcon = Icon(
            Icons.search,
            color: Colors.blueGrey.withOpacity(0.5),
          );
          hintText = "Chercher un mot, une expression ou un verbe";
        });
      }
    }
  }

  bool _filter(translation, text) {
    var tempText = text.toLowerCase().trim();
    var tempSpanish = translation["spanish"].toLowerCase().trim();
    var tempFrench = translation["french"].toLowerCase().trim();
    if (tempFrench.toString().contains(tempText)) {
      return true;
    }
    if (tempSpanish.toString().contains(tempText)) {
      return true;
    }
    return false;
  }

  void callback(List args) {
    String text = searchController.text;
    print(text);
    setState(() {
      if (text != "") {
        searchIcon = Icon(
          Icons.close,
          color: Colors.red,
          size: 18.0,
        );
        translationDataTemp = translationData
            .where((translation) => _filter(translation, text))
            .toList();
      } else {
        searchIcon = Icon(
          Icons.search,
          color: Colors.blueGrey.withOpacity(1.0),
        );
        translationDataTemp = translationData.where((test) => true).toList();
      }
      reinitializeAnimatedList();
    });
  }

  void _onChangeSearch(String text) {
    debouncer.debounce();
  }

  bool _unfocus(String language, int index, String word) {
    print(language);
    print(index);
    print(word);
    print(translationData);
    var filter =
        translationData.where((translation) => translation[language] == word);
    if (language != "french" && filter.length > 0) {
      return true;
    } else {
      for (var i = 0; i < translationData.length; i++) {
        if (translationData[i][language] ==
            translationDataTemp[index][language]) {
          translationData[i][language] = word;
        }
      }
      setState(() {
        translationDataTemp = translationData
            .where((translation) => _filter(translation, searchController.text))
            .toList();
      });
      print(translationData);
      return false;
    }
  }

  void _removeItem(index) {
    db.deleteTranslation(translationDataTemp[index]["spanish"]);
    print(translationData);
    translationData = translationData
        .where((translation) =>
            translation["spanish"] != translationDataTemp[index]["spanish"])
        .toList();
    print(translationData);
    setState(() {
      translationDataTemp = translationData
          .where((translation) => _filter(translation, searchController.text))
          .toList();
      numberList = Tween(
        begin: 1.0,
        end: translationDataTemp.length + .0,
      ).animate(CurvedAnimation(
          parent: _controllerList,
          curve: Interval(
            0.0,
            0.4,
            curve: Curves.linear,
          )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ultimas Palabras"),
        backgroundColor: Colors.blueGrey,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          padding: EdgeInsets.only(top: 15.0),
          color: Colors.blueGrey.withOpacity(0.8),
          child: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.white),
                  padding: EdgeInsets.all(10.0),
                  height: 40.0,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (yo) {
                            _onChangeSearch(yo);
                          },
                          focusNode: _focus,
                          decoration: InputDecoration.collapsed(
                              fillColor: Colors.white,
                              filled: true,
                              hintText: hintText,
                              hintStyle: TextStyle(fontSize: 15.0)),
                        ),
                        flex: 6,
                      ),
                      Expanded(
                        flex: 1,
                        child: FlatButton(
                          child: searchIcon,
                          onPressed: () {
                            setState(() {
                              searchController.text = "";
                              searchIcon = Icon(
                                Icons.search,
                                color: Colors.blueGrey.withOpacity(1.0),
                              );
                              _onChangeSearch("");
                            });
                          },
                        ),
                      )
                    ],
                  )),
              Expanded(
                  child: AnimatedBuilder(
                      animation: _controllerList,
                      builder: (BuildContext context, Widget child) {
                        return ListView.builder(
                            itemCount: translationDataTemp == null ||
                                    translationDataTemp.length == 0
                                ? 0
                                : numberList.value.round(),
                            itemBuilder: (BuildContext context, int index) {
                              return Translation(
                                index: index,
                                unfocus: _unfocus,
                                remove: _removeItem,
                                spanish: translationDataTemp[index]["spanish"],
                                french: translationDataTemp[index]["french"],
                                verb: translationDataTemp[index]["verb"],
                              );
                            });
                      }))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _startAnimation();
          Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) {
                  return AddTranslation(
                      onSubmit: (String spanish, String french, bool verb) {
                        print(spanish);
                        print(french);
                        print(verb);
                        db.addTranslation(Translation(
                            spanish: spanish, french: french, verb: verb));
                        translationData.insert(0, {
                          "spanish": spanish,
                          "french": french,
                          "verb": verb
                        });
                        setState(() {
                          translationDataTemp =
                              translationData.where((test) => true).toList();
                        });
                        reinitializeAnimatedList();
                      },
                      controller: _controller);
                },
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
