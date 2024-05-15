import 'package:flutter/material.dart';
import 'package:jejal_project/models/file_result_model.dart';
import 'package:jejal_project/screens/home_screen.dart';
import '../services/database_service.dart';

class ResultDetailScreen extends StatelessWidget {
  final FileResultModel fileResult;


  ResultDetailScreen({Key? key, required this.fileResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fileResult == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('결과 없음'),
        ),
        body: Center(
          child: Text('파일 결과가 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '음성 파일 통역 결과',
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: fileResult.data!.segments!.length,
        itemBuilder: (context, index) {
          var segment = fileResult.data!.segments![index];
          bool hideTranslated = segment.translated == "제잘";  // "제잘"일 때 true
          print('39');
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

                if(hideTranslated) ...[
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
                    '통역할 제주어가 인식되지 않았습니다.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]

                //원본 텍스트가 제주어가 아니면 (번역 데이터가 "제잘"이 아니면) 아래 부분 출력
                else if (!hideTranslated) ...[

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
                    '통역 결과',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    segment.translated ?? 'No Translation',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
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
    print('40');

    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    var max = size.width;
    var dashWidth = 5.0;
    var dashSpace = 3.0;
    double startX = 0;
    while (startX < max) {
      print('41');

      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}