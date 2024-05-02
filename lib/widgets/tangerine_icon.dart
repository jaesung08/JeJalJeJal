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
      child: Icon(
        Icons.favorite,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}