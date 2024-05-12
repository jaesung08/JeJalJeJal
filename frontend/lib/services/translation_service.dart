// // lib/services/translation_service.dart
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../services/database_service.dart';
// import '../models/conversation.dart';
// import '../models/receive_message_model.dart';
//
// class TranslationService {
//   final DatabaseService _databaseService =
//   DatabaseService(); // DatabaseService 인스턴스 가져오기
//
//   int _conversationId = 0; // 현재 통화 ID를 저장할 변수
//
//   // 더미데이터 삽입하는 메서드
//   Future<void> insertDummyData() async {
//     final conversation = Conversation(
//       phoneNumber: '010-9475-3425',
//       name: 'John Doe',
//       date:
//       DateFormat('yyyy-MM-dd').format(DateTime.now()), // YYYY-MM-DD 형식으로 변환
//     );
//
//     await _databaseService.insertConversation(conversation); // 새로운 통화 삽입
//
//     final conversations =
//     await _databaseService.getAllConversations(); // 전체 통화 목록 가져오기
//     _conversationId = conversations.last.id!; // 가장 최근 통화 ID 저장
//
//     final dummyData = [
//       ReceiveMessageModel(
//         conversationId: _conversationId,
//         jeju: '제주어 텍스트 1',
//         translated: '번역된 텍스트 1',
//         timestamp: DateFormat('HH:mm').format(DateTime.now()),
//       ),
//       ReceiveMessageModel(
//         conversationId: _conversationId,
//         jeju: '표준어 텍스트2', // "제잘"로 설정하여 제주어만 표시되도록 함
//         translated: '제잘',
//         timestamp: DateFormat('HH:mm').format(DateTime.now()),
//       ),
//       ReceiveMessageModel(
//         conversationId: _conversationId,
//         jeju: '제주어 텍스트 3',
//         translated: '번역된 텍스트 3',
//         timestamp: DateFormat('HH:mm').format(DateTime.now()),
//       ),
//     ];
//
//     for (final data in dummyData) {
//       await _databaseService.insertMessage(data);
//     }
//   }
//
//   // 특정 통화 ID에 대한 메시지 목록을 가져오는 메서드
//   Future<List<ReceiveMessageModel>> getMessagesByConversationId(int conversationId) async {
//     return await _databaseService.getMessagesByConversationId(conversationId);
//   }
//
//   // 전체 통화 목록을 가져오는 메서드
//   Future<List<Conversation>> getConversationList() async {
//     return await _databaseService.getAllConversations();
//   }
//
//   // 번역 결과를 저장하는 메서드
//   // DB에 저장
//   // import set_stream 해서 phoneNumber와 name을 가져와서 DB 칼럼에 추가해야 함
//   Future<void> saveTranslation() async {
//     final message = ReceiveMessageModel(
//       conversationId: _conversationId, // 통화 ID
//       jeju: translation.jeju,
//       translated: translation.translated,
//       timestamp: DateFormat('HH:mm').format(DateTime.now()), // 'HH:mm' 형식으로 변환
//     );
//     await _databaseService.insertMessage(message); // 메시지 저장
//   }
// }