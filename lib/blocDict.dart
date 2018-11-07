import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';

import 'package:flutter_tensoring/services/database.dart';
import 'package:flutter_tensoring/assets/theme.dart';

class BlocDict {
  TranslationDatabase db;
  List translationData;
  String query;

  BehaviorSubject<List> _translationDataTemp = BehaviorSubject<List>(seedValue: []);
  BehaviorSubject<Map> _searchBarState = BehaviorSubject<Map>(seedValue: {
    "icon": Icons.search,
    "color": appColors["disabled"],
    "text": "Chercher un mot, une expression ou un verbe"
  });

  final StreamController _queryChangeController = StreamController();
  final StreamController _deleteListItem = StreamController();
  final StreamController _addListItem = StreamController();
  final StreamController _onFocusChange = StreamController();


  BlocDict() {
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

    _queryChangeController.stream.transform(debounce(Duration(milliseconds: 250))).listen((query){
      if (!(query is bool)) {
        this.query = query;
        _updateListTemp(query);
        this.query = query;
        if (query == "") {
          _searchBarState.add({
            "icon": Icons.search,
            "color": appColors["clickable"],
            "text": ""
          });
        } else {
          _searchBarState.add({
            "icon": Icons.close,
            "color": appColors["cancel"],
            "text": ""
          });
        }
      } else {
        this.query = "";
        _updateListTemp("");
      }

    });

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

    _onFocusChange.stream.listen((focus) {
        if (focus) {
          _searchBarState.add({
            "icon": Icons.search,
            "color": appColors["clickable"],
            "text": ""
          });
        } else {
          _searchBarState.add({
            "icon": Icons.search,
            "color": appColors["disabled"],
            "text": "Chercher un mot, une expression ou un verbe"
          });
        }
    });

  }

  Sink get queryChange => _queryChangeController.sink;
  Sink get deleteListItem => _deleteListItem.sink;
  Sink get addListItem => _addListItem.sink;
  Sink get onFocusChange => _onFocusChange.sink;

  Stream<List> get translationDataTemp => _translationDataTemp.stream;
  Stream<Map> get searchBarState => _searchBarState.stream;

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
        .toList()
    );
  }

  Future<bool> onTranslationChange(String language, int index, String word) async {
    var lastTempList = await _translationDataTemp.stream.first;
    var filter = translationData.where((translation) => translation[language] == word).toList();
    var index2 = lastTempList.indexOf(filter.length > 0 ? filter[0] : {});
    if (language != "french" && (filter.length > 2 || (filter.length == 1 && index2 != index))) {
      return true;
    } else {
      db.changeTranslation(
          word, language, lastTempList[index]["spanish"]);
      for (var i = 0; i < translationData.length; i++) {
        if (translationData[i]["spanish"] ==
            lastTempList[index]["spanish"]) {
          translationData[i][language] = word;
        }
      }
      return false;
    }
  }

  void dispose() {
    _queryChangeController.close();
    _deleteListItem.close();
    _addListItem.close();
    _onFocusChange.close();
    _translationDataTemp.close();
    _searchBarState.close();
  }
}