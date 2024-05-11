class ReceiveMessageModel {
  String? jeju;
  String? translated;

  ReceiveMessageModel({this.jeju, this.translated});

  ReceiveMessageModel.fromJson(Map<String, dynamic> json) {
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