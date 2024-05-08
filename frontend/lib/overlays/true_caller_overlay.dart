import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/databases/database.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:web_socket_channel/src/channel.dart';

class TrueCallerOverlay extends StatefulWidget {
  final TranslationService translationService;

  const TrueCallerOverlay({Key? key, required this.translationService}) : super(key: key);

  @override
  _TrueCallerOverlayState createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool showIcon = true;
  bool showBox = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Stack(
        children: [
          Positioned(
            top: 0.0,
            right: 10.0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showBox = !showBox;
                  showIcon = !showIcon;
                });
              },
              child: Column(
                children: [
                  if (showIcon) TangerineIcon(),
                  if (showBox) _buildBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      width: 340.0,
      height: 480.0,
      decoration: BoxDecoration(
        color: Colors.orangeAccent.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "실시간 통역 중",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text(
              "어떻게 살고 있습니까?",
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "저는 그럭저럭 지내고 있습니다.",
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "산이영 바당이영 문딱 좋은게 마씀",
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              "산이랑 바다 모두 좋습니다",
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}