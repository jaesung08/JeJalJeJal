// lib/screens/history_chat_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jejal_project/databases/database.dart';

class HistoryChatScreen extends StatelessWidget {
  final int conversationId;
  final JejalDatabase database;

  const HistoryChatScreen({
    Key? key,
    required this.conversationId,
    required this.database,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Conversation>(
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
      body : FutureBuilder<List<JejuText>>(
        future: database.getJejuTextsByConversationId(conversationId).catchError((error) {
          print('Error fetching jeju texts: $error');
          return <JejuText>[];
        }),
        builder: (context, jejuSnapshot) {
          if (jejuSnapshot.hasData) {
            return FutureBuilder<List<TranslatedText>>(
              future: database.getTranslatedTextsByConversationId(conversationId).catchError((error) {
                print('Error fetching translated texts: $error');
                return <TranslatedText>[];
              }),
              builder: (context, translatedSnapshot) {
                if (translatedSnapshot.hasData) {
                  final jejuTexts = jejuSnapshot.data!;
                  final translatedTexts = translatedSnapshot.data!;

                  return ListView.builder(
                    itemCount: min(jejuTexts.length, translatedTexts.length),
                    itemBuilder: (context, index) {
                      final jejuText = jejuTexts[index];
                      final translatedText = translatedTexts[index];

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
                              jejuText.jejuText,
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
                              translatedText.translatedText,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}