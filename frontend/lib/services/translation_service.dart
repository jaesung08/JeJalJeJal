// lib/services/translation_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/database_service.dart';
import '../models/conversation.dart';
import '../models/text_entry.dart';

class TranslationService {
  final DatabaseService _databaseService =
      DatabaseService(); // DatabaseService 인스턴스 가져오기

  // 번역 결과를 출력하기 위한 컨트롤러와 스트림 생성
  final _outputStreamController =
      StreamController<TranslateResponseDto>.broadcast();

  Stream<TranslateResponseDto> get outputStream =>
      _outputStreamController.stream;

  int _conversationId = 0; // 현재 통화 ID를 저장할 변수
  WebSocketChannel? _webSocketChannel; // 웹소켓 채널

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
  // DB에 저장
  // import set_stream 해서 phoneNumber와 name을 가져와서 DB 칼럼에 추가해야 함
  Future<void> saveTranslation(TranslateResponseDto translation) async {
    final textEntry = TextEntry(
      conversationId: _conversationId, // 통화 ID
      jejuText: translation.jeju,
      translatedText: translation.translated,
      timestamp: DateFormat('HH:mm').format(DateTime.now()), // 'HH:mm' 형식으로 변환
    );
    await _databaseService.insertText(textEntry); // 텍스트 엔트리 저장
  }

  // 웹소켓 스트림을 시작하는 메서드
  void startWebSocketStream(WebSocketChannel wss) {
    _webSocketChannel = wss; // set_stream.dart에서 열린 웹소켓 채널을 전달받음

    // 웹소켓 메시지 수신 시 처리할 작업
    _webSocketChannel?.stream.listen((message) {
      if (message is String) {
        final jsonData = jsonDecode(message); // JSON 데이터 디코딩
        if (jsonData['isCallFinish'] == true) {
          // 통화 종료 여부 확인
          stopWebSocketStream(); // 통화 종료 시 웹소켓 스트림 중지
        } else {
          try {
          // 번역 결과 객체 생성
          final translation =
              TranslateResponseDto.fromJson(jsonDecode(message));
          _outputStreamController.add(translation); // 번역 결과 스트림에 추가
          saveTranslation(translation); // 번역 결과 저장
        } catch (e) {
            // JSON 데이터 파싱 오류 처리
            print('JSON 데이터 파싱 오류: $e');
          }
      }
      } else {
        // 예상치 못한 데이터 타입 처리
        print('예상치 못한 데이터 타입: ${message.runtimeType}');
      }
    },
      onError: (error) {
        // 웹소켓 스트림 오류 처리
        print('웹소켓 스트림 오류: $error');
      },
      onDone: () {
        // 웹소켓 스트림 종료 처리
        print('웹소켓 스트림 종료');
      },
    );
  }

  // 웹소켓 스트림을 중지하는 메서드
  void stopWebSocketStream() {
    _webSocketChannel?.sink.close(); // 웹소켓 채널 닫기
    _outputStreamController.close(); // 스트림 컨트롤러 닫기
  }
}

// 번역 결과를 저장하기 위한 데이터 모델
class TranslateResponseDto {
  final String jeju; // 제주어 텍스트
  final String translated; // 번역된 텍스트

  TranslateResponseDto({required this.jeju, required this.translated});

  // JSON 데이터에서 객체 생성
  factory TranslateResponseDto.fromJson(Map<String, dynamic> json) {
    return TranslateResponseDto(
      jeju: json['jeju'],
      translated: json['translated'],
    );
  }
}
