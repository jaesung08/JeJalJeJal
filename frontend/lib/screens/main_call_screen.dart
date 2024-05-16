import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:intl/intl.dart';
import 'package:jejal_project/models/conversation.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/screens/history_chat_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MainCallScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const MainCallScreen({Key? key, required this.databaseService})
      : super(key: key);

  @override
  _MainCallScreenState createState() => _MainCallScreenState();
}

class _MainCallScreenState extends State<MainCallScreen> {
  Future<List<Conversation>>? conversationsFuture;

  @override
  void initState() {
    super.initState();
    conversationsFuture = widget.databaseService.getAllConversations(); // 초기 데이터 로딩
  }

  void refreshScreen() {
    setState(() {
      conversationsFuture = widget.databaseService.getAllConversations(); // 데이터 재로딩
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F5F4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10) ,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "통화 중 번역을 원한다면!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "결과를 표시해 줄",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "위젯을 ON 해주세요",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10) ,
                    decoration: BoxDecoration(
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.5),
                      //     spreadRadius: 1,
                      //     blurRadius: 5,
                      //     blurStyle: BlurStyle.outer,
                      //     offset: Offset(0, 3),
                      //   ),
                      // ],
                    ),
                    child: ToggleSwitch(
                      initialLabelIndex: 1,
                      minWidth: 60.0,
                      minHeight: 60.0,
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
                            height: 250,
                            width: 250,
                            startPosition: const OverlayPosition(0, 25),
                          );
                        } else if (index == 1 && await FlutterOverlayWindow.isActive()) {
                          await FlutterOverlayWindow.closeOverlay();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text("\u{260E} 전화 통역 체험해봐요!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start
                ),
                  Text(
                    "최근 통화 목록",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ]
              )
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              height: 130,
              width: 350,
              child: FutureBuilder<List<Conversation>>(
                future: widget.databaseService.getUniqueRecentConversations(5),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final conversations = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return GestureDetector(
                          onTap: () async {
                            var url = 'tel:${conversation.phoneNumber}';
                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not launch $url'))
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            width: MediaQuery.of(context).size.width / 6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<List<Contact>>(
                                  future: ContactsService.getContactsForPhone(conversation.phoneNumber),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                      final contact = snapshot.data!.first;
                                      final avatar = contact.avatar;
                                      return CircleAvatar(
                                        radius: 25,
                                        backgroundImage: avatar != null && avatar.isNotEmpty ? MemoryImage(avatar) : null,
                                        child: avatar == null || avatar.isEmpty ? Icon(Icons.person, size: 30) : null,
                                      );
                                    } else {
                                      return CircleAvatar(radius: 25,child: Icon(Icons.person, size: 30)); // Default icon if no contact or avatar found
                                    }
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                  conversation.name == "제주도민" ? conversation.phoneNumber : conversation.name,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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
            Column(
              children: [SizedBox(height: 30)],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("\u{1F4CB} 전화 통역 기록",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: refreshScreen,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10), // 리스트뷰의 좌우 여백
                width: 370,
                child: FutureBuilder<List<Conversation>>(
                  future: widget.databaseService.getAllConversations().catchError((error) {
                    return <Conversation>[]; // 에러 발생 시 빈 리스트 반환
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final conversations = snapshot.data!.reversed.toList(); // 정렬 변경
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          bool isDefaultName = conversation.name == "제주도민";
                          return
                            Column(
                              children: [
                                Container(
                                    height: 70,
                                    width: 350,
                                    margin: EdgeInsets.symmetric(vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                      leading: FutureBuilder<List<Contact>>(
                                        future: ContactsService.getContactsForPhone(conversation.phoneNumber),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                            final contact = snapshot.data!.first;
                                            final avatar = contact.avatar;
                                            return CircleAvatar(
                                              radius: 25,
                                              backgroundImage: avatar != null && avatar.isNotEmpty ? MemoryImage(avatar) : null,
                                              child: avatar == null || avatar.isEmpty ? Icon(Icons.person, size: 30) : null,
                                            );
                                          } else {
                                            return CircleAvatar(radius: 25, child: Icon(Icons.person, size: 30)); // Default icon if no contact or avatar found
                                          }
                                        },
                                      ),
                                      title:Column(
                                        mainAxisAlignment: MainAxisAlignment.center, // Center the column along the cross axis
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min, // Use minimum space that the children need
                                        children: [
                                          Text(
                                            isDefaultName ? conversation.phoneNumber + "님과의 통화" : conversation.name + "님과의 통화",
                                            style: TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (!isDefaultName) Text(
                                            conversation.phoneNumber,
                                            style: TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),

                                      trailing: Text(
                                        DateFormat('MM-dd HH:mm').format(DateTime.parse(conversation.date)),
                                        style: TextStyle(color: Colors.grey, fontSize: 14),
                                      ),
                                      onTap: () async {
                                        final messages = await widget.databaseService.getMessagesByConversationId(conversation.id!);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => HistoryChatScreen(
                                              conversationId: conversation.id!,
                                              messages: messages,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                ),
                                Container(
                                  height: 15,
                                )
                              ],
                            );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
