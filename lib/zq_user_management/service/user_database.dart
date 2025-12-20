/*import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';  // ← ADD THIS
import '../models/user_model.dart';

class UserDatabaseService {
  static final UserDatabaseService _instance = UserDatabaseService._internal();
  factory UserDatabaseService() => _instance;
  UserDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // FIXED: Use documents directory (persistent)
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'users.db');  // FIXED: Use path.join()
    log('Database path: $path');

    return await openDatabase(
      path,
      version: 2,  // Bump version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,  // Delete old broken DB
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
    log('USERS TABLE CREATED');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS Users');
      await _onCreate(db, 2);
    }
  }

  // FIXED: Use 'database' not '_instance.database'
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

// Register new user
  Future<int> registerUser(UserModel user) async {
    final db = await database;
    return await db.insert('Users', user.toMapForInsert());
  }


  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'Users',
      user.toMap(),       // includes id
      where: 'id=?',
      whereArgs: [user.id],
    );
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
}*/
