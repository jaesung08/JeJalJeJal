import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';

class TrueCallerOverlay extends StatefulWidget {
  final TranslationService translationService;

  const TrueCallerOverlay({Key? key, required this.translationService})
      : super(key: key);

  @override
  _TrueCallerOverlayState createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  List<Map<String, String>> translationPairs = [];

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(12.0),
      child: Stack(
        children: [
          Positioned(
            top: 0.0,
            right: 10.0,
            child: IconButton(
              onPressed: () async {
                await FlutterOverlayWindow.closeOverlay();
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
          _buildBox(),
        ],
      ),
    );
  }

  Widget _buildBox() {
    return Positioned(
      top: 40.0, // 원하는 위치 조정 가능
      right: 10.0, // 원하는 위치 조정 가능
      child: Container(
        margin: const EdgeInsets.only(top: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        width: 340.0,
        height: 250.0,
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
}
