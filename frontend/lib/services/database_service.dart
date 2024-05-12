// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../databases/database_helper.dart';
import '../models/conversation.dart';
import '../models/receive_message_model.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // DatabaseHelper 인스턴스 생성
  static final DatabaseService instance = DatabaseService(); // 싱글톤 인스턴스 생성

  // 새로운 대화를 데이터베이스에 삽입하는 메서드
  Future<int> insertConversation(String phoneNumber, String name) async {
    print('57');

    final db = await _databaseHelper.database; // 데이터베이스 인스턴스 가져오기
    return await db.insert(
      'conversations', // 테이블 이름
      {
        'phone_number': phoneNumber,
        'name': name,
        'date': DateTime.now().toString(),
      }
    );
  }

  // 전체 대화 목록을 가져오는 메서드
  Future<List<Conversation>> getAllConversations() async {
    print('58');

    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('conversations');
    return List.generate(maps.length, (i) {
      print('59');

      return Conversation.fromMap(maps[i]); // Map을 Conversation 객체로 변환
    });
  }

  // 특정 통화 ID에 대한 메시지 목록을 가져오는 메서드
  Future<List<ReceiveMessageModel>> getMessagesByConversationId(int conversationId) async {
    print('60');

    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ?', // 통화 ID로 필터링
      whereArgs: [conversationId],
    );
    return List.generate(maps.length, (i) {
      print('61');

      return ReceiveMessageModel.fromMap(maps[i]); // Map을 ReceiveMessageModel 객체로 변환
    });
  }

  // 특정 통화 ID에 대한 통화 정보를 가져오는 메서드
  Future<Conversation> getConversationById(int id) async {
    print('62');

    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'id = ?', // ID로 필터링
      whereArgs: [id],
    );
    return Conversation.fromMap(maps.first); // 첫번째 Map을 Conversation 객체로 변환
  }

  // 새로운 메시지를 데이터베이스에 삽입하는 메서드
  Future<void> insertMessage(ReceiveMessageModel message, int conversationId) async {
    print('63');

    final db = await _databaseHelper.database;
    print('64');

    message.conversationId = conversationId;
    print('65');

    message.timestamp = DateFormat('HH:mm').format(DateTime.now());
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}