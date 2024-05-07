import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:jejal_project/databases/database.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


//메인에서 설정 눌렀을 때 호출된 위젯
class TrueCallerOverlay extends StatefulWidget {
  // 위젯의 생성자에 웹소켓 채널과 데이터베이스를 받아오도록 설정
  final WebSocketChannel channel;
  final JejalDatabase database;

  const TrueCallerOverlay({
    Key? key,
    required this.channel,
    required this.database,
  }) : super(key: key);

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  late TranslationService _translationService;
  bool showBox = false;

  @override
  void initState() {
    super.initState();
    _translationService = TranslationService(widget.channel, widget.database);
  }

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
