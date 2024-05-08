import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/overlays/tangerine_icon.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:web_socket_channel/src/channel.dart';
import 'package:jejal_project/widgets/text_segment_box.dart';

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

  // Widget _buildBox() {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 10.0),
  //     padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
  //     width: 340.0,
  //     height: 480.0,
  //     decoration: BoxDecoration(
  //       color: Colors.orangeAccent.shade100,
  //       borderRadius: BorderRadius.circular(12.0),
  //     ),
  //     child: SingleChildScrollView(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "실시간 통역 중",
  //             style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
  //           ),
  //           Divider(),
  //           Text(
  //             "어떻게 살고 있습니까?",
  //             style: TextStyle(fontSize: 18.0),
  //           ),
  //           SizedBox(height: 8.0),
  //           Text(
  //             "저는 그럭저럭 지내고 있습니다.",
  //             style: TextStyle(fontSize: 18.0),
  //           ),
  //           SizedBox(height: 8.0),
  //           Text(
  //             "산이영 바당이영 문딱 좋은게 마씀",
  //             style: TextStyle(fontSize: 18.0),
  //           ),
  //           SizedBox(height: 8.0),
  //           Text(
  //             "산이랑 바다 모두 좋습니다",
  //             style: TextStyle(fontSize: 18.0),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  Widget _buildBox() {

    final List<Map<String, dynamic>> segments = [
      {
        "jeju": "원래 우리가 큰아이 제대하고 조금 시험 끝난 방학 때구나 방학 때구나 방학 때",
        "translated": "원래 우리가 큰 아이 제대하고 조금 시험 끝난 방학 때구나."
      },
      {
        "jeju": "우리 큰아들하고 한 4개월 같이 4개월 5개월 같이 있었고 좋은 아들하고 2개월 같이 있어 같이 있는 거라 나 진짜 어마장장하게 바빴거든.",
        "translated": "제잘",
        // "translated": "우리 큰 아들하고 한 4~5개월 정도 같이 있었고, 좋은 아들하고는 2개월 정도 같이 있었어요. 그래서 저는 정말 엄청나게 바빴어요."
      },
      {
        "jeju": "엄청 먹어마장장 너네 큰아들 많이 먹잖아 헤드에도 돌아서면 봐 돌아서면 봐",
        "translated": "엄청 먹어서 네 큰 아들 많이 먹잖아 머리에도 돌아서면 배고프다고 하잖아"
      },
      {
        "jeju": "요즘 우리 딸내미가 인사 많지 걱정이라",
        "translated": "요즘 우리 딸이 인사를 잘 안 해서 걱정이에요."
      },
      {
        "jeju": "170이 100형이 그냥 돌아서 나 어마마마의",
        "translated": "입력하신 내용은 제주도 사투리로 되어 있어, 이를 표준어로 번역하면 다음과 같습니다.\n\n\"170이 100형이 그냥 돌아서 나 어마마마의\"\n\n위 문장은 의미가 명확하지 않아 정확한 번역이 어렵습니다. 추가적인 정보나 문맥을 제공해주시면 더 정확한 번역을 할 수 있습니다."
      },
      {
        "jeju": "짜증 안 납디가 나는 어떨 때 막 너무 짜증 난 마지",
        "translated": "화가 나지 않던가요? 저는 어떤 때에는 정말 너무 화가 나기도 합니다"
      },
      {
        "jeju": "짜증 나지 근데 아들이 많이 먹어가면 아방도 같이 들어가.",
        "translated": "화가 나지만 아이들이 많이 먹으면 아버지도 함께 들어가요."
      }
    ];

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