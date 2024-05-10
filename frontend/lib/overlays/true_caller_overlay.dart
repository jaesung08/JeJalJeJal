// true_caller_overlay.dart
import 'dart:isolate'; // 별도의 Isolate를 사용하기 위한 import
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/databases/database.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';

class TrueCallerOverlay extends StatefulWidget {
  // 오버레이 위젯은 TranslationService를 주입받아 번역 데이터를 처리합니다
  final TranslationService translationService;

  const TrueCallerOverlay({Key? key, required this.translationService}) : super(key: key);

  @override
  _TrueCallerOverlayState createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool showIcon = true;
  bool showBox = false;

  List<Map<String, String>> translationPairs = [];
  final _databaseSavePort = ReceivePort(); // 데이터베이스 저장 작업을 위한 ReceivePort

  @override
  void initState() {
    super.initState();
    // widget.translationService.startWebSocketStream();
    // TranslationService의 outputStream을 구독합니다
    widget.translationService.outputStream.listen((translationData) async {
      setState(() {
        translationPairs.add({
          'jejuText': translationData.jeju,
          'translatedText': translationData.translated,
        });
      });
      await widget.translationService.saveTranslation(translationData);
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.translationService.stopWebSocketStream();
  }

  void stopWebSocketStream() {
    widget.translationService.stopWebSocketStream();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.0),
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
                updateOverlaySettings(showIcon);
              },
              child: Column(
                children: [
                  if (showIcon) TangerineIcon(),
                  if (showBox)
                    const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
          ),
          if (showBox) _buildBox(),
        ],
      ),
    );
  }

  Widget _buildBox() {
    return Positioned(
      top: 20.0, // 원하는 위치 조정 가능
      right: 10.0, // 원하는 위치 조정 가능
      child: Container(
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        width: 340.0,
        height: 450.0,
        decoration: BoxDecoration(
          color: Colors.orangeAccent.shade100,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "실시간 통역 중",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ...translationPairs.map((pair) => _buildTranslationPair(pair['jejuText']!, pair['translatedText']!)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationPair(String jejuText, String translatedText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(jejuText, style: TextStyle(fontSize: 18.0)),
              if (translatedText != "제잘") ...[
                Divider(),
                Text(translatedText, style: TextStyle(fontSize: 18.0)),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  void updateOverlaySettings(bool showIcon) async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
      await FlutterOverlayWindow.showOverlay(
        enableDrag: showIcon,
        height: showIcon ? 170 : 1300,
        width: showIcon ? 200 : 950,
        overlayTitle: "제잘제잘",
        overlayContent: "제주 방언 번역기",
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        // positionGravity: PositionGravity.auto,
        startPosition: const OverlayPosition(0, 25),
      );
    }
  }
}