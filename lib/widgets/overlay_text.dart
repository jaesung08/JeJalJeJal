import 'package:flutter/material.dart';

class OverlayText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '번역된 표준어 텍스트가 여기에 표시됩니다.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}