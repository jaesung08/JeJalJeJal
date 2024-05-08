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
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jejuText,
            style: TextStyle(fontSize: 18.0, color: Colors.black87),
          ),
          if (!showOnlyJeju) Divider(),
          if (!showOnlyJeju)
            Text(
              translatedText,
              style: TextStyle(fontSize: 18.0, color: Colors.black54),
            ),
        ],
      ),
    );
  }
}
