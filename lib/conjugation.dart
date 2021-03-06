import 'package:flutter/material.dart';
import 'package:flutter_tensoring/database.dart';
import 'package:meta/meta.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:file/local.dart';

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

class TimesState extends State<Times> with SingleTickerProviderStateMixin {
  int time = 1;
  Map conjugation = {"present": [], "future": []};
  TranslationDatabase db;
  TabController _tabController;
  List times = ["present", "future"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: times.length);
    _tabController.addListener(changeTime);
    db = TranslationDatabase();
    getConjugation();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    print(_tabController.index); print("_tabController.index");
  }

  void changeTime() {
    setState(() {
      time = _tabController.index + 1;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: times.map((time) {
            return Text(time);
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: times.map((time) {
              return Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 6,
                      itemBuilder: (BuildContext context, int index) {
                        return Time(
                          changeConjugation: changeConjugation,
                          conjugation: findConjugation(index),
                          spanish: widget.name,
                          time: time,
                        );
                      },
                    ),
                  );
            }).toList(),
          ),
        )
      ],
    );
  }
}

class Time extends StatefulWidget {
  final conjugation;
  final changeConjugation;
  final spanish;
  final time;
  final LocalFileSystem localFileSystem;

  Time(
      {Key key,
        @required this.conjugation,
        @required this.changeConjugation,
        @required this.spanish,
        @required this.time,
        localFileSystem
      })
      : assert(conjugation != null),
        assert(changeConjugation != null),
        this.localFileSystem = localFileSystem ?? LocalFileSystem(),
        super(key: key);

  @override
  TimeState createState() => new TimeState();
}

class TimeState extends State<Time> {
  TextEditingController controller = TextEditingController();
  IconData iconLeft = Icons.play_circle_filled;
  IconData iconRight = Icons.mic;
  bool _isPlaying = false;
  bool _isRecording = false;
  Recording _recording = new Recording();
  AudioPlayer audioPlayer = new AudioPlayer();
  Color playColor = Colors.blueGrey.withOpacity(0.5);

  @override
  void initState() {
    audioPlayer.completionHandler = () {
      setState(() {
        _isPlaying = false;
        iconLeft = Icons.play_circle_filled;
        iconRight = Icons.mic;
        playColor = Colors.blue;
      });
    };
    
    initAudioPlayer();
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
    initAudioPlayer();
    if (widget.conjugation != null && widget.conjugation[1] != null) {
      controller.text = widget.conjugation[1];
    } else {
      controller.text = "";
    }
    super.didUpdateWidget(oldWidget);
  }

  initAudioPlayer() async {
    var dir = await getApplicationDocumentsDirectory();
    if (await io.File('${dir.path}/${getPath()}.m4a').exists()) {
      setState(() {
        playColor = Colors.blue;
      });
    } else {
      setState(() {
        playColor = Colors.blueGrey.withOpacity(0.5);
      });
    }
  }

  void startRecording() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        print("user gave permisssion");
        String path = getPath();
        if (path != null && path != "") {
          if (!path.contains('/')) {
            io.Directory appDocDirectory =
            await getApplicationDocumentsDirectory();
            path = appDocDirectory.path + '/' + path;
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

  String getPath() {
    return widget.spanish + widget.time.toString().toLowerCase() + widget.conjugation[0].toString();
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
      if (await io.File('${dir.path}/${getPath()}.m4a').exists()) {
        int result = await audioPlayer.play('${dir.path}/${getPath()}.m4a', isLocal: true);
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
      print("stop recording");
      var dir = await getApplicationDocumentsDirectory();
      if (await io.File('${dir.path}/${getPath()}.m4a').exists()) {
        io.File('${dir.path}/${getPath()}.m4a').delete();
        print("deleted recording");
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
      if (await io.File('${dir.path}/${getPath()}.m4a').exists()) {
        io.File('${dir.path}/${getPath()}.m4a').delete();
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
                  widget.changeConjugation(widget.conjugation[0], string);
                },
                controller: controller,
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
                decoration: const InputDecoration.collapsed(hintText: null)),
          )),
          Container(
            margin: EdgeInsets.only(left: 15.0),
            height: 25.0,
            width: 25.0,
            child: IconButton(
              iconSize: 19.0,
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
            margin: EdgeInsets.only(left: 10.0),
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
      ),
    );
  }
}
