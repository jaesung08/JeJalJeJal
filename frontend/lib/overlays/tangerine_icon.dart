import 'package:flutter/material.dart';

class TangerineIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange,
      ),
      child: Image.asset(
        'assets/images/common_mandarin.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
