// lib/services/translation_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jejal_project/services/set_stream.dart';
import '../services/database_service.dart';
import '../models/conversation.dart';
import '../models/text_entry.dart';

class TranslationService {
  final DatabaseService _databaseService =
      DatabaseService(); // DatabaseService 인스턴스 가져오기

  // // 번역 결과를 출력하기 위한 컨트롤러와 스트림 생성
  // final _outputStreamController =
  //     StreamController<TranslateResponseDto>.broadcast();

  // Stream<TranslateResponseDto> get outputStream =>
  //     _outputStreamController.stream;

  int _conversationId = 0; // 현재 통화 ID를 저장할 변수
  // WebSocketChannel? _webSocketChannel;

  // String? jejuText;
  // String? translatedText;

  // 더미데이터 삽입하는 메서드
  Future<void> insertDummyData() async {
    final conversation = Conversation(
      phoneNumber: '010-9475-3425',
      name: 'John Doe',
      date:
          DateFormat('yyyy-MM-dd').format(DateTime.now()), // YYYY-MM-DD 형식으로 변환
    );

    await _databaseService.insertConversation(conversation); // 새로운 통화 삽입

    final conversations =
        await _databaseService.getAllConversations(); // 전체 통화 목록 가져오기
    _conversationId = conversations.last.id!; // 가장 최근 통화 ID 저장

    final dummyData = [
      TextEntry(
        conversationId: _conversationId,
        jejuText: '제주어 텍스트 1',
        translatedText: '번역된 텍스트 1',
        timestamp: DateFormat('HH:mm').format(DateTime.now()),
      ),
      TextEntry(
        conversationId: _conversationId,
        jejuText: '표준어 텍스트2', // "제잘"로 설정하여 제주어만 표시되도록 함
        translatedText: '제잘',
        timestamp: DateFormat('HH:mm').format(DateTime.now()),
      ),
      TextEntry(
        conversationId: _conversationId,
        jejuText: '제주어 텍스트 3',
        translatedText: '번역된 텍스트 3',
        timestamp: DateFormat('HH:mm').format(DateTime.now()),
      ),
    ];

    for (final data in dummyData) {
      await _databaseService.insertText(data);
    }
  }

  // 특정 통화 ID에 대한 텍스트 엔트리 목록을 가져오는 메서드
  Future<List<TextEntry>> getTextsByConversationId(int conversationId) async {
    return await _databaseService.getTextsByConversationId(conversationId);
  }

  // 전체 통화 목록을 가져오는 메서드
  Future<List<Conversation>> getConversationList() async {
    return await _databaseService.getAllConversations();
  }

  // 번역 결과를 저장하는 메서드
  Future<void> saveTranslation(TranslateResponseDto translation) async {
    print('데이터베이스에 저장 성공!');
    final textEntry = TextEntry(
      conversationId: _conversationId,
      jejuText: translation.jeju,
      translatedText: translation.translated,
      timestamp: DateFormat('HH:mm').format(DateTime.now()),
    );
    await _databaseService.insertText(textEntry);
  }
}

class TranslateResponseDto {
  final String jeju;
  final String translated;

  TranslateResponseDto({required this.jeju, required this.translated});
}
