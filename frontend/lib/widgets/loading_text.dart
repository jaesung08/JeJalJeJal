import 'package:flutter/cupertino.dart';

class LoadingText extends StatefulWidget {
  final String text;

  const LoadingText({Key? key, required this.text}) : super(key: key);

  @override
  _LoadingTextState createState() => _LoadingTextState();
}

class _LoadingTextState extends State<LoadingText> {
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
      });
      _startAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.text}${List.filled(_dotCount, '.').join()}',
      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
  }
}