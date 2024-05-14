import 'package:flutter/material.dart';

class TextSegmentBox extends StatelessWidget {
  final String jejuText;
  final String? translatedText;
  final bool isLoading;

  const TextSegmentBox({
    Key? key,
    required this.jejuText,
    this.translatedText,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              jejuText,
              style: TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            if (isLoading)
              Image.asset('assets/images/overlay_loading.gif')
            else if (translatedText != null && translatedText != "제잘")
              ...[
                const Divider(color: Colors.white),
                Text(
                  translatedText!,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            else if (translatedText == "제잘")
                const SizedBox.shrink(), // 구분선이나 번역 텍스트를 추가하지 않음
          ],
        ),
      ),
    );
  }
}