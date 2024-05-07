import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';

class TrueCallerOverlay extends StatefulWidget {
  // 클래스의 인스턴스를 생성할 때 사용할 수 있는 선택적인 키를 허용
  // 이 키를 사용하여 위젯을 고유하게 식별 가능
  const TrueCallerOverlay({Key? key}) : super(key: key);

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool showIcon = true; // Icon 표시 여부를 나타내는 변수
  bool showBox = false; // 상자 표시 여부를 나타내는 변수

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87, // 배경색을 설정
      child: Stack( // 여러 위젯을 겹쳐서 표시하기 위한 Stack 위젯
        children: [
          Positioned(
            top: 5.0, // 원하는 Y 위치
            right: 20.0, // 원하는 X 위치
            child: GestureDetector( // 사용자 동작 감지를 위한 GestureDetector 위젯
              onTap: () {
                setState(() {
                  showBox = !showBox; // 상자 표시 여부를 반전
                  showIcon = !showIcon; // 아이콘 표시 여부를 반전
                });
              },
              child: Column( // 세로로 배치되는 위젯 그룹
                children: [
                  if (showIcon) TangerineIcon(), // showIcon이 true인 경우에만 아이콘 표시
                  if (showBox) _buildBox(), // showBox가 true인 경우에만 상자 표시
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox() { // 상자를 생성하는 함수
    return Container(
      margin: const EdgeInsets.only(top: 10.0), // 위쪽 마진 설정
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // 내부 패딩 설정
      width: 300.0,
      height: 480.0,
      decoration: BoxDecoration(
        color: Colors.orangeAccent.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Text(
              "실시간 통역 중",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text(
              "어떻게 살고 있습니까?",
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "저는 그럭저럭 지내고 있습니다.",
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "산이영 바당이영 문딱 좋은게 마씀",
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "산이랑 바다 모두 좋습니다",
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

}
