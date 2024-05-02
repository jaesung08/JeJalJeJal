import 'package:flutter/material.dart';
import '../widgets/overlay_text.dart';
import '../widgets/tangerine_icon.dart';

class CallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 통화 화면 UI 구현
          Positioned(
            bottom: 16,
            right: 16,
            child: TangerineIcon(),
          ),
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: OverlayText(),
          ),
        ],
      ),
    );
  }
}