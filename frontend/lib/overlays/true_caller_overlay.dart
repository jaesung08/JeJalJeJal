import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TrueCallerOverlay extends StatefulWidget {
  const TrueCallerOverlay({Key? key}) : super(key: key);

  static void startWebSocketStream(WebSocketChannel wss) {
    _TrueCallerOverlayState._startWebSocketStream(wss);
  }

  @override
  _TrueCallerOverlayState createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool showIcon = true;
  bool showBox = false;
  final List<Map<String, String>> translationList = [];
  static WebSocketChannel? _webSocketChannel;

  static void _startWebSocketStream(WebSocketChannel wss) {
    _webSocketChannel = wss;
    print('wss 호출 성공!');

    _webSocketChannel?.stream.listen(
          (message) {
        print('Received message: $message');

        if (message is String) {
          final jsonData = jsonDecode(message);
          if (jsonData['isCallFinish'] == true) {
            _stopWebSocketStream();
          } else {
            try {
              final jejuText = jsonData['jeju'];
              final translatedText = jsonData['translated'];
              print('제주어: $jejuText, 번역된 텍스트: $translatedText');

              _TrueCallerOverlayState._instance?._addTranslation(
                {'jeju': jejuText, 'translated': translatedText},
              );
            } catch (e) {
              print('JSON 데이터 파싱 오류: $e');
            }
          }
        } else {
          print('예상치 못한 데이터 타입: ${message.runtimeType}');
        }
      },
      onError: (error) {
        print('웹소켓 스트림 오류: $error');
      },
      onDone: () {
        print('웹소켓 스트림 종료');
      },
    );
  }

  static _TrueCallerOverlayState? _instance;

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  void _addTranslation(Map<String, String> translation) {
    setState(() {
      translationList.add(translation);
    });
  }

  static void _stopWebSocketStream() {
    _webSocketChannel?.sink.close();
  }

  @override
  void dispose() {
    _stopWebSocketStream();
    super.dispose();
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
      top: 20.0,
      right: 10.0,
      child: Container(
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        width: 340.0,
        height: 450.0,
        decoration: BoxDecoration(
          color: Colors.orangeAccent.shade100,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: buildTranslationList(),
      ),
    );
  }

  Widget buildTranslationList() {
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "실시간 통역 중",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ...translationList.map((translation) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translation['jeju']!),
                if (translation['translated']! != "제잘")
                  Text(translation['translated']!),
                const SizedBox(height: 16.0),
              ],
            );
          }).toList(),
        ],
      ),
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
        startPosition: const OverlayPosition(0, 25),
      );
    }
  }
}