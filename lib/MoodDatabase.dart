import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dsa_mind_health/MoodModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class MoodDatabase {
  static final MoodDatabase _moodDatabase = MoodDatabase._internal();
  factory MoodDatabase() => _moodDatabase;
  MoodDatabase._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final getDirectory = await getApplicationDocumentsDirectory();
    String path = '${getDirectory.path}/moods.db';
    log(path);
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE Moods('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'scale INTEGER,'
      'title TEXT,'
      'description TEXT,'
      'createdOn DATETIME DEFAULT CURRENT_TIMESTAMP,'
      'isFavorite INTEGER DEFAULT 0)',
    );
    log('TABLE CREATED');
  }

  Future<List<MoodModel>> getMood() async {
    final db = await _moodDatabase.database;
    var data = await db.query('Moods');
    return List.generate(
      data.length,
          (index) => MoodModel.fromJson(data[index]),
    );
  }

  Future<void> insertMood(MoodModel mood) async {
    final db = await database;
    var data = await db.rawInsert(
      'INSERT INTO Moods(scale, title, description, isFavorite) VALUES(?,?,?,?)',
      [mood.scale, mood.title, mood.description, mood.isFavorite],
    );
    log('inserted $data');
  }

  Future<void> setAsFavorite(MoodModel mood) async {
    final db = await database;

    String dateOnly = mood.createdOn.substring(0, 10);

    await db.transaction((txn) async {
      await txn.execute(
        "UPDATE Moods SET isFavorite = 0 WHERE createdOn LIKE '$dateOnly%'",
      );
      await txn.update(
        'Moods',
        {'isFavorite': 1},
        where: 'id = ?',
        whereArgs: [mood.id],
      );
    });
    log('Updated favorite for date: $dateOnly');
  }

  Future<void> editMood(MoodModel mood) async {
    final db = await _moodDatabase.database;
    var data = await db.update(
      'Moods',
      mood.toMap(),
      where: 'id=?',
      whereArgs: [mood.id],
    );
    log('updated $data');
  }

  Future<void> deleteMood(int id) async {
    final db = await _moodDatabase.database;
    var data = await db.delete('Moods', where: 'id=?', whereArgs: [id]);
    log('deleted $data');
  }
}
