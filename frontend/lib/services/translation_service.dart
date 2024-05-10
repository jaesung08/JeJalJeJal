// lib/services/translation_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/database_service.dart';
import '../models/conversation.dart';
import '../models/text_entry.dart';

class TranslationService {
  final DatabaseService _databaseService = DatabaseService();
  final _outputStreamController = StreamController<TranslateResponseDto>.broadcast();
  Stream<TranslateResponseDto> get outputStream => _outputStreamController.stream;
  int _conversationId = 0;
  WebSocketChannel? _webSocketChannel;

  Future<void> insertDummyData() async {
    final conversation = Conversation(
      phoneNumber: '010-9475-3425',
      name: 'John Doe',
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()), // YYYY-MM-DD 형식으로 변환
    );

    await _databaseService.insertConversation(conversation);

    final conversations = await _databaseService.getAllConversations();
    _conversationId = conversations.last.id!;

    final dummyData = [
      TextEntry(
        conversationId: _conversationId,
        jejuText: '제주어 텍스트 1',
        translatedText: '번역된 텍스트 1',
        timestamp: DateFormat('HH:mm').format(DateTime.now()), // 'HH:mm' 형식으로 변환
      ),
      TextEntry(
        conversationId: _conversationId,
        jejuText: '제주어 텍스트 2',
        translatedText: '번역된 텍스트 2',
        timestamp: DateFormat('HH:mm').format(DateTime.now()), // 'HH:mm' 형식으로 변환
      ),
      TextEntry(
        conversationId: _conversationId,
        jejuText: '제주어 텍스트 3',
        translatedText: '번역된 텍스트 3',
        timestamp: DateFormat('HH:mm').format(DateTime.now()), // 'HH:mm' 형식으로 변환
      ),
    ];

    for (final data in dummyData) {
      await _databaseService.insertText(data);
    }
  }

  Future<List<TextEntry>> getTextsByConversationId(int conversationId) async {
    return await _databaseService.getTextsByConversationId(conversationId);
  }

  Future<List<Conversation>> getConversationList() async {
    return await _databaseService.getAllConversations();
  }

  Future<void> saveTranslation(TranslateResponseDto translation) async {
    final textEntry = TextEntry(
      conversationId: _conversationId,
      jejuText: translation.jeju,
      translatedText: translation.translated,
      timestamp: DateFormat('HH:mm').format(DateTime.now()), // 'HH:mm' 형식으로 변환
    );
    await _databaseService.insertText(textEntry);
  }

  void startWebSocketStream() {
    // _webSocketChannel = WebSocketChannel.connect(
    //   Uri.parse('wss://k10a406.p.ssafy.io/api/record'),
    // );

    _webSocketChannel?.stream.listen((message) {
      if (message is String) {
        final jsonData = jsonDecode(message);
        if(jsonData['isCallFinish'] == true) {
          stopWebSocketStream();
        } else {
          final translation = TranslateResponseDto.fromJson(jsonDecode(message));
          _outputStreamController.add(translation);
          saveTranslation(translation);
        }
      }
    });
  }

  void stopWebSocketStream() {
    _webSocketChannel?.sink.close();
    _outputStreamController.close();
  }
}

class TranslateResponseDto {
  final String jeju;
  final String translated;

  TranslateResponseDto({required this.jeju, required this.translated});

  factory TranslateResponseDto.fromJson(Map<String, dynamic> json) {
    return TranslateResponseDto(
      jeju: json['jeju'],
      translated: json['translated'],
    );
  }
}