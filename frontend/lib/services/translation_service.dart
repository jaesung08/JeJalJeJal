import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jejal_project/databases/database.dart';

class TranslationService {
  final WebSocketChannel _channel;
  final JejalDatabase _database;

  TranslationService(this._channel, this._database);

  // 웹소켓으로부터 받은 번역 데이터를 TranslateResponseDto 객체로 변환하는 스트림
  Stream<TranslateResponseDto> get translationStream => _channel.stream
      .map((event) => TranslateResponseDto.fromJson(json.decode(event)));

  // 번역 데이터를 데이터베이스에 저장하는 메서드
  Future<void> saveTranslation(TranslateResponseDto translation, int conversationId) async {
    try {
      // 제주 방언 텍스트를 JejuTexts 테이블에 삽입
      await _database.insertJejuText(
        JejuTextsCompanion.insert(
          conversationId: conversationId,
          jejuText: translation.jeju,
          timestamp: DateTime.now(),
        ),
      );

      // 표준어 텍스트를 TranslatedTexts 테이블에 삽입
      await _database.insertTranslatedText(
        TranslatedTextsCompanion.insert(
          conversationId: conversationId,
          translatedText: translation.translated,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('saving translation to database 에러: $e');
    }
  }
}

// 번역 데이터를 나타내는 DTO 클래스
class TranslateResponseDto {
  final String jeju;
  final String translated;

  TranslateResponseDto({required this.jeju, required this.translated});

  // JSON 데이터를 TranslateResponseDto 객체로 변환하는 팩토리 생성자
  factory TranslateResponseDto.fromJson(Map<String, dynamic> json) {
    return TranslateResponseDto(
      jeju: json['jeju'],
      translated: json['translated'],
    );
  }
}