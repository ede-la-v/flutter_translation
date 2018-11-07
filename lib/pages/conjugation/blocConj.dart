import 'package:rxdart/subjects.dart';
import 'dart:async';

import 'package:flutter_tensoring/services/database.dart';

class BlocConj {
  TranslationDatabase db;
  List<String> times = ["present", "future"];

  BehaviorSubject<Map<String, List>> _conjugation = BehaviorSubject<Map<String, List>>();
  BehaviorSubject<int> _time = BehaviorSubject<int>();
  BehaviorSubject<String> _verb = BehaviorSubject<String>();

  final StreamController _newConjugations = StreamController();
  final StreamController _changeConjugations = StreamController();
  final StreamController _newTime = StreamController();

  BlocConj() {
    _initData();
    _initListener();
  }

  void _initData() async {
    db = TranslationDatabase();
  }

  void _initListener() {
    print("init listener conjjjjj");

    _newConjugations.stream.listen((verb) async {
      print("ok get conj");
      print(verb);
      _verb.add(verb);
      var conjugation = await db.getConjugation(verb);
      print(conjugation);
      print("salut");
      _conjugation.add(conjugation);
      print("there has been a new conjugation");
    });

    _changeConjugations.stream.listen((data) async {
      String verb = await _verb.stream.first;
      var timeString = times[await _time.stream.first];
      print(timeString);
      var conjugationTemp = await _conjugation.stream.first;
      conjugationTemp[timeString][data[0]] = data[1].toLowerCase();
      print(conjugationTemp);
      db.changeTranslation(data[1].toLowerCase(),
          timeString + (data[0] + 1).toString(), verb);
      print(conjugationTemp);
      _conjugation.add(conjugationTemp);
    });

    _newTime.stream.listen((newTime) {
      _time.add(newTime);
    });

  }

  Sink get newConjugations => _newConjugations.sink;
  Sink get changeConjugations => _changeConjugations.sink;
  Sink get newTime => _newTime.sink;

  Stream<Map> get conjugation => _conjugation.stream;
  Stream<int> get time => _time.stream;
  Stream<String> get verb => _verb.stream;

  void dispose() {
    _newConjugations.close();
    _changeConjugations.close();
    _newTime.close();
    _conjugation.close();
    _time.close();
    _verb.close();
  }
}