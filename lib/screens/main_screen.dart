import 'package:flutter/material.dart';
import 'package:jejal_project/screens/history_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFFFF5E0), // 배경색
        ),
        child: Column(
          children: [
            // 상단 텍스트 부분
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
              child: Row(
                children: [
                  Text(
                    'ㅇㅇ님,',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange, // 텍스트 색상
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '혼저옵서예!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // 텍스트 색상
                    ),
                  ),
                  Spacer(),
                  Text(
                    '설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange, // 텍스트 색상
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
                        builder: (context) => HistoryScreen()
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
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '통화 번역',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              const Text(
                                '통화에서의\n제주도 사투리를\n실시간으로 번역해준다',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(), // 텍스트와 이미지를 분리하는 공간
                        Stack(
                          children: [
                            Image.asset('assets/images/common_mandarin.png', width: 90),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: Image.asset('assets/images/phone.png', width: 40), // 크기와 위치를 조정하세요
                            ),
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
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300, // 버튼 배경색
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/common_jeju.png', width: 90),
                          ],
                        ),
                        Spacer(), // 이미지와 텍스트 사이의 공간을 분리
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '번역기 사용',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              const Text(
                                '번역된 통화 기록들을\n다시 확인해보세요!\n제주 방언 단어의\n의미도 알려줘요!',
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