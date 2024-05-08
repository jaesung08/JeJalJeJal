import 'dart:convert';

class FileResultModel {
  final List<String>? sentences;

  // 생성자
  FileResultModel({this.sentences});

  // JSON에서 객체로 변환하기 위한 팩토리 생성자
  factory FileResultModel.fromJson(Map<String, dynamic> json) {
    var segments = json['data']['segments'] as List<dynamic>?; // List<dynamic> 으로 segments를 읽음
    List<String> sentences = segments != null
        ? segments.map((s) => s['translated'] as String).toList()
        : ['기본 문장을 제공합니다']; // 세그먼트가 없을 경우 기본 문장 제공

    return FileResultModel(
      sentences: sentences,
    );
  }

  // 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'sentences': sentences,
    };
  }
}

