import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';

import '../style/color_style.dart';
import '../widgets/head_bar.dart';

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
        _filePath = "/storage/emulated/0/Recordings/Call";
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

    // Send data to backend
    // final response = await Dio().post(
    //   'http://k8a607.p.ssafy.io:8080/api/analysis/file',
    //   data: formData,
    // );
    // final jsonString = jsonEncode(response.data);
    // final json = jsonDecode(jsonString);
    // final resultModel = ResultModel.fromJson(json);

    // if (response.statusCode == 200) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             ResultScreenDetail(
    //               caseInfo: resultModel,
    //             )),
    //   );
    // } else if (response.statusCode == 201) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             ResultScreenDetailOK(
    //               caseInfo: resultModel,
    //             )),
    //   );
    // }

    // setState(() {
    //   result = response.toString();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeadBar(
        title: const Text(
          '녹음 파일 통역',
          style: TextStyle(
            fontSize: 18.0,
            color: ColorStyles.textBlack,
          ),
        ),
        appBar: AppBar(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              SizedBox(
                width: 230,
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
                                    color: ColorStyles.themeLightBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700
                                ))
                          },
                          style: const TextStyle(
                            color: ColorStyles.textDarkGray,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        StyledText(
                            text: isSend ? '분석 중 입니다' : '검사할 수 있습니다',
                            style: const TextStyle(
                              color: ColorStyles.textDarkGray,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      !isSend
                          ? 'assets/images/common_jeju.png'
                          : 'assets/images/common_mandarin.png',
                      height: 101,
                      width: 79,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 70),
              Visibility(
                visible: !isSend,
                child: ElevatedButton(
                  onPressed: _openFilePicker,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0)),
                  ),
                  child: Image.asset(
                    'assets/images/select_file.png',
                    height: 200,
                    width: 200,
                  ),
                ),
              ),
              Visibility(
                visible: isSend,
                child: const SizedBox(
                  height: 70,
                  child: CircularProgressIndicator(
                    strokeWidth: 18,
                    backgroundColor: Colors.black,
                    color: ColorStyles.themeLightBlue,
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
