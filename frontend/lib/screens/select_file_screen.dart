import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:jejal_project/models/file_result_model.dart';

class SelectFileScreen extends StatefulWidget {
  const SelectFileScreen({Key? key, required this.databaseService}) : super(key: key);
  final DatabaseService databaseService;

  @override
  State<SelectFileScreen> createState() => _SelectStepScreen();
}

class _SelectStepScreen extends State<SelectFileScreen> {
  String? _filePath;
  bool isSending = false;
  FileResultModel? resultModel;

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
        'https://k10a406.p.ssafy.io/api/clovaspeech/upload', // Update your API endpoint
        data: formData,
      );

      if (response.statusCode == 200) {
        setState(() {
          resultModel = FileResultModel.fromJson(response.data);
          isSending = false; // Stop showing the spinner after getting the response
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
                  foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
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
