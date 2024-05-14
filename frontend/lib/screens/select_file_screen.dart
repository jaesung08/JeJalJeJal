import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jejal_project/models/file_result_model.dart';

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
      recentFiles = files.take(5).toList(); // Take the most recent 5 files
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
        });
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
      appBar: AppBar(
        title: Text('음성 파일 통역'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            if (isSending) ...[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('통화 음성 파일을 통역 중입니다...'),
            ] else if (resultModel != null) ...[
              _buildResultDisplay(),
            ] else ...[
              ElevatedButton(
                onPressed: _openFilePicker,
                child: Text('파일 선택'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: recentFiles.length,
                  itemBuilder: (context, index) {
                    final file = recentFiles[index];
                    return ListTile(
                      title: Text(file.path.split('/').last),
                      subtitle: Text(FileStat.statSync(file.path).changed.toString()),
                      onTap: () {
                        setState(() {
                          _filePath = file.path;
                          isSending = true;
                        });
                        _sendFile();
                      },
                    );
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
    return Column(
      children: resultModel!.data!.segments!.map((segment) {
        return ListTile(
          title: Text(segment.jeju ?? 'No Jeju Text'),
          subtitle: Text(segment.translated ?? 'No Translation'),
        );
      }).toList(),
    );
  }
}
