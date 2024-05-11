// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/services/set_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:jejal_project/overlays/true_caller_overlay.dart';
import 'package:jejal_project/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final translationService = TranslationService();

  // 더미데이터 삽입
  await translationService.insertDummyData();
  // 앱 실행 시 MyApp 위젯 실행
  runApp(MyApp(translationService: translationService));
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
    runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(),
    ),
  );
}

class MyApp extends StatefulWidget {
  final TranslationService translationService;

  const MyApp({Key? key, required this.translationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: "Pretendard"
      ),
      home: HomePage(translationService: translationService),
    );
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //메인페이지 home_page.dart에 구현
      home: HomePage(translationService: TranslationService()),
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
    await _requestContactPermission(); // 연락처 권한 요청 추가
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

  // 연락처 권한 추가
  Future<void> _requestContactPermission() async {
    try {
      await Permission.contacts.request();
    } catch (e) {
      print('Error requesting contact permission: $e');
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