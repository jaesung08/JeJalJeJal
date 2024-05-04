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
import 'overlays/true_caller_overlay.dart';
import 'package:jejal_project/screens/main_screen.dart';
import 'package:jejal_project/home_page.dart';


void main() {
  // 앱 실행 시 MyApp 위젯 실행
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      //메인페이지 home_page.dart에 구현
      home: HomePage(),
    );
  }

  @override
  void initState() {
    super.initState();
    // 필요한 권한 요청
    _requestPermissions();
    // 포그라운드 서비스 초기화 및 시작
    requestOverlayPermission();
    setStream();
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

