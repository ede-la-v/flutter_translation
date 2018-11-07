import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_tensoring/pages/addTranslation/addTranslation.dart';
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
  FocusNode _focus = FocusNode();
  AnimationController _controller;
  AnimationController _controllerList;
  Animation<double> numberList;
  TextEditingController searchBarController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChangeSearchBar);
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _controllerList = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //set listener of stream
    newListTempEvent(BlocProvider.of1(context).translationDataTemp);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controllerList?.dispose();
    super.dispose();
  }

  void newListTempEvent(Stream<List> stream) async {
    //enters in for loop every time a new element is added to the stream
    await for (var list in stream) {
      reinitializeAnimatedList(list.length);
    }
  }

  Future _startAnimationModal() async {
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

  void _onFocusChangeSearchBar() {
    if (searchBarController.text == "") {
      BlocProvider.of1(context).onFocusChange.add(_focus.hasFocus);
    }
  }

  void _onChangeSearch(String text) {
    BlocProvider.of1(context).queryChange.add(text);
    BlocProvider.of2(context).newConjugations.add("test");
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of1(context);
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
                              controller: searchBarController,
                              onChanged:  _onChangeSearch,
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
                                searchBarController.text = "";
                                bloc.queryChange.add(false);
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
          _startAnimationModal();
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
