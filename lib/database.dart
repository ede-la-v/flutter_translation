import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter_tensoring/Translation.dart';

class TranslationDatabase {
  static final TranslationDatabase _instance = TranslationDatabase._internal();

  factory TranslationDatabase() => _instance;

  static Database _db;

  Future<Database> get db async {
    print("je recuprere la database");
    if (_db != null) {
      return _db;
    }
    print("salut");
    _db = await initDB();
    //await cleanUpDatabase(_db);
    print(_db);
    return _db;
  }

  TranslationDatabase._internal();

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "translation.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  Future cleanUpDatabase(Database db) async {
    print("delete movies");
    await db.execute('''DROP TABLE IF EXISTS Translations''');
    print("create transaltions");
    await db.execute('''CREATE TABLE IF NOT EXISTS Translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        spanish TEXT UNIQUE,
        french TEXT, 
        present1 TEXT,
        present2 TEXT,
        present3 TEXT,
        present4 TEXT,
        present5 TEXT,
        present6 TEXT,
        future1 TEXT,
        future2 TEXT,
        future3 TEXT,
        future4 TEXT,
        future5 TEXT,
        future6 TEXT,
        verb BIT)''');
  }

  void _onCreate(Database db, int version) async {
    print("salut de la creation");
    await db.execute('''DROP TABLE IF EXISTS Translations''');
    await db.execute('''CREATE TABLE IF NOT EXISTS Translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        spanish TEXT UNIQUE,
        french TEXT, 
        present1 TEXT,
        present2 TEXT,
        present3 TEXT,
        present4 TEXT,
        present5 TEXT,
        present6 TEXT,
        future1 TEXT,
        future2 TEXT,
        future3 TEXT,
        future4 TEXT,
        future5 TEXT,
        future6 TEXT,
        verb BIT)''');

    print("Database was Created!");
  }

  Future<int> addTranslation(Map<String, dynamic> translation) async {
    print(translation);
    print("la");
    var dbClient = await db;
    try {
      int res = await dbClient.insert("Translations", translation);
      print("Translation added $res");
      return res;
    } catch (e) {
      return 1;
    }
  }

  Future<List> getTranslations() async {
    var dbClient = await db;
    List resultFinal;
    var results = await dbClient
        .rawQuery('SELECT spanish, french, verb FROM Translations ORDER BY id DESC');
    print(results);
    resultFinal = results.map((translation) {
      return {
        "spanish": translation["spanish"],
        "french": translation["french"],
        "verb": translation["verb"] == 1 ? true : false,
      };
    }).toList();
    return resultFinal;
  }

  Future<Map<String, dynamic>> getConjugation(String spanish) async {
    var dbClient = await db;
    Map<String, dynamic> resultFinal = {"present": {}, "future": {}};
    var results = await dbClient.rawQuery(
        'SELECT * FROM Translations WHERE spanish = "' + spanish + '"');
    print('SELECT * FROM Translations WHERE spanish = "' + spanish + '"');
    print(results);
    resultFinal["present"] = [
      results[0]["present1"],
      results[0]["present2"],
      results[0]["present3"],
      results[0]["present4"],
      results[0]["present5"],
      results[0]["present6"],
    ];
    resultFinal["future"] = [
      results[0]["future1"],
      results[0]["future2"],
      results[0]["future3"],
      results[0]["future4"],
      results[0]["future5"],
      results[0]["future6"],
    ];
    return resultFinal;
  }

  Future deleteTranslation(String spanish) async {
    var dbClient = await db;
    await dbClient.rawDelete(
        'DELETE FROM Translations WHERE spanish = "' + spanish + '"');
  }

  Future changeTranslation(String change, String column, String spanish) async {
    var dbClient = await db;
    print('UPDATE Translations SET ' +
        column +
        ' = "' +
        change +
        '" WHERE spanish = "' +
        spanish +
        '"');
    await dbClient.rawUpdate('UPDATE Translations SET ' +
        column +
        ' = "' +
        change +
        '" WHERE spanish = "' +
        spanish +
        '"');
  }

  Future closeDb() async {
    var dbClient = await db;
    dbClient.close();
  }
}
