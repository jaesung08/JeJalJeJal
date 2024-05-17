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
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

import '../style/color_style.dart';

class MainCallScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const MainCallScreen({Key? key, required this.databaseService})
      : super(key: key);

  @override
  _MainCallScreenState createState() => _MainCallScreenState();
}

class _MainCallScreenState extends State<MainCallScreen> {
  Future<List<Conversation>>? conversationsFuture;
  final _controller = ValueNotifier<bool>(false);

  // 전화번호 형식 변환 함수
  String formatPhoneNumber(String phoneNumber) {
    // 숫자만 추출
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // 010 접두사 추가
    if (cleanedNumber.length == 10 && !cleanedNumber.startsWith('010')) {
      cleanedNumber = '010$cleanedNumber';
    }

    // 하이픈 추가
    return cleanedNumber.replaceAllMapped(
        RegExp(r'(\d{3})(\d{3,4})(\d{4})'),
            (Match match) => "${match[1]}-${match[2]}-${match[3]}");
  }


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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyles.backgroundBox,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10) ,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "전화 통역을 원하면!",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w200, fontFamily: 'Rikodeo'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "번역 결과를 표시해 줄",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100, color: Colors.grey, fontFamily: 'Rikodeo'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "위젯을 ON 해주세요",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100, color: Colors.grey, fontFamily: 'Rikodeo'),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(),
                    child: AdvancedSwitch(
                      activeChild: Text(
                          '  ON',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                      inactiveChild: Text(
                          'OFF  ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                      borderRadius: BorderRadius.circular(30),
                      width: 110,
                      height: 55,
                      activeColor: Colors.orange,
                      controller: _controller,
                      onChanged: (value) async {
                        if (value && !(await FlutterOverlayWindow.isActive())) {
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
                        } else if (!value && await FlutterOverlayWindow.isActive()) {
                          await FlutterOverlayWindow.closeOverlay();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children:[
                      Text("\u{260E}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),
                          textAlign: TextAlign.start),
                      Text("  최근 통화 목록",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w200, fontFamily: 'Rikodeo'),
                          textAlign: TextAlign.start
                      ),
                    ]
                  ),
                  Text(
                    "클릭 시 통화 화면으로 이동",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100, color: Colors.grey, fontFamily: 'Rikodeo'),
                  ),
                ]
              )
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              height: 130,
              width: 320,
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
                              color: Color(0xFFECDFD2),
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
                            width: MediaQuery.of(context).size.width / 5.5,
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
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, fontFamily: "Rikodeo"),
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
              children: [SizedBox(height: 20)]
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("\u{1F4CB} 전화 통역 기록",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w200, fontFamily: 'Rikodeo'),
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
                padding: EdgeInsets.symmetric(vertical: 0), // 리스트뷰의 좌우 여백
                width: 330,
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
                                      color:Color(0xFFECDFD2),
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
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, fontFamily: "Rikodeo"),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (!isDefaultName) Text(
                                            formatPhoneNumber(conversation.phoneNumber),
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, fontFamily: "Rikodeo", color: Colors.black45),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),

                                      trailing: Text(
                                        DateFormat('MM-dd HH:mm').format(DateTime.parse(conversation.date)),
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, fontFamily: "Rikodeo", color: Colors.black45),
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
