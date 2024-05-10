import 'package:flutter/material.dart';
import 'package:jejal_project/models/file_result_model.dart';

class ResultDetailScreen extends StatelessWidget {
  final FileResultModel fileResult;

  // final FileResultModel fileResult = FileResultModel.fromJson({
  //   "status": 200,
  //   "message": "clova speech 통신 완료",
  //   "data": {
  //     "segments": [
  //       {
  //         "jeju": "원래 우리가 큰아이 제대하고 조금 시험 끝난 방학 때구나 방학 때구나 방학 때",
  //         "translated": "원래 우리가 큰 아이 제대하고 조금 시험 끝난 방학 때구나."
  //       },
  //       {
  //         "jeju": "우리 큰아들하고 한 4개월 같이 4개월 5개월 같이 있었고 좋은 아들하고 2개월 같이 있어 같이 있는 거라 나 진짜 어마장장하게 바빴거든.",
  //         "translated": "제잘",
  //         // "translated": "우리 큰 아들하고 한 4~5개월 정도 같이 있었고, 좋은 아들하고는 2개월 정도 같이 있었어요. 그래서 저는 정말 엄청나게 바빴어요."
  //       },
  //       {
  //         "jeju": "엄청 먹어마장장 너네 큰아들 많이 먹잖아 헤드에도 돌아서면 봐 돌아서면 봐",
  //         "translated": "엄청 먹어서 네 큰 아들 많이 먹잖아 머리에도 돌아서면 배고프다고 하잖아"
  //       },
  //       {
  //         "jeju": "요즘 우리 딸내미가 인사 많지 걱정이라",
  //         "translated": "요즘 우리 딸이 인사를 잘 안 해서 걱정이에요."
  //       },
  //       {
  //         "jeju": "170이 100형이 그냥 돌아서 나 어마마마의",
  //         "translated": "입력하신 내용은 제주도 사투리로 되어 있어, 이를 표준어로 번역하면 다음과 같습니다.\n\n\"170이 100형이 그냥 돌아서 나 어마마마의\"\n\n위 문장은 의미가 명확하지 않아 정확한 번역이 어렵습니다. 추가적인 정보나 문맥을 제공해주시면 더 정확한 번역을 할 수 있습니다."
  //       },
  //       {
  //         "jeju": "짜증 안 납디가 나는 어떨 때 막 너무 짜증 난 마지",
  //         "translated": "화가 나지 않던가요? 저는 어떤 때에는 정말 너무 화가 나기도 합니다"
  //       },
  //       {
  //         "jeju": "짜증 나지 근데 아들이 많이 먹어가면 아방도 같이 들어가.",
  //         "translated": "화가 나지만 아이들이 많이 먹으면 아버지도 함께 들어가요."
  //       }
  //     ]
  //   }
  // });

  ResultDetailScreen({Key? key, required this.fileResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('음성 파일 통역 결과'),
      ),
      body: ListView.builder(
        itemCount: fileResult.data!.segments!.length,
        itemBuilder: (context, index) {
          var segment = fileResult.data!.segments![index];
          bool hideTranslated = segment.translated == "제잘";  // "제잘"일 때 true

          return Container(
            width: MediaQuery.of(context).size.width * 0.7,
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //원본 텍스트 (제주어)
                Text(
                  segment.jeju ?? 'No Jeju Text',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),

                //원본 텍스트가 제주어가 아니면 (번역 데이터가 "제잘"이 아니면) 아래 부분 출력
                if (!hideTranslated) ...[

                  //점선
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomPaint(
                      painter: DashedLinePainter(),
                      child: Container(
                        height: 1,
                        width: double.infinity,
                      ),
                    ),
                  ),

                  Text(
                    segment.translated ?? 'No Translation',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}

//점선 구현
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    var max = size.width;
    var dashWidth = 5.0;
    var dashSpace = 3.0;
    double startX = 0;
    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}