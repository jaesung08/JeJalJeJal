import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/databases/database.dart' hide Text;
import 'package:jejal_project/screens/history_screen.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:jejal_project/screens/result_detail_screen.dart';
import 'package:jejal_project/screens/select_file_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jejal_project/screens/guide_screen.dart';
import 'package:toggle_switch/toggle_switch.dart';

class HomePage extends StatelessWidget {
  final JejalDatabase database;
//
  const HomePage({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5E0), // 배경색
        ),
        child: Column(
          children: [
            // 상단 텍스트 부분
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 60, 20, 20),
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  // const Text(
                  //   '혼저옵서예!',
                  //   style: TextStyle(
                  //     fontSize: 26,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.black87, // 텍스트 색상
                  //   ),
                  // ),
                  Image.asset(
                    'assets/images/jejal_logo.png',
                    width: 100,
                    height: 60,
                  ),
                  const Spacer(),
                  // TextButton(
                  //   onPressed: () async {
                  //     if (await FlutterOverlayWindow.isActive()) {
                  //       await FlutterOverlayWindow.closeOverlay();
                  //       }
                  //     else {
                  //       await FlutterOverlayWindow.showOverlay(
                  //         enableDrag: true,
                  //         overlayTitle: "제잘제잘",
                  //         overlayContent: "제주 방언 번역기",
                  //         flag: OverlayFlag.defaultFlag,
                  //         visibility: NotificationVisibility.visibilityPublic,
                  //         // positionGravity: PositionGravity.auto,
                  //         height: 170,
                  //         width: 200,
                  //         startPosition: const OverlayPosition(0, 0),
                  //       );
                  //     }
                  //   },
                  //   child: const Text(
                  //     '설정',
                  //     style: TextStyle(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.orange, // 텍스트 색상
                  //     ),
                  //   ),
                  // ),
                  Text('번역'),
                  SizedBox(width: 5),
                  ToggleSwitch(
                    initialLabelIndex: 1, // Initially set to "번역 Off"
                    minWidth: 45.0,
                    minHeight: 30.0,
                    cornerRadius: 20.0,
                    activeFgColor: Colors.white,
                    activeBgColor: [Colors.orange],
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    labels: const ['On', 'Off'],
                    onToggle: (index) async {
                      if (index == 0) {
                        // "번역 On" state
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
                      } else {
                        // "번역 Off" state
                        if (await FlutterOverlayWindow.isActive()) {
                          await FlutterOverlayWindow.closeOverlay();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            // 첫 번째 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(
                        database: database,
                        translationService: TranslationService(
                          database,
                          WebSocketChannel.connect(
                              Uri.parse('wss://k10a406.p.ssafy.io/api/record')),
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300, // 버튼 배경색
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '통화 기록',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '제주도 사투리가\n번역된 통화기록을\n확인해보세요',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(), // 텍스트와 이미지를 분리하는 공간
                        Stack(
                          children: [
                            Image.asset('assets/images/call_list.png',
                                width: 80),
                            // Positioned(
                            //   top: -10,
                            //   right: -10,
                            //   child: Image.asset('assets/images/phone.png',
                            //       width: 30), // 크기와 위치를 조정하세요
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 두 번째 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
              child: GestureDetector(
                onTap: () {
                  // 번역기 사용 버튼 클릭 시 동작 구현
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectFileScreen()),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300, // 버튼 배경색
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/translating.png',
                                width: 90),
                          ],
                        ),
                        const Spacer(), // 이미지와 텍스트 사이의 공간을 분리
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                '파일 통역',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '음성 파일을 \n 바로 통역해보세요',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 앱 사용 설명서
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              child: GestureDetector(
                onTap: () {
                  // 번역기 사용 버튼 클릭 시 동작 구현
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GuideScreen()),
                  );
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black12, // 버튼 배경색
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: const [
                        Text(
                          '사용설명서', // 텍스트 추가
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
