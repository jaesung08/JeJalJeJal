import 'package:flutter/material.dart';

class TangerineIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Image.asset(
        'assets/images/common_mandarin.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
