import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jejal_project/databases/database.dart';

class TranslationService {
  final WebSocketChannel _channel;
  final JejalDatabase _database;
  int _conversationId = 0;

  TranslationService(this._channel, this._database);

  // 웹소켓으로부터 받은 번역 데이터를 TranslateResponseDto 객체로 변환하는 스트림(원시 데이터 -> 적절한 모델 객체 로 변환)
  Stream<TranslateResponseDto> get outputStream => _channel.stream
      .map((event) => TranslateResponseDto.fromJson(json.decode(event)));

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

  // // 다른 위젯에서 사용할 수 있는 메서드
  // Widget buildConversationView(int conversationId) {
  //   return FutureBuilder<List<db.TextEntry>>(
  //     future: getTextsByConversationId(conversationId),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         final texts = snapshot.data!;
  //         return ListView.builder(
  //           itemCount: texts.length,
  //           itemBuilder: (context, index) {
  //             final text = texts[index];
  //             return ChatBubble(
  //               jejuText: text.jejuText,
  //               translatedText: text.translatedText,
  //               isMyMessage: index % 2 == 0, // 간단한 예시, 실제로는 적절한 로직 구현 필요
  //             );
  //           },
  //         );
  //       } else if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       } else {
  //         return CircularProgressIndicator();
  //       }
  //     },
  //   );
  // }


  // 최근 통화 기록 목록을 모두 가져옴
  Future<List<Conversation>> getConversationList() async {
    return await _database.getAllConversations();
  }

  // // 최근 통화 기록 목록을 모두 가져오는 메서드(다른 클래스에서 사용)
  // Widget buildConversationList() {
  //   return FutureBuilder<List<Conversation>>(
  //     future: getConversationList(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         final conversations = snapshot.data!;
  //         return ListView.builder(
  //           itemCount: conversations.length,
  //           itemBuilder: (context, index) {
  //             final conversation = conversations[index];
  //             return ListTile(
  //               title: Text(conversation.name),
  //               subtitle: Text('${conversation.phoneNumber}\n${conversation.date.toString()}'),
  //               onTap: () {
  //                 // 채팅 형식 보여주는 화면으로 이동
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => ChatView(conversationId: conversation.id),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         );
  //       } else if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       } else {
  //         return CircularProgressIndicator();
  //       }
  //     },
  //   );
  // }


  // 실시간으로 받아오는 제주어 텍스트와 번역된 텍스트를 데이터베이스에 저장
  Future<void> saveTranslation(TranslateResponseDto translation) async {
    try {
      await _database.insertText(
        TextEntriesCompanion.insert(
          conversationId: _conversationId,
          jejuText: translation.jeju,
          translatedText: translation.translated,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('저장 실패: $e');
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
