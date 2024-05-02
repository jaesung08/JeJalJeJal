import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:jejal_project/services/set_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_state/phone_state.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

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
    _requestPermissions();
    initForegroundService();
    startCallback();
  }

  Future<void> _requestPermissions() async {
    await _requestCallPermission();
    await _requestStoragePermission();
    await _requestBackgroundPermission();
  }

  Future<void> initForegroundService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'channel_id',
        channelName: 'Foreground Service',
        channelDescription: 'This channel is used for important notifications.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
    );
    startForegroundService();
  }

  void startForegroundService() {
    FlutterForegroundTask.startService(
        notificationTitle: '통화 녹음 진행 중',
        notificationText: '통화 녹음 및 처리 중...',
        callback: startCallback
    );
  }

  void startCallback() {
    // PhoneState.stream.listen() 설정
    setStream();
  }

  Future<void> _requestStoragePermission() async {
    await Permission.storage.request();
  }

  Future<void> _requestCallPermission() async {
    await Permission.phone.request();
  }

  Future<void> _requestBackgroundPermission() async {
    await Permission.backgroundRefresh.request();
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
