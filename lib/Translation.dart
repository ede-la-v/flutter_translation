import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tensoring/conjugation.dart';

class Translation extends StatefulWidget {
  final String spanish;
  final String french;
  final bool verb;
  final int index;
  final unfocus;
  final remove;
  final present;
  final future;

  const Translation({
    Key key,
    @required this.spanish,
    @required this.french,
    @required this.verb,
    this.index,
    this.unfocus,
    this.present,
    this.future,
    this.remove,
  })  : assert(spanish != null),
        assert(french != null),
        assert(verb != null),
        super(key: key);

  Translation.fromJson1(Map json)
      : spanish = json["spanish"],
        french = json["french"],
        verb = json["verb"] == 1 ? true : false;

  Map<String, dynamic> toMap1() {
    var map = Map<String, dynamic>();
    map['spanish'] = spanish;
    map['french'] = french;
    map['verb'] = verb;
    return map;
  }

  Translation.fromJson2(Map json)
      : spanish = json["spanish"],
        french = json["french"],
        verb = json["verb"],
        present = TimeObj(
          je: json["present1"],
          tu: json["present2"],
          il: json["present3"],
          nous: json["present4"],
          vous: json["present5"],
          ils: json["present6"],
        ),
        future = TimeObj(
          je: json["future1"],
          tu: json["future2"],
          il: json["future3"],
          nous: json["future4"],
          vous: json["future5"],
          ils: json["future6"],
        );

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
      highlightSpanish =
          widget.unfocus("spanish", widget.index, spanishController.text);
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
      highlightFrench =
          widget.unfocus("french", widget.index, frenchController.text);
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
                              padding: EdgeInsets.only(bottom: 5.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.blueGrey))),
                              child: TextField(
                                  focusNode: _focusSpanish,
                                  controller: spanishController,
                                  decoration: InputDecoration.collapsed(
                                    hintText: null,
                                    fillColor:
                                        Colors.amberAccent.withOpacity(0.3),
                                    filled: highlightSpanish,
                                  ),
                                  //keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5.0),
                              color: Colors.white,
                              child: TextField(
                                focusNode: _focusFrench,
                                controller: frenchController,
                                decoration: InputDecoration.collapsed(
                                  hintText: null,
                                  fillColor:
                                      Colors.amberAccent.withOpacity(0.3),
                                  filled: highlightFrench,
                                ),
                                //keyboardType: TextInputType.multiline,
                                maxLines: null,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ]),
                    ),
                    iconOpen
                  ],
                ))));
  }
}

class OpenVerb extends StatelessWidget {
  final String name;

  const OpenVerb({Key key, @required this.name})
      : assert(name != null),
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
                    return Conjugation(
                      name: name,
                    );
                  },
                ));
          },
          child: Icon(
            Icons.open_in_new,
            color: Colors.blueGrey.withOpacity(0.5),
          )),
    );
  }
}

class TimeObj {
  TimeObj({this.je, this.tu, this.il, this.nous, this.vous, this.ils});

  String je, tu, il, nous, vous, ils;
}
