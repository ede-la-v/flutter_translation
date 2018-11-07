import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_tensoring/assets/theme.dart';
import 'package:flutter_tensoring/services/recorderPlayerService.dart';

class RecorderPlayer extends StatefulWidget {
  final path;

  RecorderPlayer(this.path);

  @override
  RecorderPlayerState createState() => new RecorderPlayerState();
}

class RecorderPlayerState extends State<RecorderPlayer> {
  IconData iconLeft = Icons.play_circle_filled;
  IconData iconRight = Icons.mic;
  bool _isPlaying = false;
  bool _isRecording = false;
  Color playColor = appColors["disabled"];
  RecorderService recorderService = RecorderService();

  @override
  void initState() {
    recorderService.completion = () {
      setState(() {
        _isPlaying = false;
        iconLeft = Icons.play_circle_filled;
        iconRight = Icons.mic;
        playColor = appColors["clickable"];
      });
    };
    initAudioPlayer();
    super.initState();
  }

  @override
  void didUpdateWidget(RecorderPlayer oldWidget) {
    initAudioPlayer();
    super.didUpdateWidget(oldWidget);
  }

  initAudioPlayer() async {
    if (await recorderService.fileExist(widget.path)) {
      setState(() {
        playColor = Colors.blue;
      });
    } else {
      setState(() {
        playColor = Colors.blueGrey.withOpacity(0.5);
      });
    }
  }

  Future<bool> startRecording() async {
    String resultRecording = await recorderService.startRecording(widget.path);
    if (resultRecording != "") {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text(resultRecording)));
      return false;
    } else {
      _isRecording = true;
      return true;
    }
  }

  Future<bool> stopRecording() async {
    String resultRecording = await recorderService.stopRecording();
    if (resultRecording != "") {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text(resultRecording)));
      return false;
    } else {
      _isRecording = false;
      return true;
    }
  }

  void onPressedIconLeft() async {
    if (!_isRecording && !_isPlaying) {
        String resultPlay = await recorderService.startPlaying(widget.path);
        if (resultPlay == "") {
          setState(() {
            _isPlaying = true;
            playColor = Colors.blueGrey.withOpacity(0.5);
            iconLeft = Icons.pause;
            iconRight = Icons.stop;
          });
        } else {
          Scaffold.of(context).showSnackBar(
              new SnackBar(content: new Text(resultPlay)));
        }
    } else if (_isRecording && !_isPlaying) {
      await stopRecording();
      print("stop recording");
      await recorderService.deleteRecord(widget.path);
      iconLeft = Icons.play_circle_filled;
      iconRight = Icons.mic;
    } else if (!_isRecording && _isPlaying) {
      int result = await recorderService.pausePlaying();
      if (result == 1) {
        _isPlaying = false;
        playColor = Colors.blue;
        iconLeft = Icons.play_circle_filled;
        iconRight = Icons.mic;
      }
    }
    setState(() {});
  }

  void onPressedIconRight() async {
    if (!_isRecording && !_isPlaying) {
      await recorderService.deleteRecord(widget.path);
      if (await startRecording()) {
        playColor = Colors.blueGrey.withOpacity(0.5);
        iconLeft = Icons.cancel;
        iconRight = Icons.done;
      }
    } else if (_isRecording && !_isPlaying) {
      stopRecording();
      playColor = Colors.blue;
      iconLeft = Icons.play_circle_filled;
      iconRight = Icons.mic;
    } else if (!_isRecording && _isPlaying) {
      int result = await recorderService.stopPlaying();
      if (result == 1) {
        _isPlaying = false;
        playColor = Colors.blue;
        iconLeft = Icons.play_circle_filled;
        iconRight = Icons.mic;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      child: Row(
        children: <Widget>[
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