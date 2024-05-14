import 'package:flutter/material.dart';
import 'package:jejal_project/screens/history_chat_screen.dart';
import 'package:jejal_project/models/conversation.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위한 패키지
import 'package:contacts_service/contacts_service.dart';

class HistoryScreen extends StatelessWidget {
  final DatabaseService databaseService;

  const HistoryScreen({Key? key, required this.databaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('32');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '통화 번역 기록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Conversation>>( // 대화 목록을 가져오는 FutureBuilder
        future: DatabaseService.instance.getAllConversations().catchError((error) {
          print('33');

          print('fetching conversations 에러: $error');
          return <Conversation>[]; // 에러 발생 시 빈 리스트 반환
        }),
        builder: (context, snapshot) {
          print('34');

          if (snapshot.hasData) { // 스냅샷에 데이터가 있는 경우. 비동기 작업이 완료되고 데이터가 있는지 확인
            print('35');

            final conversations = snapshot.data!; // 대화 목록을 가져오기
            return ListView.builder(
              itemCount: conversations.length, // 대화 목록의 길이에 따라 리스트 항목 생성
              itemBuilder: (context, index) {
                final conversation = conversations[index]; // 대화 가져오기
                return Column(
                  children: [
                    ListTile(
                      leading: FutureBuilder<Contact?>(
                        future: ContactsService.getContactsForPhone(conversation.phoneNumber).then((contacts) {
                          return contacts.isNotEmpty ? contacts.first : null;
                        }),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            final contact = snapshot.data; // 스냅샷에서 연락처 가져옴
                            final avatar = contact?.avatar; // 연락처의 프로필 이미지 가져옴
                            return Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFE4E1),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: avatar != null && avatar.isNotEmpty // 프로필 이미지가 존재하는 경우
                                  ? CircleAvatar(
                                backgroundImage: MemoryImage(avatar), // 이미지를 설정
                              )
                                  : Image.asset(
                                'assets/images/common_mandarin.png',
                                width: 37,
                                height: 37,
                              ),
                            );
                          }
                        },
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.name,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            conversation.phoneNumber,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        DateFormat('MM-dd HH:mm').format(DateTime.parse(conversation.date)),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
                      onTap: () async {
                        print('36');
                        final messages = await databaseService.getMessagesByConversationId(conversation.id!);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HistoryChatScreen(
                              conversationId: conversation.id!,
                              messages: messages,
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
            print('37');
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
