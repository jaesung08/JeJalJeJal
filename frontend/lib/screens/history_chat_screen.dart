import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jejal_project/models/conversation.dart';
import 'package:jejal_project/models/receive_message_model.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/widgets/text_segment_box.dart';

import '../style/color_style.dart';

class HistoryChatScreen extends StatelessWidget {
  final int conversationId;
  final List<ReceiveMessageModel> messages;

  const HistoryChatScreen({
    super.key,
    required this.conversationId,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyles.backgroundBox,
      appBar: AppBar(
        backgroundColor: ColorStyles.backgroundBox,
        title: FutureBuilder<Conversation>(
          future: DatabaseService.instance.getConversationById(conversationId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final conversation = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${conversation.name}과의 통화 통역 기록', style: TextStyle(fontSize: 16, fontFamily: "Rikodeo"),),
                  Text(
                    '${DateFormat('MM-dd HH:mm').format(DateTime.parse(conversation.date))} 통화',
                    style: TextStyle(fontSize: 14, color: Colors.orange , fontFamily: "Rikodeo"),
                  ),
                ],
              );
            } else {
              print('31');
              return Text('Loading...');
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
            child: _buildTranslationPair(message.jeju, message.translated),
          );
        },
      ),
    );
  }

  Widget _buildTranslationPair(String? jejuText, String? translatedText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextSegmentBox(
          jejuText: jejuText ?? '',
          translatedText: translatedText ?? '',
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}