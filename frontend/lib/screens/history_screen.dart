// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:jejal_project/screens/history_chat_screen.dart';
import 'package:jejal_project/databases/database.dart' as db;
import 'package:jejal_project/services/translation_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final db.JejalDatabase database;
  final TranslationService translationService;

  const HistoryScreen({Key? key, required this.database, required this.translationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '통화 번역 기록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<db.Conversation>>(
        future: database.getAllConversations().catchError((error) {
          print('fetching conversations 에러: $error');
          return <db.Conversation>[];
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
                      leading: Container(
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
                      title: Column(
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
                          Text(DateFormat('yyyy-MM-dd HH:mm').format(conversation.date)),
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
                      onTap: () async {
                        await translationService.startConversation();
                        final texts = await translationService.getTextsByConversationId(conversation.id);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HistoryChatScreen(
                              conversationId: conversation.id,
                              database: database,
                              texts: texts,
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(color: Colors.orange),
                  ],
                );
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