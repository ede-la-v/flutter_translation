import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:audioplayers/audioplayers.dart';

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
  final LocalFileSystem localFileSystem;

  Translation({
    Key key,
    @required this.spanish,
    @required this.french,
    @required this.verb,
    localFileSystem,
    this.index,
    this.unfocus,
    this.present,
    this.future,
    this.remove,
  })  : assert(spanish != null),
        assert(french != null),
        assert(verb != null),
        this.localFileSystem = localFileSystem ?? LocalFileSystem(),
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
  bool _isRecording = false;
  bool _isPlaying = false;
  Recording _recording = new Recording();
  AudioPlayer audioPlayer = new AudioPlayer();
  IconData iconLeft = Icons.play_circle_filled;
  IconData iconRight = Icons.mic;
  Color playColor = Colors.blueGrey.withOpacity(0.5);

  @override
  void initState() {
    super.initState();
    audioPlayer.completionHandler = () {
      setState(() {
        _isPlaying = false;
        iconLeft = Icons.play_circle_filled;
        iconRight = Icons.mic;
        playColor = Colors.blue;
      });
    };
    initAudioPlayer();
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
    initAudioPlayer();
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

  initAudioPlayer() async {
    var dir = await getApplicationDocumentsDirectory();
    if (await io.File('${dir.path}/${widget.spanish}.m4a').exists()) {
      setState(() {
        playColor = Colors.blue;
      });
    } else {
      setState(() {
        playColor = Colors.blueGrey.withOpacity(0.5);
      });
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

  void startRecording() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        print("user gave permisssion");
        if (widget.spanish != null && widget.spanish != "") {
          String path = widget.spanish;
          if (!widget.spanish.contains('/')) {
            io.Directory appDocDirectory =
            await getApplicationDocumentsDirectory();
            path = appDocDirectory.path + '/' + widget.spanish;
          }
          print("Start recording: $path");
          await AudioRecorder.start(
              path: path, audioOutputFormat: AudioOutputFormat.AAC);
        } else {
          await AudioRecorder.start();
        }
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print("error:");
      print(e);
    }
  }

  Future stopRecording() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    print("  File length: ${await file.length()}");
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
  }

  void onPressedIconLeft() async {
    if (!_isRecording && !_isPlaying) {
      var dir = await getApplicationDocumentsDirectory();
      if (await io.File('${dir.path}/${widget.spanish}.m4a').exists()) {
        int result = await audioPlayer.play('${dir.path}/${widget.spanish}.m4a', isLocal: true);
        if (result == 1) {
          setState(() {
            _isPlaying = true;
            playColor = Colors.blueGrey.withOpacity(0.5);
            iconLeft = Icons.pause;
            iconRight = Icons.stop;
          });
        }
      }
    } else if (_isRecording && !_isPlaying) {
      await stopRecording();
      var dir = await getApplicationDocumentsDirectory();
      if (await io.File('${dir.path}/${widget.spanish}.m4a').exists()) {
        io.File('${dir.path}/${widget.spanish}.m4a').delete();
      }
      iconLeft = Icons.play_circle_filled;
      iconRight = Icons.mic;
    } else if (!_isRecording && _isPlaying) {
      int result = await audioPlayer.pause();
      if (result == 1) {
        _isPlaying = false;
        playColor = Colors.blue;
        iconLeft = Icons.play_circle_filled;
        iconRight = Icons.mic;
      }
    }
    setState(() {

    });
  }

  void onPressedIconRight() async {
    if (!_isRecording && !_isPlaying) {
      var dir = await getApplicationDocumentsDirectory();
      if (await io.File('${dir.path}/${widget.spanish}.m4a').exists()) {
        io.File('${dir.path}/${widget.spanish}.m4a').delete();
      }
      startRecording();
      playColor = Colors.blueGrey.withOpacity(0.5);
      iconLeft = Icons.cancel;
      iconRight = Icons.done;
    } else if (_isRecording && !_isPlaying) {
      stopRecording();
      playColor = Colors.blue;
      iconLeft = Icons.play_circle_filled;
      iconRight = Icons.mic;
    } else if (!_isRecording && _isPlaying) {
      int result = await audioPlayer.stop();
      if (result == 1) {
        _isPlaying = false;
        playColor = Colors.blue;
        iconLeft = Icons.play_circle_filled;
        iconRight = Icons.mic;
      }
    }
    setState(() {

    });
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
                          Row(
                            children: <Widget>[
                              Container(
                                height: 25.0,
                                width: 25.0,
                                child: IconButton(
                                  iconSize: 18.0,
                                    icon: Icon(
                                      iconLeft,
                                      color: playColor,
                                    ),
                                    padding: EdgeInsets.all(0.0),
                                    onPressed: () async {
                                      onPressedIconLeft();
                                    },
                                ),
                              ),
                              Container(
                                height: 25.0,
                                width: 25.0,
                                child: IconButton(
                                  iconSize: 18.0,
                                  icon: Icon(
                                    iconRight,
                                    color: Colors.blueGrey.withOpacity(0.5),
                                  ),
                                  padding: EdgeInsets.all(0.0),
                                  onPressed: () {
                                    onPressedIconRight();
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ))));
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
