import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'dart:async';

import 'package:flutter_tensoring/database.dart';

class Bloc {
  TranslationDatabase db;
  List translationData;
  String query;

  BehaviorSubject<List> _translationDataTemp =
  BehaviorSubject<List>(seedValue: []);

  final StreamController _queryChangeController = StreamController();
  final StreamController _deleteListItem = StreamController();
  final StreamController _addListItem = StreamController();

  Bloc() {
    this.query = "";
    _initData();
    _initListeners();
  }

  void _initData() async {
    db = TranslationDatabase();
    db.initDB();
    translationData = await db.getTranslations();
    print(translationData);
    _updateListTemp(query);
  }

  void _initListeners() async {
    _queryChangeController.stream.listen((query){
      this.query = query;
      _updateListTemp(query);
    });
    print("algo1");
    print("algo2");
    _deleteListItem.stream.listen((index) async {
      print(index);
      print("index deleted");
      var lastTempList = await _translationDataTemp.stream.first;
      print(lastTempList);
      db.deleteTranslation(lastTempList[index]["spanish"]);
      print(translationData);
      translationData =
          translationData
          .where((translation) =>
                    translation["spanish"] != lastTempList[index]["spanish"])
          .toList();
      print(translationData);
      _updateListTemp(this.query);
    });
    _addListItem.stream.listen((translation) {
      db.addTranslation(translation);
      translationData.insert(0, translation);
      _updateListTemp(this.query);
    });
  }

  Sink get queryChange => _queryChangeController.sink;
  Sink get deleteListItem => _deleteListItem.sink;
  Sink get addListItem => _addListItem.sink;

  Stream<List> get translationDataTemp => _translationDataTemp.stream;

  bool _filter(translation, text) {
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

  void _updateListTemp(query) {
    _translationDataTemp.add(translationData
        .where((translation) => _filter(translation, query))
        .toList());
  }
}