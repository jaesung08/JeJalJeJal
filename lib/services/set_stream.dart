import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/models/send_message_model.dart';
import 'package:jejal_project/services/recent_file.dart';
import 'package:jejal_project/widgets/overlay_widget.dart';
import 'package:phone_state/phone_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void setStream() async {
  WebSocketChannel? ws;
  String phoneNumber;
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
    } else if (event.status == PhoneStateStatus.CALL_STARTED) {

      print("Call started.");
      print("Showing overlay..."); // 오버레이 표시 확인용 print 문 추가

      //전화번호 받아오기
      phoneNumber = phoneStatus.number.toString();
      print("전화온 번호"+phoneNumber);

      bool isOverlayShown = await FlutterOverlayWindow.isActive();
      print("Is overlay already shown? $isOverlayShown"); // 오버레이 표시 여부 확인용 print 문 추가
      if (!isOverlayShown) {
        await FlutterOverlayWindow.showOverlay(
          height: 200,
          width: 200,
          alignment: OverlayAlignment.centerRight,
          flag: OverlayFlag.defaultFlag,
        );
        print("Overlay shown."); // 오버레이 표시 확인용 print 문 추가
      }
      ws = WebSocketChannel.connect(
        Uri.parse('ws://k8a607.p.ssafy.io:8080/record'),
      );

      var temp = await recentFile(recordDirectory);
      targetFile = temp is FileSystemEntity ? temp as File : null;
      if (targetFile is File) {
        print("파일 찾음");
        print(targetFile?.path);
        timer = Timer.periodic(const Duration(seconds: 6), (timer) async {
          var temp = await recentFile(recordDirectory);
          targetFile = temp is FileSystemEntity ? temp as File : null;

          print("파일 또 찾음");
          print(targetFile?.path);

          Uint8List entireBytes = targetFile!.readAsBytesSync();
          var nextOffset = entireBytes.length;


          var splittedBytes = entireBytes.sublist(offset, nextOffset);
          offset = nextOffset;
          String encode = base64.encode(splittedBytes);
          print(encode);
        });
      } else {
        print("파일 못찾음");
        ws?.sink.close();
      }
    } else if (event.status == PhoneStateStatus.CALL_ENDED) {
        print("Call ended.");
        print("Closing overlay..."); // 오버레이 닫기 확인용 print 문 추가
        await FlutterOverlayWindow.closeOverlay();
        print("Overlay closed."); // 오버레이 닫기 확인용 print 문 추가

        timer?.cancel();
        Uint8List entireBytes = targetFile!.readAsBytesSync();
        var nextOffset = entireBytes.length;
        var splittedBytes = entireBytes.sublist(offset, nextOffset);
        offset = nextOffset;
        print("마지막 데이터");
        print(splittedBytes);
    }
  });
}