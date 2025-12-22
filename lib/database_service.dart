/*import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'quiz.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE results(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          result TEXT,
          score INTEGER,
          created_at TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertResult(String result, int score) async {
    final db = await database;
    await db.insert('results', {
      'result': result,
      'score': score,
      'created_at': DateTime.now().toIso8601String(),
    });

  }

  Future<void> clearResults() async {
    final db = await database;
    await db.delete('results');
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await database;
    return await db.query('results', orderBy: 'id DESC');
  }
}*/
