import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/databases/database.dart';
import 'package:jejal_project/services/set_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_state/phone_state.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'overlays/true_caller_overlay.dart';
import 'package:jejal_project/home_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = JejalDatabase();
  // 앱 실행 시 MyApp 위젯 실행
  runApp(MyApp(database: database));
}

@pragma("vm:entry-point")
void overlayMain() { // 오버레이 앱의 진입점으로, TrueCallerOverlay 위젯을 실행
  WidgetsFlutterBinding.ensureInitialized(); // 플러터 바인딩 초기화
  final database = JejalDatabase();
  final channel = WebSocketChannel.connect(Uri.parse('ws://k8a607.p.ssafy.io:8080/record'));
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(channel: channel, database: database), // TrueCaller 오버레이 위젯 실행
    ),
  );
}

class MyApp extends StatefulWidget {
  final JejalDatabase database;

  const MyApp({Key? key, required this.database}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //메인페이지 home_page.dart에 구현
      home: HomePage(database: widget.database),
    );
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _showOverlay();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // await _requestPermissions();
    // await _showOverlay();
    await requestOverlayPermission();
    setStream();
  }

  // 오버레이 실행을 위한 메서드
  Future<void> _showOverlay() async {
    // 오버레이가 이미 활성화되어 있는지 확인
    if (await FlutterOverlayWindow.isActive()) return;

    // 오버레이 표시
    // await FlutterOverlayWindow.showOverlay(
    //   enableDrag: true,
    //   overlayTitle: "제주 방언 번역기",
    //   overlayContent: 'Overlay Enabled',
    //   flag: OverlayFlag.defaultFlag,
    //   // visibility 파라미터를 삭제하거나 대체함
    //   positionGravity: PositionGravity.auto,
    //   height: (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * 1.6).toInt(),
    //   // width: WindowSize.matchParent,
    //   width: (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width * 2.2).toInt(),
    //   startPosition: const OverlayPosition(0, 20),
    // );
  }

  Future<void> _requestPermissions() async {
    // 통화, 저장소, 백그라운드 권한 요청
    await _requestCallPermission();
    await _requestStoragePermission();
    await _requestBackgroundPermission();
    await _requestSystemAlertWindowPermission();
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
}