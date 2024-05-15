import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jejal_project/models/file_result_model.dart';
import 'package:jejal_project/screens/result_detail_screen.dart';

import 'history_chat_screen.dart';

const String recordDirectoryPath = "/storage/emulated/0/Recordings/Call";

class SelectFileScreen extends StatefulWidget {
  const SelectFileScreen({Key? key}) : super(key: key);

  @override
  State<SelectFileScreen> createState() => _SelectFileState();
}

class _SelectFileState extends State<SelectFileScreen> {
  String? _filePath;
  bool isSending = false;
  FileResultModel? resultModel;
  Directory recordDirectory = Directory(recordDirectoryPath);
  List<File> recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    // Load and sort files by modification date
    var files = recordDirectory.listSync()
        .whereType<File>()
        .toList();
    files.sort((a, b) => b.statSync().changed.compareTo(a.statSync().changed)); // Sort by modified time descending
    setState(() {
      recentFiles = files.take(8).toList(); // Take the most recent 5 files
    });
  }

  void _openFilePicker() async {
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles();
    if (fileResult != null) {
      setState(() {
        _filePath = fileResult.files.single.path;
        isSending = true;
      });
      _sendFile();
    }
  }

  void _sendFile() async {
    if (_filePath == null) return;
    final file = File(_filePath!);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    try {
      final response = await Dio().post(
        'https://k10a406.p.ssafy.io/api/clovaspeech/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        setState(() {
          resultModel = FileResultModel.fromJson(response.data);
          isSending = false;
          // resultModel이 null이 아니면 ResultDetailScreen으로 이동

        });
      } else {
        // 에러 처리
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isSending = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to upload file: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSending) ...[
              Image.asset('assets/images/file_wait.gif')
                ]
            else if (resultModel != null) ...[
              _buildResultDisplay(),
            ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10) ,
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "파일 통역을 원한다면!",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "통역을 원하는",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "음성 파일을 선택해주세요",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10) ,
                      child: ElevatedButton(
                        onPressed: _openFilePicker,
                        child: Text('파일 선택'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\u{1F4C1} 파일 통역 체험해봐요!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "최근 통화 녹음 파일",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                ),
              //녹음 파일 다섯개 목록
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: recentFiles.length,
                  itemBuilder: (context, index) {
                    final file = recentFiles[index];
                    return
                      Card( child: ListTile(
                        title: Text(file.path.split('/').last, style: TextStyle(fontSize: 13)),
                        subtitle: Text(FileStat.statSync(file.path).changed.toString()),
                        onTap: () {
                          setState(() {
                            _filePath = file.path;
                            isSending = true;
                          });
                          _sendFile();
                        },
                    ));
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 30.0),
            child: Text(
              '파일 통역 결과',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: resultModel?.data?.segments?.length ?? 0,
              itemBuilder: (context, index) {
                var segment = resultModel?.data?.segments?[index];
                bool hideTranslated = segment?.translated == "제잘";
                return Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(segment?.jeju ?? 'No Jeju Text', style: TextStyle(color: Colors.black, fontSize: 14.0)),
                      if (hideTranslated) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CustomPaint(painter: DashedLinePainter(), child: Container(height: 1, width: double.infinity)),
                        ),
                        Text('통역할 제주어가 인식되지 않았습니다.', style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w600)),
                      ],
                      if (!hideTranslated) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CustomPaint(painter: DashedLinePainter(), child: Container(height: 1, width: double.infinity)),
                        ),
                        Text(segment?.translated ?? 'No Translation', style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          // 파일 다시 선택하기 버튼
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  resultModel = null;  // 상태 초기화
                });
              }, // 파일 선택 전 화면으로 리셋
              child: Text('파일 다시 선택하기'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }



}
