import 'package:path_provider/path_provider.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'dart:io' as io;
import 'package:file/local.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:async';

class RecorderService {

  static bool _isRecording = false;
  static bool _isPlaying = false;
  AudioPlayer audioPlayer = new AudioPlayer();
  final LocalFileSystem localFileSystem = LocalFileSystem();

  set completion(function) {
    audioPlayer.completionHandler = () {
      function();
      _isPlaying = false;
    };
  }

  Future<String> startRecording(String path) async {
    if (!_isRecording) {
      try {
        if (await AudioRecorder.hasPermissions) {
          print("user gave permisssion");
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
          _isRecording = isRecording;
          return "";
        } else {
          return "Please give permission";
        }
      } catch (e) {
        print("error:");
        print(e);
      }
    } else {
      return "Already recording";
    }
  }

  Future<String> stopRecording() async {
    if (_isRecording) {
      var recording = await AudioRecorder.stop();
      print("Stop recording: ${recording.path}");
      bool isRecording = await AudioRecorder.isRecording;
      io.File file = localFileSystem.file(recording.path);
      print("  File length: ${await file.length()}");
      _isRecording = isRecording;
      return "";
    } else {
      return "Not recording at the moment";
    }

  }

  Future<String> startPlaying(String path) async {
    if (!_isPlaying) {
      var dir = await getApplicationDocumentsDirectory();
      if (await io.File('${dir.path}/$path.m4a').exists()) {
        int result = await audioPlayer.play('${dir.path}/$path.m4a', isLocal: true);
        if (result == 1) {
          _isPlaying = true;
          return "";
        } else {
          print("Error playing the record");
        }
      } else {
        print("Error: record file doesn't exist");
      }
    } else {
      return "A record is already playing";
    }
  }

  Future<int> pausePlaying() async {
    if (_isPlaying) {
      int result = await audioPlayer.pause();
      if (result == 1) {
        _isPlaying = false;
      } else {
        print("Error pausing the record");
      }
      return result;
    }
  }

  Future<int> stopPlaying() async {
      int result = await audioPlayer.stop();
      if (result == 1) {
        _isPlaying = false;
      }
      return result;
  }

  Future deleteRecord(String path) async {
    var dir = await getApplicationDocumentsDirectory();
    if (await io.File('${dir.path}/$path.m4a').exists()) {
      io.File('${dir.path}/$path.m4a').delete();
      print("deleted recording");
    }
  }

  Future<bool> fileExist(String path) async {
    var dir = await getApplicationDocumentsDirectory();
    if (await io.File('${dir.path}/$path.m4a').exists()) {
      return true;
    } else {
      return false;
    }
  }
}