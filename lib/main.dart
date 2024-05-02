import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:jejal_project/services/set_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_state/phone_state.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/services.dart';
import 'widgets/overlay_widget.dart';

void main() {
  // 앱 실행 시 MyApp 위젯 실행
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jejal Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Jejal Translator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String? _filePath;
  String? _recentFileName;
  Directory recordDir = Directory("/storage/emulated/0/Recordings/Call");
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 필요한 권한 요청
    _requestPermissions();
    // 포그라운드 서비스 초기화 및 시작
    initForegroundService();
    // 콜백 함수 시작
    startCallback();
    requestOverlayPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: OverlayWidget(),
        ),
      );
      Overlay.of(context)?.insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _requestPermissions() async {
    // 통화, 저장소, 백그라운드 권한 요청
    await _requestCallPermission();
    await _requestStoragePermission();
    await _requestBackgroundPermission();
    await _requestSystemAlertWindowPermission();
  }

  Future<void> initForegroundService() async {
    // 포그라운드 서비스 초기화
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
    // 포그라운드 서비스 시작
    startForegroundService();
  }

  void startForegroundService() {
    // 포그라운드 서비스 시작
    FlutterForegroundTask.startService(
        notificationTitle: '통화 녹음 진행 중',
        notificationText: '통화 녹음 및 처리 중...',
        callback: startCallback
    );
  }

  void startCallback() {
    // PhoneState.stream.listen() 설정
    setStream();
    // 통화 상태 변경 이벤트 수신
    PhoneState.stream.listen((event) {
      print("Phone state changed: ${event.status}"); // 추가된 부분
      if (event == PhoneStateStatus.CALL_STARTED) {
        // 통화 중 상태일 때 오버레이 표시
        _showOverlay();
      } else if (event == PhoneStateStatus.CALL_ENDED) {
        // 통화 종료 상태일 때 오버레이 제거
        _removeOverlay();
      }
    });
  }

  Future<void> _requestStoragePermission() async {
    // 저장소 권한 요청
    await Permission.storage.request();
  }

  Future<void> _requestCallPermission() async {
    // 통화 권한 요청
    await Permission.phone.request();
  }

  Future<void> _requestBackgroundPermission() async {
    // 백그라운드 권한 요청
    await Permission.backgroundRefresh.request();
  }

  Future<void> _requestSystemAlertWindowPermission() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      // 권한이 허용되지 않은 경우 권한 요청
      await Permission.systemAlertWindow.request();
    }
  }

  Future<void> _findRecentFile(Directory directory) async {
    // 최근 파일 검색
    var recent = await getRecentFile(directory);
    setState(() {
      _recentFileName = recent != null ? recent.path.split('/').last : "No files found";
    });
  }

  Future<FileSystemEntity?> getRecentFile(Directory recordDir) async {
    // 최근 파일 가져오기
    if (await recordDir.exists()) {
      var files = await recordDir.list().toList();
      if (files.isNotEmpty) {
        files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        return files.first;
      }
    }
    return null;
  }

  Future<void> requestOverlayPermission() async {
    const platform = MethodChannel('overlay_permission');
    try {
      final result = await platform.invokeMethod('requestOverlayPermission');
      if (result) {
        print('Overlay permission granted');
      } else {
        print('Overlay permission not granted');
      }
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 앱 UI 구성
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text('앱이 백그라운드에서 실행 중입니다.'),
      ),
    );
  }
}