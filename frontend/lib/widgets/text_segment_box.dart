import 'package:flutter/material.dart';

class TextSegmentBox extends StatelessWidget {
  final String jejuText;
  final String translatedText;
  final bool showOnlyJeju; // 오직 제주어만 보여줄지 여부를 결정

  const TextSegmentBox({
    Key? key,  // 위젯의 키를 받는 매개변수
    required this.jejuText,
    required this.translatedText,
    this.showOnlyJeju = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align( // 위젯을 정렬하는 Align 위젯
      alignment: showOnlyJeju ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0), // 컨테이너의 여백을 설정
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0), // 컨테이너의 안쪽 여백을 설정
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: showOnlyJeju ? Colors.white : Color(0xFFF9A03A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: showOnlyJeju ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              jejuText,
              style: TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            if (!showOnlyJeju) const Divider(color: Colors.white60), // showOnlyJeju가 false인 경우 구분선을 추가
            if (!showOnlyJeju)
              Text(
                translatedText,
                style: TextStyle(fontSize: 16.0, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
