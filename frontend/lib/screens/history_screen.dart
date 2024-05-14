// // lib/screens/history_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:jejal_project/screens/history_chat_screen.dart';
// import 'package:jejal_project/models/conversation.dart';
// import 'package:jejal_project/services/database_service.dart';
// import 'package:intl/intl.dart';// 날짜 포맷팅을 위한 패키지
//
// class HistoryScreen extends StatelessWidget {
//   final DatabaseService databaseService;
//
//   const HistoryScreen({Key? key, required this.databaseService}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     print('32');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           '통화 번역 기록',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: FutureBuilder<List<Conversation>>( // 대화 목록을 가져오는 FutureBuilder
//         // 대화 가져오기 오류 발생 시
//         future: DatabaseService.instance.getAllConversations().catchError((error) {
//           print('33');
//
//           print('fetching conversations 에러: $error');
//           return <Conversation>[]; // 에러 발생 시 빈 리스트 반환
//         }),
//         // FutureBuilder 위젯은 비동기 작업이 완료될 때까지 대기하고, 그 결과를 snapshot 객체에 저장
//         builder: (context, snapshot) {
//           print('34');
//
//           if (snapshot.hasData) { // 스냅샷에 데이터가 있는 경우. 비동기 작업이 완료되고 데이터가 있는지 확인
//             print('35');
//
//             final conversations = snapshot.data!; // 대화 목록을 가져오기
//             return ListView.builder(
//               itemCount: conversations.length, // 대화 목록의 길이에 따라 리스트 항목 생성
//               itemBuilder: (context, index) {
//                 final conversation = conversations[index]; // 대화 가져오기
//                 return Column(
//                   children: [
//                     // 프로필 사진
//                     ListTile(
//                       leading: Container( // 아이콘 컨테이너
//                         decoration: BoxDecoration(
//                           color: Color(0xFFFFE4E1),
//                           shape: BoxShape.circle,
//                         ),
//                         padding: EdgeInsets.all(10.0),
//                         child: Image.asset(
//                           'assets/images/common_mandarin.png',
//                           width: 37,
//                           height: 37,
//                         ),
//                       ),
//                       title: Column( // 상대방 이름과 전화번호 표시
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         chiimport 'package:flutter/material.dart';
//                 import 'package:flutter_overlay_window/flutter_overlay_window.dart';
//                 import 'package:toggle_switch/toggle_switch.dart';
//                 import 'package:contacts_service/contacts_service.dart';
//                 import 'package:intl/intl.dart';
//                 import 'package:jejal_project/models/conversation.dart';
//                 import 'package:jejal_project/services/database_service.dart';
//                 import 'package:jejal_project/screens/history_chat_screen.dart';
//
//                 class MainCallScreen extends StatelessWidget {
//                 final DatabaseService databaseService;
//
//                 const MainCallScreen({Key? key, required this.databaseService}) : super(key: key);
//
//                 @override
//                 Widget build(BuildContext context) {
//                 return Scaffold(
//                 body: Center(
//                 child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                 Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                 Expanded(
//                 child: Text(
//                 "통화 중 번역을 원한다면! \n 결과를 표시해줄 위점을 ON해주세요",
//                 style: TextStyle(fontSize: 16),
//                 ),
//                 ),
//                 SizedBox(width: 20),
//                 ToggleSwitch(
//                 initialLabelIndex: 1,
//                 minWidth: 90.0,
//                 minHeight: 30.0,
//                 cornerRadius: 20.0,
//                 activeFgColor: Colors.white,
//                 activeBgColor: [Colors.orange],
//                 inactiveBgColor: Colors.grey,
//                 inactiveFgColor: Colors.white,
//                 labels: const ['On', 'Off'],
//                 onToggle: (index) async {
//                 if (index == 0 && !(await FlutterOverlayWindow.isActive())) {
//                 await FlutterOverlayWindow.showOverlay(
//                 enableDrag: true,
//                 overlayTitle: "제잘제잘",
//                 overlayContent: "제주 방언 번역기",
//                 flag: OverlayFlag.defaultFlag,
//                 visibility: NotificationVisibility.visibilityPublic,
//                 height: 170,
//                 width: 200,
//                 startPosition: const OverlayPosition(0, 0),
//                 );
//                 } else if (index == 1 && await FlutterOverlayWindow.isActive()) {
//                 await FlutterOverlayWindow.closeOverlay();
//                 }
//                 },
//                 ),
//                 ],
//                 ),
//                 ),
//                 const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10),
//                 child: Text("통화해볼까요?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 ),
//                 // Recent 5 contacts horizontal list
//                 Container(
//                 height: 100,
//                 child: FutureBuilder<List<Conversation>>(
//                 future: databaseService.getRecentConversations(5), // 가정: 최근 5개 대화 가져오기
//                 builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                 return ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) {
//                 final conversation = snapshot.data![index];
//                 return Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Column(
//                 children: [
//                 CircleAvatar(
//                 radius: 30,
//                 backgroundImage: NetworkImage(conversation.avatarUrl ?? 'default_avatar.png'), // 가정
//                 ),
//                 Text(conversation.name),
//                 ],
//                 ),
//                 );
//                 },
//                 );
//                 } else {
//                 return Center(child: CircularProgressIndicator());
//                 }
//                 },
//                 ),
//                 ),
//                 const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10),
//                 child: Text("통화기록", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 ),
//                 Expanded(
//                 child: FutureBuilder<List<Conversation>>(
//                 future: databaseService.getAllConversations().catchError((error) {
//                 return <Conversation>[]; // 에러 발생 시 빈 리스트 반환
//                 }),
//                 builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                 final conversations = snapshot.data!.reversed.toList(); // 정렬 변경
//                 return ListView.builder(
//                 itemCount: conversations.length,
//                 itemBuilder: (context, index) {
//                 final conversation = conversations[index];
//                 return ListTile(
//                 leading: FutureBuilder<Contact?>(
//                 future: ContactsService.getContactsForPhone(conversation.phoneNumber).then((contacts) {
//                 return contacts.isNotEmpty ? contacts.first : null;
//                 }),
//                 builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//                 } else {
//                 final contact = snapshot.data;
//                 final avatar = contact?.avatar;
//                 return avatar != null && avatar.isNotEmpty
//                 ? CircleAvatar(backgroundImage: MemoryImage(avatar))
//                     : CircleAvatar(child: Icon(Icons.person));
//                 }
//                 },
//                 ),
//                 title: Text(conversation.name),
//                 subtitle: Text(conversation.phoneNumber),
//                 trailing: Text(
//                 DateFormat('MM-dd HH:mm').format(DateTime.parse(conversation.date)),
//                 style: TextStyle(color: Colors.grey, fontSize: 14),
//                 ),
//                 onTap: () async {
//                 final messages = await databaseService.getMessagesByConversationId(conversation.id!);
//                 Navigator.of(context).push(
//                 MaterialPageRoute(
//                 builder: (context) => HistoryChatScreen(
//                 conversationId: conversation.id!,
//                 messages: messages,
//                 ),
//                 ),
//                 );
//                 },
//                 );
//                 },
//                 );
//                 } else {
//                 return Center(child: CircularProgressIndicator());
//                 }
//                 },
//                 ),
//                 ),
//                 ],
//                 ),
//                 ),
//                 );
//                 }
//                 }
//                 ldren: [
//                           // 상대방 이름
//                           Text(
//                             conversation.name, // 대화 상대방 전화번호 출력
//                             style: TextStyle(
//                               color: Colors.orange, // 오렌지색
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             conversation.phoneNumber, // 대화 상대방 전화번호 출력
//                             style: TextStyle(
//                               color: Colors.grey, // 회색
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       trailing: Text(
//                         DateFormat('MM-dd HH:mm').format(DateTime.parse(conversation.date)), // 월/일 시:분 형식으로 날짜 출력
//                         style: TextStyle(
//                           color: Colors.grey, // 회색
//                           fontSize: 14,
//                         ),
//                       ),
//                       contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
//                       onTap: () async { // ListTile 탭 시 실행될 코드
//                         print('36');
//                         final messages = await databaseService.getMessagesByConversationId(conversation.id!); // 대화 ID로 텍스트 가져오기
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => HistoryChatScreen(
//                               conversationId: conversation.id!, // 대화 ID 전달
//                               messages: messages, // 텍스트 데이터 전달
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     Divider(color: Colors.orange), // 구분선
//                   ],
//                 );
//               },
//             );
//           } else {
//             print('37');
//             return Center(child: CircularProgressIndicator()); // 로딩 중 표시
//           }
//         },
//       ),
//     );
//   }
// }