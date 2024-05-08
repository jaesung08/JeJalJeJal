// lib/screens/history_chat_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jejal_project/databases/database.dart' as db;

class HistoryChatScreen extends StatelessWidget {
  final int conversationId;
  final db.JejalDatabase database;
  final List<db.TextEntry> texts;

  const HistoryChatScreen({
    Key? key,
    required this.conversationId,
    required this.database,
    required this.texts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<db.Conversation>(
          future: database.getConversationById(conversationId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final conversation = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${conversation.phoneNumber}의 통화 번역 기록'),
                  Text(
                    '${conversation.date} 통화',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ],
              );
            } else {
              return Text('Loading...');
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: texts.length,
        itemBuilder: (context, index) {
          final text = texts[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 4.0),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  text.jejuText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 4.0),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  text.translatedText,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}