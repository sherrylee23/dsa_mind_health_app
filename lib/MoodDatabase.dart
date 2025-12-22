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
    log('Local database path: $path');
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
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
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (list_id) REFERENCES todo_list(list_id)
    )
  ''');

    log('TABLES CREATED');
  }

  // Helper method for better error logging
  void _logSupabaseError(String operation, dynamic error, [StackTrace? stackTrace]) {
    log('Supabase $operation failed: $error');
    if (stackTrace != null) {
      log('Stack trace: $stackTrace');
    }
    if (error is PostgrestException) {
      log('Code: ${error.code}');
      log('Message: ${error.message}');
      log('Details: ${error.details}');
      log('Hint: ${error.hint}');
    }
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

      // FIX: Convert database rows (Maps) to objects AFTER the list is created
      // or ensure the JSON factory can handle existing objects.
      final items = itemsData.map((e) => TodoItemModel.fromJson(e)).toList();

      // Create the model manually to avoid the .fromJson type error
      lists.add(TodoListModel(
        list_id: listData['list_id'] as int,
        user_id: listData['user_id'] as int,
        title: listData['title']?.toString() ?? '',
        updated_at: listData['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
        items: items,
      ));
    }
    return lists;
  }

  Future<void> insertList(TodoListModel list) async {
    final db = await database;
    var localId = await db.insert('todo_list', list.toMap());
    log('Local todo_list inserted with ID: $localId');

    try {
      final dataToInsert = {
        'list_id': localId,
        'user_id': list.user_id,
        'title': list.title,
        'updated_at': list.updated_at,
      };
      log('Sending to Supabase: $dataToInsert');

      final response = await Supabase.instance.client
          .from('todo_list')
          .insert(dataToInsert)
          .select()
          .single();

      log('Supabase todo_list insert successful: ${response['list_id']}');
    } catch (e, stackTrace) {
      _logSupabaseError('todo_list insert', e, stackTrace);
    }
  }

  // Inside your MoodDatabase class...

  Future<void> insertFullList(TodoListModel list) async {
    final db = await database;

    // 1. Save the List locally first
    var localListId = await db.insert('todo_list', list.toMap());
    list.list_id = localListId; // Update the object with the new ID

    // 2. IMPORTANT: Sync the List to Supabase FIRST to avoid Foreign Key errors
    try {
      await Supabase.instance.client.from('todo_list').insert({
        'list_id': localListId,
        'user_id': list.user_id,
        'title': list.title,
        'updated_at': list.updated_at,
      });
      log('Supabase list header synced');
    } catch (e) {
      _logSupabaseError('Full list header sync', e);
      // If header fails, items will definitely fail, so we might return here
    }

    // 3. Save items locally and THEN sync to Supabase
    for (var item in list.items) {
      item.list_id = localListId;
      var localItemId = await db.insert('todo_item', item.toMap());

      try {
        await Supabase.instance.client.from('todo_item').insert({
          'item_id': localItemId,
          'list_id': localListId,
          'title': item.title,
          'completed': item.completed,
          'created_at': item.created_at,
        });
      } catch (e) {
        _logSupabaseError('Bulk item sync', e);
      }
    }
  }

  Future<void> editList(TodoListModel list) async {
    final db = await database;
    await db.update('todo_list', list.toMap(), where: 'list_id=?', whereArgs: [list.list_id]);

    try {
      await Supabase.instance.client.from('todo_list').update({
        'user_id': list.user_id,
        'title': list.title,
        'updated_at': list.updated_at,
      }).eq('list_id', list.list_id);
      log('Supabase todo_list update successful');
    } catch (e) {
      _logSupabaseError('todo_list update', e);
    }
  }

  Future<void> deleteList(int id) async {
    final db = await database;
    await db.delete('todo_list', where: 'list_id=?', whereArgs: [id]);

    try {
      await Supabase.instance.client.from('todo_list').delete().eq('list_id', id);
      log('Supabase todo_list delete successful');
    } catch (e) {
      _logSupabaseError('todo_list delete', e);
    }
  }

  Future<void> insertItem(TodoItemModel item) async {
    final db = await database;

    // 1. Validation check
    if (item.list_id <= 0) {
      log('Error: Invalid list_id (${item.list_id}). Cannot save item.');
      return;
    }

    // 2. Local SQLite Insert
    var localId = await db.insert('todo_item', item.toMap());
    log('Local todo_item saved with ID: $localId');

    try {
      // 3. Supabase Insert
      await Supabase.instance.client.from('todo_item').insert({
        'item_id': localId,
        'list_id': item.list_id,
        'title': item.title,
        'completed': item.completed,
        'created_at': item.created_at,
      });
      log('Supabase todo_item sync successful');
    } catch (e) {
      _logSupabaseError('todo_item insert', e);
    }
  }

  Future<void> editItem(TodoItemModel item) async {
    final db = await database;
    await db.update('todo_item', item.toMap(), where: 'item_id = ?', whereArgs: [item.item_id]);

    try {
      await Supabase.instance.client.from('todo_item').update({
        'list_id': item.list_id,
        'title': item.title,
        'completed': item.completed,
        'created_at': item.created_at,
      }).eq('item_id', item.item_id);
      log('Supabase todo_item update successful');
    } catch (e) {
      _logSupabaseError('todo_item update', e);
    }
  }

  // ====== MOOD Database

  Future<void> insertMood(MoodModel mood) async {
    final db = await database;

    var localId = await db.insert('Moods', mood.toMap());
    log('Local mood inserted with ID: $localId');

    try {
      final dataToInsert = {
        'id': localId,
        'userId': mood.userId,
        'scale': mood.scale,
        'title': mood.title,
        'description': mood.description,
        'createdOn': mood.createdOn,
        'isFavorite': mood.isFavorite,
      };
      log('Sending to Supabase MoodModel: $dataToInsert');

      final response = await Supabase.instance.client
          .from('MoodModel')
          .insert(dataToInsert)
          .select()
          .single();

      log('Supabase mood insert successful: ${response['id']}');
    } catch (e, stackTrace) {
      _logSupabaseError('MoodModel insert', e, stackTrace);
    }
  }

  Future<List<MoodModel>> getMood({
    required int userId,
    String sortBy = 'createdOn DESC',
  }) async {
    final db = await database;

    var data = await db.query(
      'Moods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: sortBy,
    );

    log('Retrieved ${data.length} moods from local database');
    return List.generate(
      data.length,
          (index) => MoodModel.fromJson(data[index]),
    );
  }

  Future<void> syncFromSupabase(int userId) async {
    try {
      log('Starting sync from Supabase for userId: $userId');

      final response = await Supabase.instance.client
          .from('MoodModel')
          .select()
          .eq('userId', userId);

      log('Supabase returned ${response.length} moods');

      if (response.isNotEmpty) {
        final db = await database;
        await db.delete('Moods', where: 'userId = ?', whereArgs: [userId]);

        for (var moodData in response) {
          await db.insert('Moods', {
            'id': moodData['id'],
            'userId': moodData['userId'],
            'scale': moodData['scale'],
            'title': moodData['title'],
            'description': moodData['description'],
            'createdOn': moodData['createdOn'],
            'isFavorite': moodData['isFavorite'] == true ? 1 : 0,
          });
        }
        log('Synced ${response.length} moods from Supabase');
      }
    } catch (e, stackTrace) {
      _logSupabaseError('sync', e, stackTrace);
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
      _logSupabaseError('favorite update', e);
    }
  }

  Future<void> editMood(MoodModel mood) async {
    final db = await database;
    await db.update(
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
      log('Supabase mood update successful');
    } catch (e) {
      _logSupabaseError('mood update', e);
    }
  }

  Future<void> deleteMood(int id) async {
    final db = await database;
    await db.delete('Moods', where: 'id=?', whereArgs: [id]);

    try {
      await Supabase.instance.client.from('MoodModel').delete().eq('id', id);
      log('Supabase mood delete successful');
    } catch (e) {
      _logSupabaseError('mood delete', e);
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
    log('Local user registered with ID: $id');

    try {
      await Supabase.instance.client.from('user_model').insert({
        'name': user.name,
        'email': user.email,
        'gender': user.gender,
        'age': user.age,
        'password': user.password,
        'createdOn': user.createdOn,
      });
      log('Supabase user registered successfully');
    } catch (e) {
      _logSupabaseError('user registration', e);
    }
    return id;
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update('Users', user.toMap(), where: 'id=?', whereArgs: [user.id]);
  }

  Future<void> updatePassword(int id, String newPassword) async {
    final db = await database;

    // 1. Update Local SQLite
    await db.update(
      'Users',
      {'password': newPassword},
      where: 'id=?',
      whereArgs: [id],
    );
    log('Local password updated for user ID: $id');

    try {
      // 2. Update Supabase (Optional but recommended if not already handled by Auth)
      // Note: If you use Supabase Auth's 'updateUser', this happens automatically in the cloud,
      // but if you have a custom 'user_model' table, you must update it manually:
      await Supabase.instance.client
          .from('user_model')
          .update({'password': newPassword})
          .eq('id', id);

      log('Supabase user_model password synced');
    } catch (e) {
      _logSupabaseError('password sync', e);
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
    await db.delete('results');

    try {
      await Supabase.instance.client.from('quiz_result').delete().neq('id', 0);
      log('Supabase quiz results cleared');
    } catch (e) {
      _logSupabaseError('quiz clear', e);
    }
  }

  Future<void> insertResult(int userId, String result, int score) async {
    final db = await database;

    var localId = await db.insert('results', {
      'user_id': userId,
      'result': result,
      'score': score,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    log('Local quiz result inserted with ID: $localId');

    try {
      final dataToInsert = {
        'user_id': userId,
        'result': result,
        'score': score,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      log('Sending to Supabase quiz_result: $dataToInsert');

      // 3. Perform Supabase Insert [cite: 134]
      await Supabase.instance.client
          .from('quiz_result')
          .insert(dataToInsert);

      log('Supabase quiz result sync successful');
    } catch (e, stackTrace) {
      _logSupabaseError('quiz_result sync', e, stackTrace);
    }
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await database;
    return await db.query('results', orderBy: 'id DESC');
  }
}