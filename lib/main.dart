import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    await Permission.storage.request();
  }

  Future<void> _pickDirectory(BuildContext context) async {
    Directory initialDirectory = await Directory("/storage/emulated/0/Recordings/Call") ?? await getTemporaryDirectory();

    Directory? newDirectory = await FolderPicker.pick(
        allowFolderCreation: true,
        context: context,
        rootDirectory: initialDirectory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
    );

    if (newDirectory != null) {
      _filePath = newDirectory.path;
      _findRecentFile(newDirectory);
    }
  }

  Future<void> _findRecentFile(Directory directory) async {
    FileSystemEntity? recent = await getRecentFile(directory); // Rename function to avoid conflict and confusion
    setState(() {
      _recentFileName = recent != null ? recent.path.split('/').last : "No files found";
    });
  }

  Future<FileSystemEntity?> getRecentFile(Directory recordDir) async {
    if (await recordDir.exists()) {
      List<FileSystemEntity> files = await recordDir.list().toList();
      if (files.isNotEmpty) {
        files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        return files.first; // Directly return the first file if list is not empty
      }
    }
    return null; // Return null if directory does not exist or no files are found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _pickDirectory(context),
              child: const Text('Open Folder Picker'),
            ),
            if (_filePath != null) Text('Selected folder: $_filePath'),
            if (_recentFileName != null) Text('Recent file: $_recentFileName'),
          ],
        ),
      ),
    );
  }
}

Future<FileSystemEntity?> recentFile(Directory recordDir) async {
  FileSystemEntity? target;
  if (await recordDir.exists()) {
    List<FileSystemEntity> files = await recordDir.list().toList();
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    target = files.isNotEmpty ? files.first : null;
  } else {
    target = null;
  }
  return target;
}
