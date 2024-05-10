// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:jejal_project/screens/history_chat_screen.dart';
import 'package:jejal_project/databases/database_helper.dart' as db;
import 'package:jejal_project/models/conversation.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:intl/intl.dart';// 날짜 포맷팅을 위한 패키지

class HistoryScreen extends StatelessWidget {
  final TranslationService translationService;

  const HistoryScreen({Key? key, required this.translationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '통화 번역 기록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Conversation>>( // 대화 목록을 가져오는 FutureBuilder
        future: DatabaseService.instance.getAllConversations().catchError((error) {
          print('fetching conversations 에러: $error');
          return <Conversation>[]; // 에러 발생 시 빈 리스트 반환
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final conversations = snapshot.data!;
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return Column(
                  children: [
                    ListTile(
                      leading: Container( // 아이콘 컨테이너
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE4E1),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/common_mandarin.png',
                          width: 37,
                          height: 37,
                        ),
                      ),
                      title: Column( // 전화번호와 날짜 표시
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.phoneNumber,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
                      onTap: () async { // ListTile 탭 시 실행될 코드
                        await translationService.insertDummyData(); // 더미 데이터 삽입
                        final texts = await translationService.getTextsByConversationId(conversation.id!);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HistoryChatScreen(
                              conversationId: conversation.id!,
                              texts: texts,
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(color: Colors.orange), // 구분선
                  ],
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator()); // 로딩 중 표시
          }
        },
      ),
    );
  }
}