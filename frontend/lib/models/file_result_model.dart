class FileResultModel {
  int? status;
  String? message;
  Data? data;

  FileResultModel({this.status, this.message, this.data});

  FileResultModel.fromJson(Map<String, dynamic> json) { // JSON에서 객체 생성
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() { // 객체를 JSON으로 변환
    print('6');
    final Map<String, dynamic> data = new Map<String, dynamic>(); // 데이터 맵 생성
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      print('7');
      data['data'] = this.data!.toJson(); // 데이터를 JSON으로 변환하여 추가
    }
    return data;
  }
}

class Data {
  List<Segments>? segments;

  Data({this.segments});

  Data.fromJson(Map<String, dynamic> json) {
    print('8');
    if (json['segments'] != null) {
      print('9');
      segments = <Segments>[];
      json['segments'].forEach((v) {
        segments!.add(new Segments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    print('9');

    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.segments != null) {
      print('10');

      data['segments'] = this.segments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Segments {
  String? jeju;
  String? translated;

  Segments({this.jeju, this.translated});

  Segments.fromJson(Map<String, dynamic> json) {
    print('11');

    jeju = json['jeju'];
    translated = json['translated'];
  }

  Map<String, dynamic> toJson() {
    print('12');

    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jeju'] = this.jeju;
    data['translated'] = this.translated;
    return data;
  }
}