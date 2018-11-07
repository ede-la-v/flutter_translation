import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tensoring/pages/conjugation/conjugation.dart';
import 'package:flutter_tensoring/assets/theme.dart';
import 'package:flutter_tensoring/BlocProvider.dart';
import 'package:flutter_tensoring/widgets/recorderPlayer.dart';

class Translation extends StatefulWidget {
  final String spanish;
  final String french;
  final bool verb;
  final int index;

  Translation({
    Key key,
    @required this.spanish,
    @required this.french,
    @required this.verb,
    localFileSystem,
    this.index,
  })  : assert(spanish != null),
        assert(french != null),
        assert(verb != null),
        super(key: key);

  Map<String, dynamic> toMap1() {
    var map = Map<String, dynamic>();
    map['spanish'] = spanish;
    map['french'] = french;
    map['verb'] = verb;
    return map;
  }

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
      iconOpen = OpenVerb(
        french: widget.french,
        spanish: widget.spanish,
      );
    }
  }

  @override
  void didUpdateWidget(translation) {
    super.didUpdateWidget(translation);
    spanishController.text = widget.spanish;
    frenchController.text = widget.french;
    if (widget.verb) {
      iconOpen = OpenVerb(
        french: widget.french,
        spanish: widget.spanish,
      );
    } else {
      iconOpen = Container();
    }
  }

  void _onFocusSpanish() async {
    if (!_focusSpanish.hasFocus) {
      highlightSpanish =
          await BlocProvider.of1(context).onTranslationChange("spanish", widget.index, spanishController.text);
    } else if (!_focusSpanish.hasFocus) {
      highlightSpanish = false;
    }
    if (_focusSpanish.hasFocus) {
      highlightSpanish = true;
    }
    setState(() {});
  }

  void _onFocusFrench() async {
    if (!_focusFrench.hasFocus) {
      highlightFrench =
          await BlocProvider.of1(context).onTranslationChange("french", widget.index, frenchController.text);
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
    final bloc = BlocProvider.of1(context);
    return Dismissible(
        background: Container(color: Colors.red),
        key: Key(widget.spanish),
        onDismissed: (info) {
          print("delete item");
          bloc.deleteListItem.add(widget.index);
        },
        child: Padding(
            padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 10.0,
                bottom: 10.0
            ),
            child: Card(
              color: appColors["card"],
              elevation: 5.0,
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  //color: Colors.white,
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
                      Container(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                height: 25.0,
                                width: 25.0,
                                child: iconOpen
                            ),
                            RecorderPlayer(widget.spanish)
                          ],
                        ),
                      )
                    ],
                  )),
            )));
  }
}

class OpenVerb extends StatelessWidget {
  final french;
  final spanish;

  const OpenVerb({Key key, @required this.french, @required this.spanish})
      : assert(french != null),
        assert(spanish != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 18.0,
        padding: EdgeInsets.all(0.0),
        onPressed: () {
          Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) {
                  return Conjugation(french: french, spanish: spanish);
                },
              ));
        },
        icon: Icon(
          Icons.open_in_new,
          color: Colors.blueGrey.withOpacity(0.5),
        ));
  }
}

class TimeObj {
  TimeObj({this.je, this.tu, this.il, this.nous, this.vous, this.ils});

  String je, tu, il, nous, vous, ils;
}
