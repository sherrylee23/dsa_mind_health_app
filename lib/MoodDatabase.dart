import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:dsa_mind_health/MoodModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'zq_user_management/models/user_model.dart';
import 'package:intl/intl.dart';


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
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'mind_health_app.db');
    log('Local db path $path');
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE Moods('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'userId INTEGER,'
          'scale INTEGER,'
          'title TEXT,'
          'description TEXT,'
          'createdOn DATETIME DEFAULT CURRENT_TIMESTAMP,'
          'isFavorite INTEGER DEFAULT 0)',
    );
    await db.execute('''
        CREATE TABLE Users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        gender TEXT,
        age INTEGER,
        password TEXT NOT NULL,
        createdOn TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''');

    await db.execute('''
    CREATE TABLE results(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      result TEXT,
      score INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES Users(id)
      )
      ''');
    log('TABLES CREATED');
  }

  // ====== MOOD Database

  Future<void> insertMood(MoodModel mood) async {
    final db = await database;

    // Convert model to map
    Map<String, dynamic> moodMap = mood.toMap();

    // Local SQLite insert
    var localId = await db.insert('Moods', moodMap);
    log('Inserted to local db $localId');

    try {
      // Supabase insert - make sure 'userId' is a column in your Supabase table!
      await Supabase.instance.client.from('MoodModel').insert({
        'userId': mood.userId,
        'scale': mood.scale,
        'title': mood.title,
        'description': mood.description,
        'createdOn': mood.createdOn,
        'isFavorite': mood.isFavorite,
      });
      log('Supabase insert successful');
    } catch (e) {
      log('Supabase insert failed: $e');
    }
  }

  Future<List<MoodModel>> getMood({
    required int userId,
    String sortBy = 'createdOn DESC',
  }) async {
    final db = await database;

    // Filter where userId matches
    var data = await db.query(
      'Moods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: sortBy,
    );

    return List.generate(
      data.length,
          (index) => MoodModel.fromJson(data[index]),
    );
  }

  // Add 'int userId' as a parameter here
  Future<void> syncFromSupabase(int userId) async {
    try {
      // Now 'userId' is defined and can be used to filter Supabase data
      final response = await Supabase.instance.client
          .from('MoodModel')
          .select()
          .eq('userId', userId);

      final db = await database;

      // Use the parameter to only delete local data for THIS specific user
      await db.delete(
        'Moods',
        where: 'userId = ?',
        whereArgs: [userId],
      ); // [cite: 18]

      for (var moodData in response) {
        await db.insert('Moods', {
          'id': moodData['id'],
          'userId': moodData['userId'], // Ensure userId is saved locally too
          'scale': moodData['scale'],
          'title': moodData['title'],
          'description': moodData['description'],
          'createdOn': moodData['createdOn'],
          'isFavorite': moodData['isFavorite'] is bool
              ? (moodData['isFavorite'] ? 1 : 0)
              : moodData['isFavorite'],
        });
      }
      log('Synced ${response.length} moods from Supabase');
    } catch (e) {
      log('Supabase sync unsuccessful $e');
    }
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

    try {
      await Supabase.instance.client
          .from('MoodModel')
          .update({'isFavorite': 0})
          .like('createdOn', '$dateOnly%');
      await Supabase.instance.client
          .from('MoodModel')
          .update({'isFavorite': 1})
          .eq('id', mood.id);
      log('Supabase favorite update successful');
    } catch (e) {
      log('Supabase favorite update unsuccessful $e');
    }
  }

  Future<void> editMood(MoodModel mood) async {
    final db = await database;
    var data = await db.update(
      'Moods',
      mood.toMap(),
      where: 'id=?',
      whereArgs: [mood.id],
    );

    try {
      await Supabase.instance.client
          .from('MoodModel')
          .update({
        'scale': mood.scale,
        'title': mood.title,
        'description': mood.description,
        'isFavorite': mood.isFavorite,
      })
          .eq('id', mood.id);
      log('Supabase update successful');
    } catch (e) {
      log('Supabase update unsuccessful $e');
    }
  }

  Future<void> deleteMood(int id) async {
    final db = await database;
    await db.delete('Moods', where: 'id=?', whereArgs: [id]);

    try {
      await Supabase.instance.client.from('MoodModel').delete().eq('id', id);
      log('Supabase delete successful');
    } catch (e) {
      log('Supabase delete unsuccessful $e');
    }
  }

  // ===== USER Database

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final data = await db.query('Users', where: 'id=?', whereArgs: [id]);
    if (data.isEmpty) return null;
    return UserModel.fromJson(data.first);
  }



  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final data = await db.query('Users', where: 'email=?', whereArgs: [email]);
    if (data.isEmpty) return null;
    return UserModel.fromJson(data.first);
  }

  Future<int> registerUser(UserModel user) async {
    final db = await database;
    int id = await db.insert('Users', user.toMapForInsert());

    try {
      await Supabase.instance.client.from('user_model').insert({
        'name': user.name,
        'email': user.email,
        'gender': user.gender,
        'age': user.age,
        'password': user.password,
        'createdOn': DateTime.now().toIso8601String(),
      });
      log('Supabase successful');
    } catch (e) {
      log('Supabase error $e');
    }
    return id;
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update('Users', user.toMap(), where: 'id=?', whereArgs: [user.id]);
  }

  Future<void> updatePassword(int id, String newPassword) async {
    final db = await database;
    await db.update(
      'Users',
      {'password': newPassword},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUser(int userId) async {
    try {
      final db = await database;

      // Delete in transaction with timeout
      await db.transaction((txn) async {
        await txn.delete('results', where: 'user_id = ?', whereArgs: [userId]);
        await txn.delete('Moods', where: 'userId = ?', whereArgs: [userId]);
        await txn.delete('Users', where: 'id = ?', whereArgs: [userId]);
      });

      log('Local delete complete');

      _deleteFromSupabase(userId);

    } catch (e) {
      log(' Delete error: $e');
      rethrow;
    }
  }

  Future<void> _deleteFromSupabase(int userId) async {
    try {
      await Supabase.instance.client
          .from('user_model')
          .delete()
          .eq('id', userId);
    } catch (e) {
      log('Supabase delete failed (non-blocking): $e');
    }
  }


  // ===== QUIZ DATABASE =====

  Future<List<Map<String, dynamic>>> getQuizResultsWithUser() async {
    final db = await database;

    return await db.rawQuery('''
    SELECT 
      r.id,
      r.result,
      r.score,
      r.created_at,
      u.name AS username
    FROM results r
    JOIN Users u ON r.user_id = u.id
    ORDER BY r.id DESC
  ''');
  }


  Future<void> clearResults() async {
    final db = await database;

    // Clear all local results
    await db.delete('results');

    // Clear all Supabase results
    try {
      await Supabase.instance.client.from('quiz_result').delete().neq('id', 0);
      log('Supabase quiz results cleared');
    } catch (e) {
      log('Supabase clear failed: $e');
    }
  }

  Future<void> insertResult(int userId, String result, int score) async {
    final db = await database;
    // Local SQLite insert
    await db.insert('results', {
      'user_id': userId,
      'result': result,
      'score': score,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    // Supabase insert
    try {
      await Supabase.instance.client.from('quiz_result').insert({
        'user_id': userId,
        'result': result,
        'score': score,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      log('Supabase quiz result inserted');
    } catch (e) {
      log('Supabase insert failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await database;
    return await db.query('results', orderBy: 'id DESC');
  }
}