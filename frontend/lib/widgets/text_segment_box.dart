import 'package:flutter/material.dart';

class TextSegmentBox extends StatelessWidget {
  final String jejuText;
  final String translatedText;

  const TextSegmentBox({
    Key? key,
    required this.jejuText,
    required this.translatedText, // translatedText는 필수 매개변수
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      // alignment: translatedText == "제잘" ? Alignment.centerRight : Alignment.centerLeft, // translatedText가 "제잘"인 경우 오른쪽 정렬
      alignment: Alignment.center, // 모든 텍스트를 가운데 정렬
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Colors.black12,
          // color: translatedText == "제잘" ? Colors.black12 : Color(0xFFF9A03A), // translatedText가 "제잘"인 경우 흰색 박스
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          // crossAxisAlignment: translatedText == "제잘" ? CrossAxisAlignment.end : CrossAxisAlignment.start, // translatedText가 "제잘"인 경우 오른쪽 정렬
          children: [
            Text(
              jejuText,
              style: TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            if (translatedText != "제잘") // translatedText가 "제잘"이 아닌 경우에만 구분선과 번역 텍스트를 추가
              ...[
                const Divider(color: Colors.white),
                Text(
                  translatedText,
                  style: TextStyle(fontSize: 16.0, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
              ],
          ],
        ),
      ),
    );
  }
}