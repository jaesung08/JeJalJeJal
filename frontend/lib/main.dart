import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = JejalDatabase();
  final channel = WebSocketChannel.connect(Uri.parse('ws://k8a607.p.ssafy.io:8080/record'));
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(channel: channel, database: database),
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
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _requestPermissions();
    await requestOverlayPermission();
    setStream();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //메인페이지 home_page.dart에 구현
      home: HomePage(database: widget.database),
    );
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

class FileResultModel {
  final double? score;
  final String? date;
  // category
  final int? type;
  final List<String>? words, sentences;
  final String? androidId;
  final String? phoneNumber;

  FileResultModel.toJson(Map<String, dynamic> json)
      : score = json['risk'] ?? 75.0,
        type = json['category'] ?? 0,
        date = json['createdTime'] ?? DateTime(2023).toString(),
        words = json['keyword'] != null
            ? List<String>.from(json['keyword'])
            : ['단어'],
        sentences = json['sentence'] != null
            ? List<String>.from(json['sentence'])
            : ['단어를 포함한 문장'],
        androidId = json['androidId'] ?? '',
        phoneNumber = json['phoneNumber'] ?? '';

  FileResultModel.fromJson(Map<String, dynamic> json)
      : score = json['result']?['totalCategoryScore'] ?? 75.0,
        type = json['result']?['totalCategory'] ?? 0,
        date = json['createdTime'] ?? DateTime.now().toString(),
        words = json['result']?['results'] != null &&
            json['result']?['results'].isNotEmpty
            ? List<String>.from(json['result']['results']
            .map((result) => result['sentKeyword']))
            : ['단어'],
        sentences = json['result']?['results'] != null &&
            json['result']?['results'].isNotEmpty
            ? List<String>.from(
            json['result']['results'].map((result) => result['sentence']))
            : ['단어를 포함한 문장'],
        androidId = json['androidId'] ?? '',
        phoneNumber = json['phoneNumber'] ?? '';
}
