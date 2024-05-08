class FileResultModel {
  int? status;
  String? message;
  Data? data;

  FileResultModel({this.status, this.message, this.data});

  FileResultModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Segments>? segments;

  Data({this.segments});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['segments'] != null) {
      segments = <Segments>[];
      json['segments'].forEach((v) {
        segments!.add(new Segments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.segments != null) {
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
    jeju = json['jeju'];
    translated = json['translated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jeju'] = this.jeju;
    data['translated'] = this.translated;
    return data;
  }
}