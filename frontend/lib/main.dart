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
  print('102');

  WidgetsFlutterBinding.ensureInitialized();
  print('103');

  final databaseService = DatabaseService();
  print('104');

  await _requestPermissions();
  await _showOverlay();
  await requestOverlayPermission();
  await setStream();
  initPhoneStateListener();
  print('105');

  runApp(MyApp(databaseService: databaseService));
  print('106');

}

@pragma("vm:entry-point")
void overlayMain() {
  print('107');

  // WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(),
    ),
  );
  print('108');

}

class MyApp extends StatefulWidget {
  final DatabaseService databaseService;

  const MyApp({Key? key, required this.databaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('109');

    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
      home: HomePage(databaseService: databaseService),
    );
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    print('110');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(databaseService: DatabaseService()),
    );
  }

  @override
  void initState() {
    print('111');
    super.initState();
  }
}

Future<void> _requestPermissions() async {
  print('112');

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
  print('113');

  if (await FlutterOverlayWindow.isActive()) return;
}

Future<void> requestOverlayPermission() async {
  print('114');

  const platform = MethodChannel('overlay_permission');
  try {
    print('115');

    final result = await platform.invokeMethod('requestOverlayPermission');
    if (result) {
      print('116');

      print('Overlay permission granted');
    } else {
      print('117');

      print('Overlay permission not granted');
    }
  } on PlatformException catch (e) {
    print('118');
    print('Error: ${e.message}');
  }
}