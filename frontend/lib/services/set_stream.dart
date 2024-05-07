// lib/services/set_stream.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:jejal_project/databases/database.dart';
import 'package:jejal_project/services/recent_file.dart';
import 'package:jejal_project/services/translation_service.dart';
import 'package:phone_state/phone_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:contacts_service/contacts_service.dart';

void setStream(JejalDatabase database) async {
  WebSocketChannel? ws;
  String phoneNumber;
  late Directory recordDirectory;
  late String androidId;
  const String recordDirectoryPath = "/storage/emulated/0/Recordings/Call";
  File? targetFile;
  Timer? timer;
  int offset = 0;
  int? conversationId;
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
      print("전화온 번호" + phoneNumber);

      Future<String?> getContactName(String phoneNumber) async {
        try {
          final contacts = await ContactsService.getContacts(query: phoneNumber);
          if (contacts.isNotEmpty) {
            return contacts.first.displayName;
          }
        } catch (e) {
          print('Error fetching contact name: $e');
        }
        return null;
      }

      // 연락처에서 이름 가져오기
      final contactName = await getContactName(phoneNumber);

      // 웹소켓 연결 열기
      ws = WebSocketChannel.connect(
        Uri.parse('ws://k8a607.p.ssafy.io:8080/record'),
      );

      // TranslationService 인스턴스 생성
      final translationService = TranslationService(ws!, database);

      // 새로운 Conversation 레코드 생성
      conversationId = await database.insertConversation(
        ConversationsCompanion.insert(
          phoneNumber: phoneNumber,
          date: DateTime.now(),
          name: contactName ?? '',
          recordingFilePath: '',
        ),
      );

      // 번역 데이터 받아오기 및 저장
      translationService.translationStream.listen((translation) async {
        await translationService.saveTranslation(translation, conversationId!);
        // 번역 데이터를 UI에 업데이트하는 로직 추가
      });

      translationService.translationStream.listen((translation) async {
        await translationService.saveTranslation(translation, conversationId!);
      });

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

      //통화 종료되면 위젯 끄기
      //됐다가 안됐다가 함
      //UX 상으로 없애는게 나을 수도 있을 듯
      FlutterOverlayWindow.closeOverlay();

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
