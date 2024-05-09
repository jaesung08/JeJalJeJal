import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jejal_project/databases/database.dart';
import 'package:flutter/foundation.dart';

class TranslationService {
  final JejalDatabase _database;
  final WebSocketChannel _channel;
  int _conversationId = 0;

  // StreamController를 사용하여 번역 데이터를 스트림으로 내보냄
  final _outputStreamController = StreamController<TranslateResponseDto>.broadcast();
  Stream<TranslateResponseDto> get outputStream => _outputStreamController.stream;

  TranslationService(this._database, WebSocketChannel channel)
      : _channel = channel {
    // 웹소켓 채널에서 들어오는 데이터를 listen하고 TranslateResponseDto로 변환하여 스트림에 추가
    _channel.stream.listen(
          (event) {
            // 웹소켓 통신으로 실시간으로 JSON 데이터 받아오는 부분
        final translation = TranslateResponseDto.fromJson(json.decode(event));
        _outputStreamController.sink.add(translation);
      },
      onError: (error) {
        print('웹소켓 에러: $error');
        _outputStreamController.sink.addError(error);
      },
      onDone: () {
        _outputStreamController.sink.close();
      },
    );
  }

  // 통화 시작 시 호출되어 새로운 Conversation 레코드를 생성하고 conversationId를 저장
  Future<void> startConversation() async {
    final conversation = ConversationsCompanion(
      phoneNumber: const Value('010-1234-5678'),
      name: const Value('John Doe'),
      date: Value(DateTime.now()),
    );

    _conversationId = await _database.insertConversation(conversation);
  }

  // 한 통화 목록에 대한 대화 내용을 가져옴
  Future<List<TextEntry>> getTextsByConversationId(int conversationId) async {
    return await _database.getTextsByConversationId(conversationId);
  }

  // 최근 통화 기록 목록을 모두 가져옴
  Future<List<Conversation>> getConversationList() async {
    return await _database.getAllConversations();
  }

  // 실시간으로 받아오는 제주어 텍스트와 번역된 텍스트를 데이터베이스에 저장
  Future<void> saveTranslation(TranslateResponseDto translation) async {
    await compute(_saveTranslationInBackground, {
      'translation': translation,
      'database': _database,
      'conversationId': _conversationId,
    });
  }

  // 백그라운드 작업자에서 실행될 데이터베이스 저장 함수
  Future<void> _saveTranslationInBackground(Map<String, dynamic> data) async {
    final translation = data['translation'] as TranslateResponseDto;
    final database = data['database'] as JejalDatabase;
    final conversationId = data['conversationId'] as int;

    try {
      await database.insertText(
        TextEntriesCompanion.insert(
          conversationId: conversationId,
          jejuText: translation.jeju,
          translatedText: translation.translated,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('저장 실패: $e');
    }
  }


  void dispose() {
    _outputStreamController.close();
    _channel.sink.close();
  }
}

// 번역 데이터를 나타내는 DTO 클래스
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