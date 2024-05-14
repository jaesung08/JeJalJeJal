import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:intl/intl.dart';
import 'package:jejal_project/models/conversation.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/screens/history_chat_screen.dart';

import '../services/contacts_service.dart';

class MainCallScreen extends StatelessWidget {
  final DatabaseService databaseService;

  const MainCallScreen({Key? key, required this.databaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "통화 중 번역을 원한다면! \n 결과를 표시해줄 위젯을 ON해주세요",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 20),
                  ToggleSwitch(
                    initialLabelIndex: 1,
                    minWidth: 90.0,
                    minHeight: 30.0,
                    cornerRadius: 20.0,
                    activeFgColor: Colors.white,
                    activeBgColor: [Colors.orange],
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    labels: const ['On', 'Off'],
                    onToggle: (index) async {
                      if (index == 0 && !(await FlutterOverlayWindow.isActive())) {
                        await FlutterOverlayWindow.showOverlay(
                          enableDrag: true,
                          overlayTitle: "제잘제잘",
                          overlayContent: "제주 방언 번역기",
                          flag: OverlayFlag.defaultFlag,
                          visibility: NotificationVisibility.visibilityPublic,
                          height: 170,
                          width: 200,
                          startPosition: const OverlayPosition(0, 0),
                        );
                      } else if (index == 1 && await FlutterOverlayWindow.isActive()) {
                        await FlutterOverlayWindow.closeOverlay();
                      }
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("통화해볼까요?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 120, // Increased height to accommodate names below the avatars
              child: FutureBuilder<List<Conversation>>(
                future: databaseService.getUniqueRecentConversations(5), // Adjusted to call new method
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final conversations = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: conversations.length, // This now corresponds to the number of unique conversations
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return Container(
                          width: MediaQuery.of(context).size.width / 5, // Adjust width to fit 5 items on screen
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FutureBuilder<Contact?>(
                                future: ContactsService.getContactsForPhone(conversation.phoneNumber).then((contacts) {
                                  return contacts.isNotEmpty ? contacts.first : null;
                                }),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    final contact = snapshot.data;
                                    final avatar = contact?.avatar;
                                    return CircleAvatar(
                                      radius: 30,
                                      backgroundImage: avatar != null && avatar.isNotEmpty ? MemoryImage(avatar) : null,
                                      child: avatar == null || avatar.isEmpty ? Icon(Icons.person, size: 30) : null,
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: 8), // Space between avatar and name
                              Text(
                                conversation.name == "제주도민" ? conversation.phoneNumber : conversation.name,
                                style: TextStyle(fontSize: 12), // Adjust font size to fit
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),



            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("통화기록", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: FutureBuilder<List<Conversation>>(
                future: databaseService.getAllConversations().catchError((error) {
                  return <Conversation>[]; // 에러 발생 시 빈 리스트 반환
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final conversations = snapshot.data!.reversed.toList(); // 정렬 변경
                    return ListView.builder(
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ListTile(
                          leading: FutureBuilder<Contact?>(
                            future: ContactsService.getContactsForPhone(conversation.phoneNumber).then((contacts) {
                              return contacts.isNotEmpty ? contacts.first : null;
                            }),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else {
                                final contact = snapshot.data;
                                final avatar = contact?.avatar;
                                return avatar != null && avatar.isNotEmpty
                                    ? CircleAvatar(backgroundImage: MemoryImage(avatar))
                                    : CircleAvatar(child: Icon(Icons.person));
                              }
                            },
                          ),
                          title: Text(conversation.name+'님과의 대화 기록'),
                          subtitle: Text(conversation.phoneNumber),
                          trailing: Text(
                            DateFormat('MM-dd HH:mm').format(DateTime.parse(conversation.date)),
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          onTap: () async {
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
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
