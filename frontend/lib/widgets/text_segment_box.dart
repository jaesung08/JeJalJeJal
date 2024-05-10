import 'package:flutter/material.dart';

class TextSegmentBox extends StatelessWidget {
  final String jejuText;
  final String translatedText;

  const TextSegmentBox({
    Key? key,
    required this.jejuText,
    required this.translatedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('TextSegmentBox 빌드: jejuText=$jejuText, translatedText=$translatedText');
    return Align(
      alignment: translatedText == "제잘"
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: translatedText == "제잘" ? Colors.green : Color(0xFFF9A03A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: translatedText == "제잘"
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.start,
            children: [
              Text(
                jejuText,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                  fontWeight: translatedText == "제잘"
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (translatedText != "제잘")
                ...[
                  const Divider(color: Colors.white),
                  Text(
                    translatedText,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}