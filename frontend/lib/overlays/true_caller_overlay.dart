// true_caller_overlay.dart
import 'dart:convert';
import 'dart:isolate'; // 별도의 Isolate를 사용하기 위한 import
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/widgets/text_segment_box.dart';
import 'package:jejal_project/models/receive_message_model.dart';

class TrueCallerOverlay extends StatefulWidget {

  const TrueCallerOverlay({Key? key}) : super(key: key);

  @override
  _TrueCallerOverlayState createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  final DatabaseService _databaseService = DatabaseService();
  int _conversationId = 0;
  String? previousJejuText; // 이전 메시지의 jeju값을 저장할 변수 추가

  bool showIcon = true;
  bool showBox = false;

  List<ReceiveMessageModel> messages = [];

  @override
  void initState() {
    print('21');

    super.initState();
    print('22');

    //
    FlutterOverlayWindow.overlayListener.listen((newResult) async {
      var decodedResult = json.decode(newResult); // JSON 문자열을 디코드
      print('23');

      // 새 메시지를 리스트 앞에 추가
      ReceiveMessageModel message = ReceiveMessageModel.fromJson(decodedResult);
      setState(() {
        print('24');

        if(message.isTranslated) {
          // translated 값이 있는 경우
          // messages 리스트에서 jeju 값이 같고 translated가 null인 메시지를 찾아 업데이트
          var index = messages.lastIndexWhere((m) => m.jeju == message.jeju && !m.isTranslated);
          if(index != -1) {
            // 이전 메시지의 jeju 값과 현재 메시지의 jeju 값이 동일한 경우
            messages[index] = message; // 리스트의 첫번째 요소를 현재 메시지로 대체
          } else {
            messages.insert(0, message); // 새로운 메시지를 리스트 앞에 추가
          }
        } else {
          // translated 값이 null인 경우
          messages.insert(0, message); // 새로운 메시지를 리스트 앞에 추가
        }
        // previousJejuText = message.jeju; // 이전 메시지의 jeju 값을 업데이트
      });

      // 콘솔에 받아온 데이터 출력
      print('Received data from overlay window:');
      print('Jeju: ${decodedResult['jeju']}');
      print('Translated: ${decodedResult['translated']}');
      print('conversationId: $_conversationId' );
      print('---');

    });
  }

  @override
  Widget build(BuildContext context) {
    print('25');

    // 오버레이 위젯 UI Rntjd
    // 1. 아이콘 표시 (탭하면 박스 표시/숨김)
    // 2. 박스 표시 시 _buildBox() 호출
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

    // 실시간 통역 결과를 보여주는 박스 UI 구성
    // 1. 제주 방언 텍스트 표시
    // 2. 번역된 표준어 텍스트 표시
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
          reverse: true, // 최신 메시지를 맨 아래에 위치시키기 위해 reverse 사용
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "실시간 통역 중",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ...messages.map((message) => TextSegmentBox(
                jejuText: message.jeju ?? "No data",
                translatedText: message.isTranslated ? message.translated! : null,
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }


  void updateOverlaySettings(bool showIcon) async {
    print('27');

    // 오버레이 설정 업데이트(아이콘 표시 여부에 따라 크기 조정)
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
        // positionGravity: PositionGravity.auto,
        startPosition: const OverlayPosition(0, 25),
      );
    }
  }
}