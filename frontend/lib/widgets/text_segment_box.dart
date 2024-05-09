import 'package:flutter/material.dart';

class TextSegmentBox extends StatelessWidget {
  final String jejuText;
  final String translatedText;
  final bool showOnlyJeju;

  const TextSegmentBox({
    Key? key,
    required this.jejuText,
    required this.translatedText,
    this.showOnlyJeju = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: showOnlyJeju ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
            if (!showOnlyJeju) const Divider(color: Colors.white60),
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
