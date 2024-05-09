import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/services/recent_file.dart';
import 'package:phone_state/phone_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:jejal_project/databases/database.dart';
import 'package:drift/drift.dart';
import 'package:jejal_project/services/translation_service.dart';

import '../models/send_message_model.dart';

void setStream() async {
  WebSocketChannel? ws;
  late String phoneNumber;
  late Directory recordDirectory;
  late String androidId;
  const String recordDirectoryPath = "/storage/emulated/0/Recordings/Call";
  File? targetFile;
  Timer? timer;
  int offset = 0;
  PhoneState phoneStatus = PhoneState.nothing();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  androidId = androidInfo.id;

  recordDirectory = Directory(recordDirectoryPath);

  PhoneState.stream.listen((event) async {
    phoneStatus = event as PhoneState;
    if (event.status == PhoneStateStatus.CALL_INCOMING) {
      print("Incoming call detected.");
    }

    else if (event.status == PhoneStateStatus.CALL_STARTED) {

      //전화 시작되면 위젯 띄우기
      //지금 실행 안되고 있음
      if (!await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Overlay Title",
          overlayContent: 'Overlay Content',
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: WindowSize.matchParent,
          width: WindowSize.matchParent,
        );
      }

      print("Call started.");

      //전화번호 받아오기
      phoneNumber = phoneStatus.number.toString();
      print("전화온 번호"+phoneNumber);

      ws = WebSocketChannel.connect(
        Uri.parse('wss://k10a406.p.ssafy.io/api/record'),
      );

      // var startMessage = SendMessageModel(
      //   state: 0,
      //   androidId: androidId,
      // );
      // ws?.sink.add(jsonEncode(startMessage));

      var temp = await recentFile(recordDirectory);
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
          String encode = base64.encode(splittedBytes);
          print(encode);

          ws?.sink.add(splittedBytes);
        });
      }

      else {
        print("파일 못찾음");
        ws?.sink.close();
      }

    } else if (event.status == PhoneStateStatus.CALL_ENDED) {
      print("Call ended.");

      //통화 종료되면 위젯 끄기
      //됐다가 안됐다가 함
      //UX 상으로 없애는게 나을 수도 있을 듯
      // FlutterOverlayWindow.closeOverlay();

      timer?.cancel();
      Uint8List entireBytes = targetFile!.readAsBytesSync();
      var nextOffset = entireBytes.length;
      var splittedBytes = entireBytes.sublist(offset, nextOffset);
      offset = nextOffset;

      print("마지막 데이터");
      print(splittedBytes);
      var encode = base64.encode(splittedBytes);
      print(encode);

      ws?.sink.add(splittedBytes);

      // //마지막 데이터 전송
      // ws?.sink.add(splittedBytes);

      // //종료 메세지 전송
      // var endMessage = SendMessageModel(
      //   state: 1,
      //   androidId: androidId,
      //   phoneNumber: phoneNumber,
      // );
      // ws?.sink.add(jsonEncode(endMessage));
    }
  });
}