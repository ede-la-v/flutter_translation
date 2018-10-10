import 'package:flutter/material.dart';
import 'dart:async';
import 'package:throttle_debounce/throttle_debounce.dart';

import 'package:flutter_tensoring/addTranslation.dart';
import 'package:flutter_tensoring/conjugation.dart';

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
  List translationData = [
    {"spanish": "hacer", "french": "faire", "verb": true},
    {"spanish": "vaso", "french": "verre", "verb": false},
    {"spanish": "computadora", "french": "ordinateurjhjhjhjkhjhkjhjhkjhjkhjkhkjhjjkhjppppppppppppppppp", "verb": false},
    {"spanish": "computadora", "french": "ordinateurjhjhjhjkhjhkjhjhkjhjkhjkhkjhjjkhjppppppppppppppppp", "verb": false},
    {"spanish": "computadora", "french": "ordinateurjhjhjhjkhjhkjhjhkjhjkhjkhkjhjjkhjppppppppppppppppp", "verb": false},
    {"spanish": "computadora", "french": "ordinateurjhjhjhjkhjhkjhjhkjhjkhjkhkjhjjkhjppppppppppppppppp", "verb": false},
    {"spanish": "computadora", "french": "ordinateurjhjhjhjkhjhkjhjhkjhjkhjkhkjhjjkhjppppppppppppppppp", "verb": false},
    {"spanish": "computadora", "french": "ordinateurjhjhjhjkhjhkjhjhkjhjkhjkhkjhjjkhjppppppppppppppppp", "verb": false},
  ];
  List translationDataTemp;
  double iconOpacity = 0.5;
  String hintText = "Chercher un mot, une expression ou un verbe";
  FocusNode _focus = FocusNode();
  TextEditingController searchController = TextEditingController();
  Widget searchIcon = Icon(Icons.search, color: Colors.blueGrey.withOpacity(0.5),);
  AnimationController _controller;
  AnimationController _controllerList;
  Animation<double> numberList;
  var debouncer;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    translationDataTemp = translationData.where((test) => true).toList();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _controllerList = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
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
    debouncer = new Debouncer(const Duration(milliseconds:250), callback, []);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controllerList?.dispose();
    super.dispose();
  }

  Future _startAnimation() async {
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

  void _onFocusChange(){
    if (searchController.text == "") {
      if (_focus.hasFocus) {
        setState(() {
          searchIcon = Icon(Icons.search, color: Colors.blueGrey.withOpacity(1.0),);
          hintText = "";
        });
      } else {
        setState(() {
          searchIcon = Icon(Icons.search, color: Colors.blueGrey.withOpacity(0.5),);
          hintText = "Chercher un mot, une expression ou un verbe";
        });
      }
    }
  }

  bool _filter(translation, text){
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
        searchIcon = Icon(Icons.close, color: Colors.red, size: 18.0,);
        translationDataTemp = translationData.where((translation) => _filter(translation, text)).toList();
      } else {
        searchIcon = Icon(Icons.search, color: Colors.blueGrey.withOpacity(1.0),);
        translationDataTemp = translationData.where((test) => true).toList();
      }
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
    var filter = translationData.where((translation) => translation[language] == word);
    if (language != "french" && filter.length > 0) {
      return true;
    } else {
      for (var i=0; i<translationData.length; i++) {
        if (translationData[i][language] == translationDataTemp[index][language]) {
          translationData[i][language] = word;
        }
      }
      setState(() {
        translationDataTemp = translationData.where((translation) => _filter(translation, searchController.text)).toList();
      });
      print(translationData);
      return false;
    }
  }

  void _removeItem(index) {
    print(translationData);
    translationData = translationData.where((translation) => translation["spanish"] != translationDataTemp[index]["spanish"]).toList();
    print(translationData);
    setState(() {
      translationDataTemp = translationData.where((translation) => _filter(translation, searchController.text)).toList();
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
                      color: Colors.white
                  ),
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
                              hintStyle: TextStyle(
                                  fontSize: 15.0
                              )
                          ),
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
                              searchIcon = Icon(Icons.search, color: Colors.blueGrey.withOpacity(1.0),);
                              _onChangeSearch("");
                            });
                          },
                        ),
                      )
                    ],
                  )

              ),
              Expanded(
                child: AnimatedBuilder(
                    animation: _controllerList,
                    builder: (BuildContext context, Widget child) {
                      return ListView.builder(
                          itemCount: translationDataTemp == null ? 0 : numberList.value.round(),
                          itemBuilder: (BuildContext context, int index) {
                            return Translation(
                              index: index,
                              unfocus: _unfocus,
                              remove: _removeItem,
                              spanish: translationDataTemp[index]["spanish"],
                              french: translationDataTemp[index]["french"],
                              verb: translationDataTemp[index]["verb"],
                            );
                          }
                      );
                    }
                    )
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
                  return AddTranslation(
                    onSubmit: (String spanish, String french, bool verb) {
                    print(spanish);
                    print(french);
                    print(verb);
                    translationData.insert(0, {
                      "spanish": spanish,
                      "french": french,
                      "verb": verb
                    });
                    setState(() {
                      translationDataTemp = translationData.where((test) => true).toList();
                    });
                    print(translationData);
                    print(translationDataTemp);
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

class Translation extends StatefulWidget {
  final String spanish;
  final String french;
  final bool verb;
  final int index;
  final unfocus;
  final remove;

  const Translation({
    Key key,
    @required this.spanish,
    @required this.french,
    @required this.verb,
    @required this.index,
    @required this.unfocus,
    @required this.remove,
  })  : assert(spanish != null),
        assert(french != null),
        assert(verb != null),
        assert(index != null),
        assert(unfocus != null),
        assert(remove != null),
        super(key: key);

  @override
  TranslationState createState() => new TranslationState();
}

class TranslationState extends State<Translation> {
  TextEditingController spanishController = TextEditingController();
  TextEditingController frenchController = TextEditingController();
  FocusNode _focusSpanish = FocusNode();
  FocusNode _focusFrench = FocusNode();
  bool highlightSpanish = false;
  bool highlightFrench = false;
  Widget iconOpen = Container();

  @override
  void initState() {
    super.initState();
    print(widget.spanish);
    spanishController.text = widget.spanish;
    frenchController.text = widget.french;
    _focusSpanish.addListener(_onFocusSpanish);
    _focusFrench.addListener(_onFocusFrench);
    if (widget.verb) {
      iconOpen = OpenVerb(name: widget.french);
    }
  }

  @override
  void didUpdateWidget(translation) {
    super.didUpdateWidget(translation);
    spanishController.text = widget.spanish;
    frenchController.text = widget.french;
    if (widget.verb) {
      iconOpen = OpenVerb(name: widget.french);
    } else {
      iconOpen = Container();
    }
  }

  void _onFocusSpanish() {
    if (!_focusSpanish.hasFocus && spanishController.text != widget.spanish) {
      highlightSpanish = widget.unfocus("spanish", widget.index, spanishController.text);
    } else if (!_focusSpanish.hasFocus) {
      highlightSpanish = false;
    }
    if (_focusSpanish.hasFocus) {
      highlightSpanish = true;
    }
    setState(() {});
  }

  void _onFocusFrench() {
    if (!_focusFrench.hasFocus && frenchController.text != widget.french) {
      highlightFrench = widget.unfocus("french", widget.index, frenchController.text);
    } else if (!_focusFrench.hasFocus) {
      highlightFrench = false;
    }
    if (_focusFrench.hasFocus) {
      highlightFrench = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        background: Container(color: Colors.red),
        key: Key(widget.spanish),
        onDismissed: (info) {
          widget.remove(widget.index);
        },
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
                padding: EdgeInsets.all(10.0),
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: 5.0
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.blueGrey
                                      )
                                  )
                              ),
                              child: TextField(
                                  focusNode: _focusSpanish,
                                  controller: spanishController,
                                  decoration: InputDecoration.collapsed(
                                    hintText: null,
                                    fillColor: Colors.amberAccent.withOpacity(0.3),
                                    filled: highlightSpanish,
                                  ),
                                  //keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  top: 5.0
                              ),
                              color: Colors.white,
                              child: TextField(
                                focusNode: _focusFrench,
                                controller: frenchController,
                                decoration: InputDecoration.collapsed(
                                  hintText: null,
                                  fillColor: Colors.amberAccent.withOpacity(0.3),
                                  filled: highlightFrench,
                                ),
                                //keyboardType: TextInputType.multiline,
                                maxLines: null,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontStyle: FontStyle.italic
                                ),
                              ),
                            ),
                          ]
                      ),
                    ),
                    iconOpen
                  ],
                )
            )
        )
    );
  }
}

class OpenVerb extends StatelessWidget {
  final String name;

  const OpenVerb({
    Key key,
    @required this.name
  })  : assert(name != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: FlatButton(
          padding: EdgeInsets.only(left: 10.0),
          onPressed: () {
            Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) {
                return Conjugation(name: name,);
              },
            ));
          },
          child: Icon(Icons.open_in_new, color: Colors.blueGrey.withOpacity(0.5),)
      ),
    );
  }
}