import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:throttle_debounce/throttle_debounce.dart';

import 'package:flutter_tensoring/addTranslation.dart';
import 'package:flutter_tensoring/database.dart';
import 'package:flutter_tensoring/Translation.dart';
import 'package:flutter_tensoring/assets/theme.dart';
import 'package:flutter_tensoring/BlocProvider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      child: MaterialApp(
        theme: ThemeData.light(
        ),
        title: "Dictionnary",
        home: new Dictionary(),
      ),
    );
  }
}

class Dictionary extends StatefulWidget {
  @override
  DictState createState() => new DictState();
}

class DictState extends State<Dictionary> with TickerProviderStateMixin {
  List translationData = [];
  //List translationDataTemp = [];
  double iconOpacity = 0.5;
  String hintText = "Chercher un mot, une expression ou un verbe";
  FocusNode _focus = FocusNode();
  TextEditingController searchController = TextEditingController();
  Widget searchIcon = Icon(
    Icons.search,
    //color: Colors.blueGrey.withOpacity(0.5),
  );
  AnimationController _controller;
  AnimationController _controllerList;
  Animation<double> numberList;
  var debouncer;


  @override
  void initState() {
    super.initState();
    debugPrint("heloooooo");
    //translationDataTemp = translationData.where((test) => true).toList();
    //print(translationDataTemp);
    _focus.addListener(_onFocusChange);
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _controllerList = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    //reinitializeAnimatedList(0);
    //debouncer = new Debouncer(const Duration(milliseconds: 250), callback, []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    listTemp(BlocProvider.of(context).translationDataTemp);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controllerList?.dispose();
    super.dispose();
  }

  void listTemp(Stream<List> stream) async {
    await for (var list in stream) {
      print("new list temp");
      reinitializeAnimatedList(list.length);
    }
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

  reinitializeAnimatedList(int length) {
    numberList = Tween(
      begin: 1.0,
      end: length + .0,
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
    print("focus change");
    if (searchController.text == "") {
        BlocProvider.of(context).onFocusChange.add(_focus.hasFocus);
    }
  }

  void callback() {
    String text = searchController.text;
    BlocProvider.of(context).queryChange.add(text);
  }

  void _onChangeSearch(String text) {
    //debouncer.debounce();
    callback();
  }

  /*bool _unfocus(String language, int index, String word) {
    print(language);
    print(index);
    print(word);
    print(translationData);
    var filter =
        translationData.where((translation) => translation[language] == word);
    if (language != "french" && filter.length > 0) {
      return true;
    } else {
      db.changeTranslation(
          word, language, translationDataTemp[index][language]);
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
  }*/

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Ultimas Palabras"),
        //backgroundColor: Colors.blueGrey,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          padding: EdgeInsets.only(top: 15.0),
          //color: Colors.blueGrey.withOpacity(0.8),
          child: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: appColors["searchBar"]
                  ),
                  padding: EdgeInsets.all(10.0),
                  height: 40.0,
                  child: StreamBuilder(
                    stream: bloc.searchBarState,
                    initialData: {
                      "icon": Icons.search,
                      "color": appColors["disabled"],
                      "text": "Chercher un mot, une expression ou un verbe"
                    },
                    builder: (context, snapshot) {
                      print(snapshot.data);
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (yo) {
                                _onChangeSearch(yo);
                              },
                              focusNode: _focus,
                              decoration: InputDecoration.collapsed(
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  hintText: snapshot.data["text"],
                                  hintStyle: TextStyle(fontSize: 12.0)),
                            ),
                          ),
                          Container(
                            width: 40.0,
                            child: FlatButton(
                              child: Icon(
                                  snapshot.data["icon"],
                                  color: snapshot.data["color"],
                              ),
                              onPressed: () {
                                bloc.queryChange.add(false);
                                searchController.text = "";
                                FocusScope.of(context).requestFocus(new FocusNode());
                              },
                            ),
                          )
                        ],
                      );
                    },
                  )),
              Expanded(
                  child: AnimatedBuilder(
                        animation: _controllerList,
                        builder: (BuildContext context, Widget child) {
                          return StreamBuilder<List>(
                            stream: bloc.translationDataTemp,
                            initialData: [],
                            builder: (context, snapshot) {
                              return ListView.builder(
                                  itemCount: snapshot == null ||
                               snapshot.data == null ||
                                    snapshot.data.length == 0
                                    ? 0
                                    : numberList.value.round(),
                                itemBuilder: (BuildContext context, int index) {
                                  return Translation(
                                    index: index,
                                    //unfocus: _unfocus,
                                    spanish: snapshot == null ? "" : snapshot.data[index]["spanish"],
                                    french: snapshot == null ? "" : snapshot.data[index]["french"],
                                    verb: snapshot == null ? false : snapshot.data[index]["verb"],
                                  );
                                });
                            },
                          );
                        }),
                  )
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
                  return AddTranslation(controller: _controller);
                },
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
