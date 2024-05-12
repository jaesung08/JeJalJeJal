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
  print('69');

  const String testfilePath = "/storage/emulated/0/Recordings/test";
  print('70');

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  print('71');

  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print('72');


  androidId = androidInfo.id;

  recordDirectory = Directory(recordDirectoryPath);
  print('73');

  testDirectory = Directory(testfilePath);
  print('74');

}

void initPhoneStateListener() {
  PhoneState.stream.listen((event) async {
    print('상태 변경 감지: ${event.status}');
    phoneStatus = event as PhoneState;

    if (event.status == PhoneStateStatus.CALL_STARTED) {
      if (phoneStatus!.number?.isNotEmpty ?? false) {
        phoneNumber = phoneStatus!.number.toString();
        print('통화 시작됨.');
        print('전화 번호: $phoneNumber');

        List<Contact>? contacts = await ContactsService.getContactsForPhone(phoneNumber!);
        String? name;

        if (contacts != null && contacts.isNotEmpty) {
          name = contacts.first.displayName;
        } else {
          name = "제주도민";
        }

        conversationId = await DatabaseService.instance.insertConversation(phoneNumber!, name!);
        print('상대방 이름: $name');

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

        if (targetFile is File) {
          print('파일 찾음: ${targetFile?.path}');
          timer = Timer.periodic(const Duration(seconds: 6), (timer) async {
            Uint8List entireBytes = targetFile!.readAsBytesSync();
            var nextOffset = entireBytes.length;

            var splittedBytes = entireBytes.sublist(offset, nextOffset);
            offset = nextOffset;
            print('전송 데이터: $splittedBytes');

            ws?.sink.add(splittedBytes);
          });
        } else {
          print('파일 못 찾음.');
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
      } else {
        print('전화 번호가 감지되지 않음.');
      }
    } else if (event.status == PhoneStateStatus.CALL_ENDED) {
      print('통화 종료.');

      timer?.cancel();
      if (targetFile != null) {
        Uint8List entireBytes = targetFile!.readAsBytesSync();
        var nextOffset = entireBytes.length;
        var splittedBytes = entireBytes.sublist(offset, nextOffset);
        offset = nextOffset;
        print('마지막 데이터: $splittedBytes');

        ws?.sink.add(splittedBytes);
      }

      var endMessage = SendMessageModel(
        state: 1,
        androidId: androidId!,
        phoneNumber: phoneNumber!,
      );

      ws?.sink.add(jsonEncode(endMessage));
      ws?.sink.close();
    }
  });
}
