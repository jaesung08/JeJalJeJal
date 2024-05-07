import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';


//메인에서 설정 눌렀을 때 호출된 위젯
class TrueCallerOverlay extends StatefulWidget {
  const TrueCallerOverlay({Key? key}) : super(key: key);

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool showBox = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            top: 20.0, // 원하는 Y 위치
            right: 20.0, // 원하는 X 위치
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showBox = !showBox;
                });
              },
              child: showBox ? _buildBox() : _buildIcon(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return TangerineIcon();
  }

  Widget _buildBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      width: 300.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _orangeColors,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                title: const Text(
                  "제주어 실시간 통역 중",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () async {
                setState(() {
                  showBox = false;
                });
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<Color> _orangeColors = [
    Color(0xFFFF7F00),
    Color(0xFFFFD700),
  ];
}
