// true_caller_overlay.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/widgets/text_segment_box.dart';
import 'package:jejal_project/widgets/loading_text.dart';
import 'package:jejal_project/models/receive_message_model.dart';

class TrueCallerOverlay extends StatefulWidget {
  const TrueCallerOverlay({Key? key}) : super(key: key);

  @override
  _TrueCallerOverlayState createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  bool showIcon = true;
  bool showBox = false;

  List<ReceiveMessageModel> messages = [];
  int currentIndex = -1;

  @override
  void initState() {
    print('1. 오버레이 initState 호출');
    super.initState();
    print('22');

    FlutterOverlayWindow.overlayListener.listen((newResult) async {
      setState(() {
        if (newResult == '{"clear":true}') {
          messages.clear();
          currentIndex = -1;
          print('2. 메시지 초기화 확인');
        } else {
          var decodedResult = json.decode(newResult);
          print('3. 수신 데이터 확인: $decodedResult');

          ReceiveMessageModel newMessage =
              ReceiveMessageModel.fromJson(decodedResult);
          print('4. 새 메시지 확인: ${newMessage.jeju}, ${newMessage.translated}');

          if (newMessage.translated == "wait") {
            currentIndex++;
            messages.add(newMessage);
            print('5. 새 메시지 추가 확인: ${newMessage}');
            print('"wait" 메시지 도착 시간 출력: ${DateTime.now()}');
            _scrollToBottom(); // 새 메시지 추가 후 스크롤 위치 이동
          } else {
            int existingIndex = messages.indexWhere((message) =>
                message.jeju == newMessage.jeju &&
                message.translated == "wait");
            print('6. 기존 메시지 인덱스 확인: $existingIndex');

            if (existingIndex != -1) {
              messages[existingIndex] = messages[existingIndex].copyWith(
                translated: newMessage.translated,
              );
              print(
                  '7. 인덱스 $existingIndex에 맞는 메시지 업데이트 확인: ${newMessage.isTranslated}');
              print('번역된 메시지 도착 시간 출력: ${DateTime.now()}'); // 번역된 메시지 도착 시간 출력
              _scrollToBottom(); // 메시지 업데이트 후 스크롤 위치 이동
            }
          }

          if (newResult != '{"clear":true}') {
            print('Received data from overlay window:');
            print('Jeju: ${decodedResult['jeju']}');
            print('Translated: ${decodedResult['translated']}');
            print('---');
          }
        }
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('25');

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
    print('26');

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoadingText(text: "실시간 통역 중"),
              // Text(
              //   "실시간 통역 중",
              //   style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              // ),
              Divider(),
              ...messages
                  .map((message) => TextSegmentBox(
                        jejuText: message.jeju ?? "No data",
                        translatedText: message.translated,
                        isLoading: message.translated == "wait",
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  void updateOverlaySettings(bool showIcon) async {
    print('27');

    if (await FlutterOverlayWindow.isActive()) {
      print('28');

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
