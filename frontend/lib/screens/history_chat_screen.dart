import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jejal_project/models/conversation.dart';
import 'package:jejal_project/models/text_entry.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/widgets/text_segment_box.dart';

import '../widgets/text_segment_box.dart'; // TextSegmentBox 위젯 가져오기

class HistoryChatScreen extends StatelessWidget {
  final int conversationId;
  final List<TextEntry> texts;

  const HistoryChatScreen({
    super.key,
    required this.conversationId,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Conversation>(
          future: DatabaseService.instance.getConversationById(conversationId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final conversation = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${conversation.phoneNumber}의 통화 번역 기록'),
                  Text(
                    '${DateFormat('yyyy-MM-dd').format(DateTime.now())} 통화',
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
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: _buildTranslationPair(text.jejuText, text.translatedText),
          );
        },
      ),
    );
  }

  Widget _buildTranslationPair(String jejuText, String translatedText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextSegmentBox(
          jejuText: jejuText,
          translatedText: translatedText,
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}