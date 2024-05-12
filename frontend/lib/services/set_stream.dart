// lib/services/set_stream.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/services/recent_file.dart';
import 'package:phone_state/phone_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/receive_message_model.dart';
import '../models/send_message_model.dart';
import 'database_service.dart';

WebSocketChannel? ws;
String? phoneNumber;
Directory? recordDirectory;
Directory? testDirectory;
String? androidId;
const String recordDirectoryPath = "/storage/emulated/0/Recordings/Call";
File? targetFile;
File? testFile;
Timer? timer;
int offset = 0;
PhoneState? phoneStatus;
int? conversationId;

Future<void> setStream() async {
  const String testfilePath = "/storage/emulated/0/Recordings/test";
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  androidId = androidInfo.id;

  recordDirectory = Directory(recordDirectoryPath);
  testDirectory = Directory(testfilePath);
}

void initPhoneStateListener() {
  PhoneState.stream.listen((event) async {
    phoneStatus = event as PhoneState;
    if (event.status == PhoneStateStatus.CALL_INCOMING) {
      print("Incoming call detected.");
    } else if (event.status == PhoneStateStatus.CALL_STARTED) {
      print("Call started.");

      phoneNumber = phoneStatus!.number.toString();
      List<Contact>? contacts = await ContactsService.getContactsForPhone(phoneNumber!);
      String? name;

      if (contacts != null && contacts.isNotEmpty) {
        name = contacts.first.displayName;
      } else {
        name = "제주도민";
      }

      conversationId = await DatabaseService.instance.insertConversation(phoneNumber!, name!);
      print("전화온 번호: $phoneNumber");
      print("상대방 이름: $name");

      ws = WebSocketChannel.connect(
        Uri.parse('wss://k10a406.p.ssafy.io/api/record'),
      );

      var startMessage = SendMessageModel(
        state: 0,
        androidId: androidId!,
      );
      ws?.sink.add(jsonEncode(startMessage));

      var temp = await recentFile(recordDirectory!);
      targetFile = temp is FileSystemEntity ? temp as File : null;

      offset = 0;
      if (targetFile is File) {
        print("파일 찾음");
        print(targetFile?.path);
        timer = Timer.periodic(const Duration(seconds: 6), (timer) async {
          Uint8List entireBytes = targetFile!.readAsBytesSync();
          var nextOffset = entireBytes.length;

          var splittedBytes = entireBytes.sublist(offset, nextOffset);
          offset = nextOffset;
          print(splittedBytes);

          ws?.sink.add(splittedBytes);
        });
      } else {
        print("파일 못찾음");
        ws?.sink.close();
      }

      ws?.stream.listen((msg) async {
        if (msg != null) {
          ReceiveMessageModel receivedResult = ReceiveMessageModel.fromJson(jsonDecode(msg));
          receivedResult.conversationId = conversationId;
          FlutterOverlayWindow.shareData(msg);
          await DatabaseService.instance.insertMessage(receivedResult, conversationId!);
        }
      });
    } else if (event.status == PhoneStateStatus.CALL_ENDED) {
      print("Call ended.");

      timer?.cancel();
      Uint8List entireBytes = targetFile!.readAsBytesSync();
      var nextOffset = entireBytes.length;
      var splittedBytes = entireBytes.sublist(offset, nextOffset);
      offset = nextOffset;

      print("마지막 데이터");
      print(splittedBytes);

      ws?.sink.add(splittedBytes);

      var endMessage = SendMessageModel(
        state: 1,
        androidId: androidId!,
        phoneNumber: phoneNumber!,
      );
      ws?.sink.add(jsonEncode(endMessage));
    }
  });
}