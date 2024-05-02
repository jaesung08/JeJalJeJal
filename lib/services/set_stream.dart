import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
// import 'package:unique_device_id/unique_device_id.dart';
import 'recent_file.dart';
import 'package:phone_state/phone_state.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jejal_project/models/send_message_model.dart';
import 'package:device_info_plus/device_info_plus.dart';

void setStream() async {
  WebSocketChannel? ws;
  String phoneNumber = '01012345678';
  late Directory recordDirectory;
  late String androidId;
  const String recordDirectoryPath = "/storage/emulated/0/Recordings/Call";
  File? targetFile;
  Timer? timer;
  int offset = 0;
  PhoneState phoneStatus = PhoneState.nothing();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  //원하던 ssaid는 아닌데 일단 이걸로..
  //이걸 식별자로 쓰기도 하는듯..
  androidId = androidInfo.id;

  // print("아이디다"+androidId);

  recordDirectory = Directory(recordDirectoryPath);
  // androidId = await UniqueDeviceId.instance.getUniqueId() ?? 'unknown';

  PhoneState.stream.listen((event) async {
      phoneStatus = event as PhoneState;
      if (event.status == PhoneStateStatus.CALL_INCOMING) {
        print("Incoming call detected.");
        
      } else if (event.status == PhoneStateStatus.CALL_STARTED) {
        print("Call started.");
        //웹소켓 연결 시작
        ws = WebSocketChannel.connect(
          //주소 변경 필요
          Uri.parse('ws://k8a607.p.ssafy.io:8080/record'),
        );
        //
        // var startMessage = SendMessageModel(
        //   state: 0,
        //   androidId: androidId,
        // );
        // ws?.sink.add(jsonEncode(startMessage));
        // print(startMessage);

        var temp = await recentFile(recordDirectory);
        targetFile = temp is FileSystemEntity ? temp as File : null;
        if (targetFile is File) {
            print("파일 찾음");
            print(targetFile?.path);
            timer = Timer.periodic(const Duration(seconds: 6), (timer) async {
              //파일 다시 찾기
              var temp = await recentFile(recordDirectory);
              targetFile = temp is FileSystemEntity ? temp as File : null;
              print("파일 또 찾음");
              print(targetFile?.path);

              Uint8List entireBytes = targetFile!.readAsBytesSync();
              //다음 읽어야 하는 위치
              var nextOffset = entireBytes.length;

              //이전에 읽은 마지막 위치(offset)부터 현재 파일 끝까지의 데이터를 추출하여 splittedBytes에 저장
              var splittedBytes = entireBytes.sublist(offset, nextOffset);
              offset = nextOffset;
              print(splittedBytes);
              // ws?.sink.add(splittedBytes);
            });
          } else {
            print("파일 못찾음");
            ws?.sink.close();
          }
      } else if (event.status == PhoneStateStatus.CALL_ENDED) {
        print("Call ended.");

        timer?.cancel();
        // 덜 전달된 마지막 오프셋까지 보내기
        Uint8List entireBytes = targetFile!.readAsBytesSync();
        var nextOffset = entireBytes.length;
        var splittedBytes = entireBytes.sublist(offset, nextOffset);
        offset = nextOffset;
        print("마지막 데이터");
        print(splittedBytes);
        // ws?.sink.add(splittedBytes);
        //
        // var endMessage = SendMessageModel(
        //   state: 1,
        //   androidId: androidId,
        //   phoneNumber: phoneNumber,
        // );
        // ws?.sink.add(jsonEncode(endMessage));
      }
    });
  }


  // androidId = await UniqueDeviceId.instance.getUniqueId() ?? 'unknown';
  //
  // PlatformChannel().callStream().listen((event) {
  //   if (event is String) {
  //     phoneNumber = event;
  //   }
  // });
  //
  // PhoneState.phoneStateStream.listen((event) async {
  //   if (event != null) {
  //     phoneStatus = event;
  //   }
  //   // 통화 연결
  //   if (phoneStatus == PhoneStateStatus.CALL_STARTED) {
      // 웹소켓 연결 시작
      // ws = WebSocketChannel.connect(
      //   Uri.parse('ws://k8a607.p.ssafy.io:8080/record'),
      // );

      // var startMessage = SendMessageModel(
      //   state: 0,
      //   androidId: androidId,
      // );
      // ws?.sink.add(jsonEncode(startMessage));
      //
      // App.navigatorKey.currentContext!.read<IsAnalyzing>().on();

      // 통화 녹음 데이터 전송
      // var temp = await recentFile(recordDirectory);
      // targetFile = temp is FileSystemEntity ? temp as File : null;
      // offset = 0;
      // if (targetFile is File) {
      //   print("파일 찾음");
      //   timer = Timer.periodic(const Duration(seconds: 6), (timer) async {
      //     Uint8List entireBytes = targetFile!.readAsBytesSync();
      //     var nextOffset = entireBytes.length;
      //     var splittedBytes = entireBytes.sublist(offset, nextOffset);
      //     offset = nextOffset;
      //     // ws?.sink.add(splittedBytes);
      //   });
      // } else {
      //   print("파일 못찾음");
      //   // ws?.sink.close();
      // }

      // 검사 결과 수신
      // ws?.stream.listen((msg) async {
      //   if (msg != null) {
      //     ReceiveMessageModel receivedResult =
      //     ReceiveMessageModel.fromJson(jsonDecode(msg));
      //
      //     // 최종 결과 수신
      //     if (receivedResult.isFinish == true) {
      //       ws?.sink.close();
      //
      //       App.navigatorKey.currentContext!.read<IsAnalyzing>().off();
      //
      //       if (receivedResult.result != null &&
      //           receivedResult.result!.results != null) {
      //         if (receivedResult.result!.totalCategoryScore >= 0.6 &&
      //             receivedResult.result!.totalCategory != 0) {
      //           if (!await FlutterOverlayWindow.isActive()) {
      //             await FlutterOverlayWindow.showOverlay(
      //               enableDrag: false,
      //               flag: OverlayFlag.defaultFlag,
      //               alignment: OverlayAlignment.center,
      //               visibility: NotificationVisibility.visibilityPublic,
      //               positionGravity: PositionGravity.auto,
      //               height: 0,
      //               width: 0,
      //             );
      //             SendMessageModel callInfo = SendMessageModel(
      //               state: 1,
      //               androidId: androidId,
      //               phoneNumber: phoneNumber,
      //             );
      //             FlutterOverlayWindow.shareData(callInfo);
      //           }
      //           FlutterOverlayWindow.shareData(receivedResult);
      //         }
      //       }
      //     } else {
      //       if (receivedResult.result != null &&
      //           receivedResult.result!.results != null) {
      //         if (receivedResult.result!.totalCategoryScore >= 0.6 &&
      //             receivedResult.result!.totalCategory != 0) {
      //           App.navigatorKey.currentContext!
      //               .read<RealtimeProvider>()
      //               .add(receivedResult);
      //           // 푸시 알림 전송
      //           NotificationController.cancelNotifications();
      //           NotificationController.createNewNotification(receivedResult);
      //         }
      //       }
      //     }
      //   }
      // });
  //   } else if (phoneStatus == PhoneStateStatus.CALL_ENDED) {
  //     // 통화 종료
  //     timer?.cancel();
  //     // 덜 전달된 마지막 오프셋까지 보내기
  //     Uint8List entireBytes = targetFile!.readAsBytesSync();
  //     var nextOffset = entireBytes.length;
  //     var splittedBytes = entireBytes.sublist(offset, nextOffset);
  //     offset = nextOffset;
  //     // ws?.sink.add(splittedBytes);
  //     //
  //     // var endMessage = SendMessageModel(
  //     //   state: 1,
  //     //   androidId: androidId,
  //     //   phoneNumber: phoneNumber,
  //     // );
  //     // ws?.sink.add(jsonEncode(endMessage));
  //   }
  // });
// }