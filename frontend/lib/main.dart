import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jejal_project/home_page.dart';
import 'package:jejal_project/databases/database.dart';
import 'package:jejal_project/services/set_stream.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = JejalDatabase();
  runApp(MyApp(database: database));
}

class MyApp extends StatefulWidget {
  final JejalDatabase database;

  const MyApp({Key? key, required this.database}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    requestOverlayPermission();
    setStream(widget.database);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(database: widget.database),
    );
  }

  Future<void> _requestPermissions() async {
    await _requestCallPermission();
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