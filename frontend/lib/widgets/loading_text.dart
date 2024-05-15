import 'dart:async';
import 'package:flutter/material.dart';

class LoadingText extends StatefulWidget {
  final String text;

  const LoadingText({Key? key, required this.text}) : super(key: key);

  @override
  _LoadingTextState createState() => _LoadingTextState();
}

class _LoadingTextState extends State<LoadingText> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 취소
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) { // mounted 속성 확인
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.text}${List.filled(_dotCount, '.').join()}',
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }
}