import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'jejal_database.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT,
        name TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE text_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER,
        jeju_text TEXT,
        translated_text TEXT,
        timestamp TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id)
      )
    ''');
  }
}