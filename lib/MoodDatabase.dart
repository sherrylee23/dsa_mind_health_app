import 'dart:developer';
import 'package:dsa_mind_health/todo_item.dart';
import 'package:dsa_mind_health/todo_list.dart';
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
    return await openDatabase(path, onCreate: _onCreate, version: 2);
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

    await db.execute('''
    CREATE TABLE todo_list(
      list_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      title TEXT,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    await db.execute('''
    CREATE TABLE todo_item(
      item_id INTEGER PRIMARY KEY AUTOINCREMENT,
      list_id INTEGER,
      title TEXT,
      completed INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    log('TABLES CREATED');
  }

  // ===== TODO LIST DATABASE (LOCAL + SUPABASE) =====

  Future<List<TodoListModel>> getTodoList({required int user_id}) async {
    final db = await database;
    var listsData = await db.query('todo_list',
        where: 'user_id = ?', whereArgs: [user_id],
        orderBy: 'updated_at DESC'
    );

    final lists = <TodoListModel>[];
    for (var listData in listsData) {
      var itemsData = await db.query('todo_item',
          where: 'list_id = ?', whereArgs: [listData['list_id']]
      );
      final items = itemsData.map((e) => TodoItemModel.fromJson(e)).toList();

      lists.add(TodoListModel.fromJson({
        ...listData as Map<String, dynamic>,
        'items': items,
      }));
    }
    return lists;
  }

  Future<void> insertList(TodoListModel list) async {
    final db = await database;

    // Convert model to map
    Map<String, dynamic> listMap = list.toMap();

    // Local SQLite insert
    var localId = await db.insert('todo_list', listMap);
    log('Inserted to local db $localId');

    try {
      // Supabase insert - make sure 'userId' is a column in your Supabase table!
      await Supabase.instance.client.from('todo_list').insert({
        'user_id': list.user_id, // <--- Add this
        'title': list.title,
        'updated_at': list.updated_at.toIso8601String(),
      });
      log('Supabase insert successful');
    } catch (e) {
      log('Supabase insert failed: $e');
    }
  }

  Future<void> editList(TodoListModel list) async {
    final db = await database;
    var data = await db.update(
      'todo_list',
      list.toMap(),
      where: 'list_id=?',
      whereArgs: [list.list_id],
    );

    try {
      await Supabase.instance.client
          .from('todo_list')
          .update({
        'user_id': list.user_id,
        'title': list.title,
        'updated_at': list.updated_at,
      })
          .eq('list_id', list.list_id);
      log('Supabase update successful');
    } catch (e) {
      log('Supabase update unsuccessful $e');
    }
  }

  Future<void> deleteList(int id) async {
    final db = await database;
    await db.delete('todo_list', where: 'list_id=?', whereArgs: [id]);

    try {
      await Supabase.instance.client.from('todo_list').delete().eq('list_id', id);
      log('Supabase delete successful');
    } catch (e) {
      log('Supabase delete unsuccessful $e');
    }
  }

  Future<void> insertItem(TodoItemModel item) async {
    final db = await database;

    await db.insert('todo_item', item.toMap());

    try {
      await Supabase.instance.client.from('todo_item').insert({
        'list_id': item.list_id,
        'title': item.title,
        'completed': item.completed,
        'created_at': item.created_at.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Supabase insertItem failed: $e');
    }
  }

  Future<void> editItem(TodoItemModel item) async {
    final db = await database;

    await db.update(
      'todo_item',
      item.toMap(),
      where: 'item_id = ?',
      whereArgs: [item.item_id],
    );

    try {
      await Supabase.instance.client
          .from('todo_item')
          .update({
        'list_id': item.list_id,
        'title': item.title,
        'completed': item.completed,
        'created_at': item.created_at.toIso8601String(),
      })
          .eq('item_id', item.item_id);
    } catch (e) {
      debugPrint('Supabase editItem failed: $e');
    }
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
      final res = await Supabase.instance.client
          .from('user_model')
          .insert({
        'name': user.name,
        'email': user.email,
        'gender': user.gender,
        'age': user.age,
        'password': user.password,
        'createdOn': DateTime.now().toIso8601String(),
      })
          .select();

      log('>>> Supabase user_model insert result: $res');
    } on PostgrestException catch (e) {
      log('>>> Supabase PostgrestException: ${e.message} details=${e.details}');
    } catch (e) {
      log('>>> Supabase unknown error: $e');
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

     await _deleteFromSupabase(userId);

    } catch (e) {
      log(' Delete error: $e');
      rethrow;
    }
  }

  Future<void> _deleteFromSupabase(int userId) async {
    try {
      // 先查本地拿 email
      final user = await getUserById(userId);
      if (user == null) {
        log('Supabase delete skipped: local user not found');
        return;
      }

      await Supabase.instance.client
          .from('user_model')
          .delete()
          .eq('email', user.email);
      log('Supabase user_model deleted for email=${user.email}');

      await Supabase.instance.client
          .from('MoodModel')
          .delete()
          .eq('userId', userId);
      log('Supabase MoodModel deleted for userId=$userId');

      await Supabase.instance.client
          .from('quiz_result')
          .delete()
          .eq('user_id', userId);
      log('Supabase quiz_result deleted for userId=$userId');
    } catch (e) {
      log('Supabase delete failed: $e');
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

  Future<List<Map<String, dynamic>>> getQuizResultsForUser(int userId) async {
    final db = await database;

    return await db.rawQuery('''
    SELECT 
      r.id,
      r.result,
      r.score,
      r.created_at
    FROM results r
    WHERE r.user_id = ?
    ORDER BY r.created_at DESC
  ''', [userId]);
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