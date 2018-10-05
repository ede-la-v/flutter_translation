import 'package:flutter/material.dart';

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

class DictState extends State<Dictionary> {
  final List translationData = [
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

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    translationDataTemp = translationData.where((test) => true).toList();
  }

  void _onFocusChange(){
    if (_focus.hasFocus) {
      setState(() {
        iconOpacity = 1.0;
        hintText = "";
      });
    } else {
      setState(() {
        iconOpacity = 0.5;
        hintText = "Chercher un mot, une expression ou un verbe";
      });
    }
  }

  void _onChangeSearch(String text) {
    setState(() {
      if (text != "") {
        translationDataTemp = translationData.where((translation) {
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
        }).toList();
      } else {
        translationDataTemp = translationData.where((test) => true).toList();
      }
    });
  }

  bool _unfocus(String language, int index, String word) {
    var filter = translationData.where((translation) => translation[language] == word);
    if (filter.length > 0) {
      return true;
    } else {
      translationData[index][language] = word;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ultimas Palabras"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
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
                  ),
                  Icon(
                    Icons.search,
                    color: Colors.blueGrey.withOpacity(iconOpacity),
                  )
                ],
              )
              
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: translationDataTemp == null ? 0 : translationDataTemp.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Translation(
                      index: index,
                      unfocus: _unfocus,
                      spanish: translationDataTemp[index]["spanish"],
                      french: translationDataTemp[index]["french"],
                      verb: translationDataTemp[index]["verb"],
                    );
                  }
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) {
                  return AddTranslation(onSubmit: (String spanish, String french, bool verb) {
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
                  },);
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

  const Translation({
    Key key,
    @required this.spanish,
    @required this.french,
    @required this.verb,
    @required this.index,
    @required this.unfocus,
  })  : assert(spanish != null),
        assert(french != null),
        assert(verb != null),
        assert(index != null),
        assert(unfocus != null),
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
      iconOpen = openVerb();
    }
  }

  @override
  void didUpdateWidget(translation) {
    super.didUpdateWidget(translation);
    spanishController.text = widget.spanish;
    frenchController.text = widget.french;
    if (widget.verb) {
      iconOpen = openVerb();
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
    return Padding(
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
                        Text(widget.spanish),
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
                              onChanged: (truc) {
                                spanishController.text = widget.spanish;
                              },
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
    );
  }
}

class openVerb extends StatelessWidget {
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
                return Conjugation();
              },
            ));
          },
          child: Icon(Icons.open_in_new, color: Colors.blueGrey.withOpacity(0.5),)
      ),
    );
  }
}