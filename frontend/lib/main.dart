// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/services/database_service.dart';
import 'package:jejal_project/services/set_stream.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:jejal_project/overlays/true_caller_overlay.dart';
import 'package:jejal_project/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databaseService = DatabaseService();

  await _requestPermissions();
  await _showOverlay();
  await requestOverlayPermission();
  await setStream();
  initPhoneStateListener();

  runApp(MyApp(databaseService: databaseService));
}

@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(),
    ),
  );
}

class MyApp extends StatefulWidget {
  final DatabaseService databaseService;

  const MyApp({Key? key, required this.databaseService}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
      home: HomePage(databaseService: DatabaseService()),
    );
  }
}

Future<void> _requestPermissions() async {
  await _requestCallPermission();
  await _requestContactPermission();
  await _requestStoragePermission();
  await _requestBackgroundPermission();
  await _requestSystemAlertWindowPermission();
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

Future<void> _requestSystemAlertWindowPermission() async {
  if (!await Permission.systemAlertWindow.isGranted) {
    await Permission.systemAlertWindow.request();
  }
}

Future<void> _requestContactPermission() async {
  try {
    await Permission.contacts.request();
  } catch (e) {
    print('Error requesting contact permission: $e');
  }
}

Future<void> _showOverlay() async {
  if (await FlutterOverlayWindow.isActive()) return;
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