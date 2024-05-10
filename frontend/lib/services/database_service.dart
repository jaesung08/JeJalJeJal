// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import '../databases/database_helper.dart';
import '../models/conversation.dart';
import '../models/text_entry.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // DatabaseHelper 인스턴스 생성
  static final DatabaseService instance = DatabaseService(); // 싱글톤 인스턴스 생성

  // 새로운 대화를 데이터베이스에 삽입하는 메서드
  Future<void> insertConversation(Conversation conversation) async {
    final db = await _databaseHelper.database; // 데이터베이스 인스턴스 가져오기
    await db.insert(
      'conversations', // 테이블 이름
      conversation.toMap(), // Conversation 객체를 Map으로 변환
      conflictAlgorithm: ConflictAlgorithm.replace, // 기존 데이터가 있으면 대체
    );
  }

  // 전체 대화 목록을 가져오는 메서드
  Future<List<Conversation>> getAllConversations() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('conversations');
    return List.generate(maps.length, (i) {
      return Conversation.fromMap(maps[i]); // Map을 Conversation 객체로 변환
    });
  }

  // 새로운 텍스트 엔트리를 데이터베이스에 삽입하는 메서드
  Future<void> insertText(TextEntry textEntry) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'text_entries',
      textEntry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 특정 통화 ID에 대한 텍스트 엔트리 목록을 가져오는 메서드
  Future<List<TextEntry>> getTextsByConversationId(int conversationId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      where: 'conversation_id = ?', // 통화 ID로 필터링
      whereArgs: [conversationId],
    );
    return List.generate(maps.length, (i) {
      return TextEntry.fromMap(maps[i]); // Map을 TextEntry 객체로 변환
    });
  }

  // 특정 통화 ID에 대한 통화 정보를 가져오는 메서드
  Future<Conversation> getConversationById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'id = ?', // ID로 필터링
      whereArgs: [id],
    );
    return Conversation.fromMap(maps.first); // 첫번째 Map을 Conversation 객체로 변환
  }
}