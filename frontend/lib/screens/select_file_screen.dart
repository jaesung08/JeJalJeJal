import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../widgets/head_bar.dart';
import 'result_detail_screen.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';
import 'package:jejal_project/models/file_result_model.dart';
import 'package:jejal_project/style/color_style.dart';


class SelectFileScreen extends StatefulWidget {
  const SelectFileScreen({Key? key}) : super(key: key);

  @override
  State<SelectFileScreen> createState() => _SelectFileScreenState();
}

class _SelectFileScreenState extends State<SelectFileScreen> {
  String? _filePath;
  String result = "a";
  int counter = 0;
  bool isSend = false;

  late String androidId;

  @override
  void initState() {
    super.initState();
    initializer();
  }

  void initializer() async {
    // Get Android ID
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    androidId = androidInfo.id;

    setState(() {
      isSend = false;
    });
  }

  Future<void> _openFilePicker() async {
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles();
    if (fileResult != null) {
      setState(() {
        _filePath = fileResult.files.single.path;
        counter = counter + 1;
        isSend = true;
      });
      _sendFile();
    }
  }

  void _sendFile() async {
    final file = File(_filePath!);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'androidId': androidId,
    });

    try {
      final response = await Dio().post(
        'https://k10a406.p.ssafy.io/api/clovaspeech/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final resultModel = FileResultModel.fromJson(response.data);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultDetailScreen(fileResult: resultModel)),
        );
      }
    } on DioError catch (e) {
      setState(() {
        isSend = false;
      });
      final errorMessage = e.response != null ? e.response!.data.toString() : e.message;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to upload file: $errorMessage'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '음성 파일 통역',
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(
                          text: '<b>통화 음성 파일</b>을',
                          tags: {
                            'b': StyledTextTag(
                                style: const TextStyle(
                                    color: ColorStyles.themeOrange,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700
                                ))
                          },
                          style: const TextStyle(
                            color: ColorStyles.textDarkGray,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        //파일이 선택됐는지 여부에 따라 다르게 출력
                        StyledText(
                            text: isSend ? '통역 중 입니다' : '통역할 수 있습니다',
                            style: const TextStyle(
                              color: ColorStyles.textDarkGray,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),

                    const SizedBox(width: 12),

                    //파일이 선택됐는지 여부에 따라 다르게 출력
                    Image.asset(
                      !isSend
                          ? 'assets/images/file.png'
                          : 'assets/images/translating.png',
                      height: 101,
                      width: 79,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              //파일 선택 전 보여질 이미지
              Visibility(
                visible: !isSend,
                child: GestureDetector(
                  onTap: _openFilePicker,
                  child: Image.asset(
                    'assets/images/select_file.png',
                    height: 280,
                    width: 280,
                  ),
                ),
              ),

              //파일 선택 후 보여질 로딩 스피너 (api 호출 후 요청 기다릴 때)
              Visibility(
                visible: isSend,
                child: const SizedBox(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(
                    strokeWidth: 18,
                    backgroundColor: Colors.black,
                    color: ColorStyles.themeOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
