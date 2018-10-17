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
    _db = await initDB();
    await cleanUpDatabase(_db);
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
    await db.execute('''DROP TABLE IF EXISTS Movies''');
    print("create transaltions");
    await db.execute('''CREATE TABLE IF NOT EXISTS Translations (
        spanish TEXT PRIMARY KEY,
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
        spanish TEXT PRIMARY KEY,
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

  Future<int> addTranslation(Translation Translation) async {
    var dbClient = await db;
    try {
      int res = await dbClient.insert("Translations", Translation.toMap1());
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
        .rawQuery('SELECT spanish, french, verb FROM Translations');
    print("ok ok");
    resultFinal = results.map((translation) {
      return {
        "spanish": translation["spanish"],
        "french": translation["french"],
        "verb": translation["verb"] == 1 ? true : false,
      };
    }).toList();
    return resultFinal;
  }

  Future deleteTranslation(String spanish) async {
    var dbClient = await db;
    await dbClient.rawDelete(
        'DELETE FROM Translations WHERE spanish = "' + spanish + '"');
  }

  Future closeDb() async {
    var dbClient = await db;
    dbClient.close();
  }
}
