import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';
import 'package:jejal_project/services/translation_service.dart';

class TrueCallerOverlay extends StatefulWidget {
  final TranslationService translationService;

  const TrueCallerOverlay({Key? key, required this.translationService})
      : super(key: key);

  @override
  _TrueCallerOverlayState createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool showIcon = true;
  bool showBox = false;
  List<Map<String, String>> translationPairs = []; // 제주방언과 표준어 같이 받는 배열리스트

  @override
  void initState() {
    super.initState();
    // TranslationService의 outputStream을 listen하여 번역 데이터를 받아오고 화면을 업데이트
    // 웹소켓을 통해 데이터가 도착하면 자동으로 outputStream으로 전달되고, 이를 TrueCallerOverlay에서 구독하여 처리
    widget.translationService.outputStream.listen((translationData) async {
      // 화면 업데이트
      setState(() {
        translationPairs.add({
          'jejuText': translationData.jeju,
          'translatedText': translationData.translated,
        });
      });

      // 백그라운드 작업자에서 데이터베이스 저장 작업 실행
      await widget.translationService.saveTranslation(translationData);
    });
  }

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
                // 아이콘 또는 박스 표시 상태를 토글
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
        reverse: true, // 최신 데이터가 맨 아래에 표시되도록 설정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "실시간 통역 중",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Divider(),
            // translationPairs를 역순으로 순회하며 말풍선 생성
            ...translationPairs.map((pair) => _buildTranslationPair(pair['jejuText']!, pair['translatedText']!)).toList(),
          ],
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
}