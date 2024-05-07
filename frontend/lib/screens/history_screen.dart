// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:jejal_project/screens/history_chat_screen.dart';
import 'history_chat_screen.dart';

class Chat {
  final String name;
  final String message;
  final String time;

  Chat(this.name, this.message, this.time);
}

class HistoryScreen extends StatelessWidget {
  final List<Chat> chats = [
    Chat("정소영", "산이랑 바다가 모두 좋습니다", "01:21"),
    Chat("박중현", "제주도 가고싶다", "02:31"),
    Chat("조성호", "밥은 먹었니?", "03:21"),
    Chat("장재성", "배고프다", "04:31"),
    Chat("이지우", "현지야 너 정말 멋지다", "05:21")
  ];

  final Map<String, List<Map<String, String>>> conversationData = {
    "정소영": [
      {"type": "received", "text": "어떻게 살고 있습니까?"},
      {"type": "sent", "text": "저는 그럭저럭 지내고 있습니다."},
      {"type": "sent", "text": "제주도 생활은 어떻습니까?"},
      {"type": "received", "text": "산이랑 바다가 모두 좋습니다."}
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '통화 번역 기록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE4E1), // 연한 분홍색
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(10.0), // 배경과 이미지 사이 패딩
                    child: Image.asset(
                      'assets/images/common_mandarin.png',
                      width: 37, // 이미지 크기 줄임
                      height: 37,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Ensures text is left-aligned
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      SizedBox(height: 4), // Adjust the height value as needed for the gap
                      Text(chat.message),
                    ],
                  ),
                  trailing: Text(
                    chat.time,
                    style: TextStyle(fontSize: 14, color: Colors.grey), // Customize time text style
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0), // 세로 길이와 양 옆 여백
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HistoryChatScreen(
                          chatName: chat.name,
                          conversationDate: "2024.04.15, 14:53", // Example date
                          conversation: conversationData[chat.name] ?? [],
                        ),
                      ),
                    );
                  },
                ),
                Divider(color: Colors.orange), // 주황색 구분선
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: HistoryScreen()));
}
