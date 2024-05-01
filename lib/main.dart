import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:jejal_project/services/set_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_state/phone_state.dart';

void main() {
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'File Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _filePath;
  String? _recentFileName;
  Directory recordDir = Directory("/storage/emulated/0/Recordings/Call");
  PhoneState? phoneState;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
    setStream();
  }

  Future<void> _requestStoragePermission() async {
    await Permission.storage.request();
  }

  Future<void> _findRecentFile(Directory directory) async {
    var recent = await getRecentFile(directory);
    setState(() {
      _recentFileName = recent != null ? recent.path.split('/').last : "No files found";
    });
  }

  Future<FileSystemEntity?> getRecentFile(Directory recordDir) async {
    if (await recordDir.exists()) {
      var files = await recordDir.list().toList();
      if (files.isNotEmpty) {
        files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        return files.first;
      }
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (phoneState != null) ...[
              Text("Phone State: ${phoneState!.status}"),
              Text("Phone Number: ${phoneState!.number ?? 'Unknown'}"),
              Divider(),
              Text("Recent File: $_recentFileName"),
            ],
            Text("Application is running..."),
          ],
        ),
      ),
    );
  }
}



