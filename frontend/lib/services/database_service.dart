// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import '../databases/database_helper.dart';
import '../models/conversation.dart';
import '../models/text_entry.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static final DatabaseService instance = DatabaseService();

  Future<void> insertConversation(Conversation conversation) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Conversation>> getAllConversations() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('conversations');
    return List.generate(maps.length, (i) {
      return Conversation.fromMap(maps[i]);
    });
  }

  Future<void> insertText(TextEntry textEntry) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'text_entries',
      textEntry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TextEntry>> getTextsByConversationId(int conversationId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'text_entries',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
    return List.generate(maps.length, (i) {
      return TextEntry.fromMap(maps[i]);
    });
  }

  Future<Conversation> getConversationById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Conversation.fromMap(maps.first);
  }
}