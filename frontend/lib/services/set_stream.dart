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

void setStream() async {
  const String testfilePath = "/storage/emulated/0/Recordings/test";
  WebSocketChannel? ws;
  late String phoneNumber;
  late Directory recordDirectory;
  late Directory testDirectory;
  late String androidId;
  const String recordDirectoryPath = "/storage/emulated/0/Recordings/Call";
  File? targetFile;
  File? testFile;
  Timer? timer;
  int offset = 0;
  PhoneState phoneStatus = PhoneState.nothing();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  androidId = androidInfo.id;

  recordDirectory = Directory(recordDirectoryPath);
  testDirectory = Directory(testfilePath);

  PhoneState.stream.listen((event) async {
    phoneStatus = event as PhoneState;
    if (event.status == PhoneStateStatus.CALL_INCOMING) {
      print("Incoming call detected.");
    }

    else if (event.status == PhoneStateStatus.CALL_STARTED) {
      //전화 시작되면 위젯 띄우기
      //지금 실행 안되고 있음
      // if (!await FlutterOverlayWindow.isActive()) {
      //   await FlutterOverlayWindow.showOverlay(
      //     enableDrag: true,
      //     overlayTitle: "Overlay Title",
      //     overlayContent: 'Overlay Content',
      //     flag: OverlayFlag.defaultFlag,
      //     visibility: NotificationVisibility.visibilityPublic,
      //     positionGravity: PositionGravity.auto,
      //     height: WindowSize.matchParent,
      //     width: WindowSize.matchParent,
      //   );
      // }

      print("Call started.");

      //전화번호 받아오기
      phoneNumber = phoneStatus.number.toString();
      //핸드폰 주소록에 접근해서 받아온 전화번호와 일치하는 사람의 이름을 name이라는 변수에 저장
      List<Contact>? contacts = await ContactsService.getContactsForPhone(phoneNumber);
      String? name;

      if (contacts != null && contacts.isNotEmpty) {
        // 첫 번째 연락처의 이름을 사용합니다.
        name = contacts.first.displayName;
      } else {
        name = "제주도민"; // 연락처를 찾지 못한 경우 null로 설정
      }

      // 새로운 대화 생성 및 conversation_id 가져오기
      int conversationId = await DatabaseService.instance.insertConversation(phoneNumber, name!);
      print("전화온 번호: $phoneNumber");
      print("상대방 이름: $name");

      ws = WebSocketChannel.connect(
        Uri.parse('wss://k10a406.p.ssafy.io/api/record'),
      );

      var startMessage = SendMessageModel(
        state: 0,
        androidId: androidId,
      );
      ws?.sink.add(jsonEncode(startMessage));


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

          ws?.sink.add(splittedBytes);
        });
      }

      else {
        print("파일 못찾음");
        ws?.sink.close();
      }

      // 검사 결과 수신
      ws?.stream.listen((msg) async {
        if (msg != null) {
          ReceiveMessageModel receivedResult =
          ReceiveMessageModel.fromJson(jsonDecode(msg));
          receivedResult.conversationId = conversationId; // conversationId 설정
          FlutterOverlayWindow.shareData(msg);
          await DatabaseService.instance.insertMessage(receivedResult, conversationId); // 메시지 저장
        }
      });

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
      // var encode = base64.encode(splittedBytes);
      // print(encode);

      // 마지막 데이터 전송
      ws?.sink.add(splittedBytes);

      //종료 메세지 전송
      var endMessage = SendMessageModel(
        state: 1,
        androidId: androidId,
        phoneNumber: phoneNumber,
      );
      ws?.sink.add(jsonEncode(endMessage));
    }
  });
}