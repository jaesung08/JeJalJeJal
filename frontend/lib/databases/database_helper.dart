import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 싱글톤 인스턴스 생성
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database; // 데이터베이스 인스턴스 변수
  DatabaseHelper._internal();

  // 데이터베이스 인스턴스를 반환하는 게터
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase(); // 데이터베이스가 없으면 초기화
    print('1');
    return _database!;
  }

  // 데이터베이스를 초기화하는 메서드
  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath(); // 데이터베이스 경로 가져오기
    final databasePath = join(path, 'jejal_database.db'); // 데이터베이스 파일 경로 및 생성

    print('2');
    return await openDatabase(
      databasePath,
      version: 2, // 데이터베이스 버전
      onCreate: _onCreate, // 데이터베이스 생성 시 실행될 함수
      onUpgrade: _onUpgrade,
    );
  }

  // 데이터베이스 생성 시 실행될 함수
  Future<void> _onCreate(Database db, int version) async {
    print('3');
    await db.execute('''
      CREATE TABLE conversations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT,
        name TEXT,
        date TEXT
      )
    '''); // conversations 테이블 생성

    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER,
        jeju_text TEXT,
        translated_text TEXT,
        timestamp TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id)
      )
    '''); // text_entries 테이블 생성
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      print('4');

      // 버전이 1에서 2로 변경될 때 실행될 코드
      await db.execute('''
      CREATE TABLE messages(
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
}