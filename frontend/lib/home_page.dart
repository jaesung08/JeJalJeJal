// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/databases/database_helper.dart' hide Text;
import 'package:jejal_project/screens/history_screen.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:jejal_project/screens/select_file_screen.dart';

class HomePage extends StatelessWidget {
  final TranslationService translationService;

//
  const HomePage({Key? key, required this.translationService})
      : super(key: key);

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
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  const Text(
                    '혼저옵서예!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // 텍스트 색상
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      if (await FlutterOverlayWindow.isActive()) {
                        await FlutterOverlayWindow.closeOverlay();
                      } else {
                        await FlutterOverlayWindow.showOverlay(
                          enableDrag: true,
                          overlayTitle: "제잘제잘",
                          overlayContent: "제주 방언 번역기",
                          flag: OverlayFlag.defaultFlag,
                          visibility: NotificationVisibility.visibilityPublic,
                          positionGravity: PositionGravity.auto,
                          height: 170,
                          width: 200,
                          startPosition: const OverlayPosition(0, 0),
                        );
                      }
                    },
                    child: const Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange, // 텍스트 색상
                      ),
                    ),
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
                        translationService: TranslationService(
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
                                '통화 번역',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '통화에서의\n제주도 사투리를\n실시간으로 번역해드려요',
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
                            Image.asset('assets/images/common_mandarin.png',
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
                            Image.asset('assets/images/common_jeju.png',
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
          ],
        ),
      ),
    );
  }
}
