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
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  androidId = androidInfo.id;
  recordDirectory = Directory(recordDirectoryPath);
}

void initPhoneStateListener() {
  PhoneState.stream.listen((event) async {
    print('상태 변경 감지: ${event.status}');
    phoneStatus = event as PhoneState;

    //통화 시작
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

        //웹소켓 연결
        ws = WebSocketChannel.connect(
          Uri.parse('wss://k10a406.p.ssafy.io/api/record'),
        );

        //시작 알림 메시지
        var startMessage = SendMessageModel(
          state: 0,
          androidId: androidId!,
        );

        ws?.sink.add(jsonEncode(startMessage));

        //보낼 파일 찾기
        // var temp = await recentFile(recordDirectory!);
        // targetFile = temp is FileSystemEntity ? temp as File : null;

        //2초마다 파일 전송

        timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
            var temp = await recentFile(recordDirectory!);
            targetFile = temp is FileSystemEntity ? temp as File : null;
            if (targetFile is File) {
              print('파일 찾음: ${targetFile?.path}');
              Uint8List entireBytes = targetFile!.readAsBytesSync();
              var nextOffset = entireBytes.length;

              // 범위 초과 문제를 해결하기 위해 nextOffset 이전의 데이터만 추출
              if (offset < nextOffset) {
                var splittedBytes = entireBytes.sublist(offset, nextOffset);
                print('전송 데이터: $splittedBytes');
                ws?.sink.add(splittedBytes);
              }

              offset = nextOffset;
            }
          });
        }

        //결과 데이터 받아오기
        ws?.stream.listen((msg) async {
          if (msg != null) {
            ReceiveMessageModel receivedResult = ReceiveMessageModel.fromJson(jsonDecode(msg));
            receivedResult.conversationId = conversationId;
            //위젯으로 보내주기
            FlutterOverlayWindow.shareData(msg);
            await DatabaseService.instance.insertMessage(receivedResult, conversationId!);

            //마지막 데이터 받아오고 나서 웹소켓 닫기
            if(receivedResult.isFinish == true){
              ws?.sink.close();
            }
          }
        });
      }
     else if (event.status == PhoneStateStatus.CALL_ENDED) {
      print('통화 종료.');

      //타이머 취소, 남은 데이터 보내주기
      timer?.cancel();

      if (targetFile != null) {
        Uint8List entireBytes = targetFile!.readAsBytesSync();
        var nextOffset = entireBytes.length;
        var splittedBytes = entireBytes.sublist(offset, nextOffset);
        offset = nextOffset;
        print('마지막 데이터: $splittedBytes');

        ws?.sink.add(splittedBytes);
      }

      //마지막 알림 메시지 전송
      var endMessage = SendMessageModel(
        state: 1,
        androidId: androidId!,
        phoneNumber: phoneNumber!,
      );

      ws?.sink.add(jsonEncode(endMessage));

      //임시 웹소켓 닫음
      // ws?.sink.close();
    }
  });
}


