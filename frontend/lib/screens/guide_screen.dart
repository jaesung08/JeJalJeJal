import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용 설명서'),
      ),
      body: Center(
        child: Text(
          '늘 미안하고,,, 고맙고,,',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
