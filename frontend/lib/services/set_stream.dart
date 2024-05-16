import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
      offset = 0;
      if (phoneStatus!.number?.isNotEmpty ?? false) {
        phoneNumber = phoneStatus!.number.toString();
        print('통화 시작됨: ${DateTime.now()}');
        print('전화 번호: $phoneNumber');

        // // 오버레이 데이터 초기화
        FlutterOverlayWindow.shareData(jsonEncode({'clear': true}));
        print('오버레이 클리어');

        List<Contact>? contacts =
        await ContactsService.getContactsForPhone(phoneNumber!);
        String? name;

        if (contacts.isNotEmpty) {
          name = contacts.first.displayName;
        } else {
          name = "제주도민";
        }

        conversationId = await DatabaseService.instance
            .insertConversation(phoneNumber!, name!);
        print('상대방 이름: $name');

        //웹소켓 연결
        ws = WebSocketChannel.connect(
          Uri.parse('wss://k10a406.p.ssafy.io/api/record'),
        );
        print('웹소켓 연결 시작');

        // 웹소켓 연결 시작 신호 전달
        FlutterOverlayWindow.shareData(
            jsonEncode({'type': 'websocket_connected'}));

        //시작 알림 메시지
        var startMessage = SendMessageModel(
          state: 0,
          androidId: androidId!,
        );

        ws?.sink.add(jsonEncode(startMessage));
        print('startMessage JSON으로 인코딩해서 추가하기');

        //보낼 파일 찾기
        // var temp = await recentFile(recordDirectory!);
        // targetFile = temp is FileSystemEntity ? temp as File : null;

        //1초 기다리기
        await Future.delayed(const Duration(seconds: 1));
        timer?.cancel();
        //1초마다 타이머 실행
        timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          var temp = await recentFile(recordDirectory!);
          targetFile = temp is FileSystemEntity ? temp as File : null;
          if (targetFile is File) {
            print('파일 찾음: ${targetFile?.path}');
            Uint8List entireBytes = targetFile!.readAsBytesSync();
            var nextOffset = entireBytes.length;

            // 범위 초과 문제를 해결하기 위해 nextOffset 이전의 데이터만 추출
            if (offset < nextOffset) {
              var splittedBytes = entireBytes.sublist(offset, nextOffset);

              // splittedBytes가 비어있지 않은 경우에만 전송
              if (splittedBytes.isNotEmpty) {
                ws?.sink.add(splittedBytes);
                print('전송 데이터: $splittedBytes');
              }
            }
            else{
              offset = 0;
            }
            offset = nextOffset;
          }
        });
      }

      //결과 데이터 받아오기
      ws?.stream.listen((msg) async {
        print('결과 데이터 받아오기 성공');
        if (msg != null) {
          ReceiveMessageModel receivedResult =
          ReceiveMessageModel.fromJson(jsonDecode(msg));
          receivedResult.conversationId = conversationId;
          //위젯으로 보내주기
          FlutterOverlayWindow.shareData(msg);
          print('결과 데이터 위젯으로 전송(shareData)');

          // translated 값이 "wait"이 아닐 때만 데이터베이스에 저장
          if (receivedResult.translated != "wait") {
            await DatabaseService.instance
                .insertMessage(receivedResult, conversationId!);
          }

          //마지막 데이터 받아오고 나서 웹소켓 닫기
          if (receivedResult.isFinish == true) {
            ws?.sink.close();
            print('마지막 데이터 받아오고 나서 웹소켓 연결 종료');
          }
        }
      });
    }
    else if (event.status == PhoneStateStatus.CALL_ENDED) {
      print('통화 종료.');
      if (targetFile != null) {
        Uint8List entireBytes = targetFile!.readAsBytesSync();
        var nextOffset = entireBytes.length;
        var splittedBytes = entireBytes.sublist(offset, nextOffset);
        offset = nextOffset;
        print('마지막 데이터: $splittedBytes');

        //   //마지막 알림 메시지 전송
        var endMessage = SendMessageModel(
          state: 1,
          androidId: androidId!,
          phoneNumber: phoneNumber!,
        );

        //웹소켓 연결 종료
        await ws?.sink.close();
        ws = null;
        print('웹소켓 연결 종료');

        //타이머 취소, 남은 데이터 보내주기
        timer?.cancel();
      }
    }
  });
}
