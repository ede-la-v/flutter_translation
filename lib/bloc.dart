import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'dart:async';

import 'package:flutter_tensoring/database.dart';

class Bloc {
  List translationData = [];
  TranslationDatabase db;

  BehaviorSubject<List> _translationDataTemp =
  BehaviorSubject<List>(seedValue: []);

  final StreamController _queryChangeController =
  StreamController();

  Bloc() {
    init();
    _queryChangeController.stream.listen((query){
      if (query != "") {
        _translationDataTemp.add(translationData
            .where((translation) => _filter(translation, query))
            .toList()
        );
      } else {
        _translationDataTemp.add(translationData.where((test) => true).toList());
      }
    });

  }

  init() async {
    db = TranslationDatabase();
    db.initDB();
    translationData = await db.getTranslations();
    _translationDataTemp.add(translationData.where((test) => true).toList());
  }

  Sink get queryChange => _queryChangeController.sink;

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
}