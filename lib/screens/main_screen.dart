import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '흔님, 혼저옵서예!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('통화 시작기'),
              onPressed: () {
                // TODO: 통화 시작 버튼 클릭 시 동작 구현
              },
            ),
          ],
        ),
      ),
    );
  }
}