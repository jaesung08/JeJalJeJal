import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jejal_project/models/conversation.dart';
import 'package:jejal_project/models/receive_message_model.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/widgets/text_segment_box.dart';

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
    print('29');

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Conversation>(
          future: DatabaseService.instance.getConversationById(conversationId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print('30');
              final conversation = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${conversation.name}의 통화 번역 기록'),
                  Text(
                    '${DateFormat('MM-dd HH:mm').format(DateTime.parse(conversation.date))} 통화',
                    style: TextStyle(fontSize: 14, color: Colors.orange),
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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