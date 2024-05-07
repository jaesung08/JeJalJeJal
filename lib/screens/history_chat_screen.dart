import 'package:flutter/material.dart';

class HistoryChatScreen extends StatelessWidget {
  final String chatName;
  final String conversationDate;
  final List<Map<String, String>> conversation;

  HistoryChatScreen ({
    required this.chatName,
    required this.conversationDate,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$chatName의 통화 번역 기록'),
            Text(
              '$conversationDate 통화',
              style: TextStyle(fontSize: 14, color: Colors.orange),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: conversation.length,
        itemBuilder: (context, index) {
          final message = conversation[index];
          final isSent = message['type'] == 'sent';

          return Align(
            alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isSent ? Colors.orange : Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                message['text']!,
                style: TextStyle(color: isSent ? Colors.white : Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}
