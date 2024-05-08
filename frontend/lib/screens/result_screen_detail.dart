import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';
import '../models/file_result_model.dart';  // 모델 import 경로 확인 필요
import 'package:jejal_project/style/color_style.dart';  // 색상 스타일 import 경로 확인 필요

class ResultScreenDetail extends StatefulWidget {
  final FileResultModel caseInfo;

  const ResultScreenDetail({super.key, required this.caseInfo});

  @override
  State<ResultScreenDetail> createState() => _ResultScreenDetailState();
}

class _ResultScreenDetailState extends State<ResultScreenDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          const roundedRectangleBorder = RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          );

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 29),
                    const Text(
                      '통역 결과',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            shape: roundedRectangleBorder,
                            elevation: 0,
                            color: ColorStyles.background,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: SizedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.caseInfo.sentences!.map((sentence) => Padding(
                                    padding: const EdgeInsets.only(bottom: 30),
                                    child: StyledText(
                                      text: sentence,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: ColorStyles.textDarkGray,
                                          fontSize: 15
                                      ),
                                      tags: {
                                        'b': StyledTextTag(
                                            style: const TextStyle(
                                                color: ColorStyles.themeLightBlue,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700
                                            )
                                        )
                                      },
                                    ),
                                  )).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
