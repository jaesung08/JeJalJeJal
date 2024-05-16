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
  bool isOverlayOn = false;

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

  void toggleOverlay() async {
    if (!isOverlayOn && !(await FlutterOverlayWindow.isActive())) {
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
      setState(() {
        isOverlayOn = true;
      });
    } else if (isOverlayOn && await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
      setState(() {
        isOverlayOn = false;
      });
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    // 전화번호에서 공백, 대시(-) 제거
    String cleaned = phoneNumber.replaceAll(RegExp(r'[-\s]'), '');

    // 전화번호를 형식에 맞게 포맷팅
    if (cleaned.length == 11) {
      return cleaned.replaceAllMapped(RegExp(r'(\d{3})(\d{4})(\d{4})'), (Match m) => "${m[1]}-${m[2]}-${m[3]}");
    } else if (cleaned.length == 10) {
      return cleaned.replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d{4})'), (Match m) => "${m[1]}-${m[2]}-${m[3]}");
    } else {
      return phoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xf7f7f7f7),
      body: Center(
        child: SingleChildScrollView(
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
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "통화 중 번역을 원한다면",
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
                    GestureDetector(
                      onTap: toggleOverlay,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Image.asset(
                          isOverlayOn ? 'assets/images/translate_on.png' : 'assets/images/translate_off.png',
                          width: 90,
                          height: 90,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\u{260E} 전화 통역 체험해봐요!",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "최근 통화 목록",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      height: 130,
                      width: double.infinity,
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
                                    var url = 'tel:${formatPhoneNumber(conversation.phoneNumber)}';
                                    if (await canLaunchUrlString(url)) {
                                      await launchUrlString(url);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Could not launch $url'))
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 35),
                                    width: MediaQuery.of(context).size.width / 6,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FutureBuilder<List<Contact>>(
                                          future: ContactsService.getContactsForPhone(formatPhoneNumber(conversation.phoneNumber)),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                              final contact = snapshot.data!.first;
                                              final avatar = contact.avatar;
                                              return CircleAvatar(
                                                radius: 40,
                                                backgroundImage: avatar != null && avatar.isNotEmpty ? MemoryImage(avatar) : null,
                                                child: avatar == null || avatar.isEmpty ? Icon(Icons.person, size: 30) : null,
                                              );
                                            } else {
                                              return CircleAvatar(radius: 40, child: Icon(Icons.person, size: 30)); // Default icon if no contact or avatar found
                                            }
                                          },
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          conversation.name == "제주도민" ? formatPhoneNumber(conversation.phoneNumber) : conversation.name,
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
                  ],
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
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: 370,
                child: FutureBuilder<List<Conversation>>(
                  future: widget.databaseService.getAllConversations().catchError((error) {
                    return <Conversation>[]; // 에러 발생 시 빈 리스트 반환
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final conversations = snapshot.data!.reversed.toList(); // 정렬 변경
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = conversations[index];
                          bool isDefaultName = conversation.name == "제주도민";
                          return Column(
                            children: [
                              Container(
                                height: 80,
                                width: 350,
                                margin: EdgeInsets.symmetric(vertical: 4),
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
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  leading: FutureBuilder<List<Contact>>(
                                    future: ContactsService.getContactsForPhone(formatPhoneNumber(conversation.phoneNumber)),
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
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Text(
                                      //   isDefaultName ? conversation.phoneNumber + "님과의 통화" : conversation.name + "님과의 통화",
                                      //   style: TextStyle(fontSize: 12),
                                      //   overflow: TextOverflow.ellipsis,
                                      // ),
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 14, color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: isDefaultName ? formatPhoneNumber(conversation.phoneNumber) : conversation.name,
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: " 님과의 통화"),
                                          ],
                                        ),
                                      ),
                                      if (!isDefaultName) Padding(
                                        padding: EdgeInsets.only(top: 8.0), // 원하는 여백 값 설정
                                        child: Text(
                                          formatPhoneNumber(conversation.phoneNumber),
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0), // 원하는 패딩 값 설정
                                        child: Text(
                                          DateFormat('MM/dd').format(DateTime.parse(conversation.date)),
                                          style: TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0), // 원하는 패딩 값 설정
                                        child: Text(
                                          DateFormat('a HH:mm').format(DateTime.parse(conversation.date)),
                                          style: TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ),
                                    ],
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
