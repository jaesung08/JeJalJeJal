class ReceiveMessageModel {
  int? id;
  int? conversationId;
  String? jeju;
  String? translated;
  String? timestamp;

  ReceiveMessageModel({
    this.id,
    this.conversationId,
    this.jeju,
    this.translated,
    this.timestamp,
  });

  ReceiveMessageModel.fromJson(Map<String, dynamic> json) {
    // JSON에서 jeju와 translated 값을 파싱
    print('13');

    jeju = json['jeju'];
    translated = json['translated'];
  }

  Map<String, dynamic> toJson() {
    print('14');

    // jeju와 translated 값을 JSON으로 변환
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jeju'] = this.jeju;
    data['translated'] = this.translated;
    return data;
  }

  Map<String, dynamic> toMap() {
    // 통화 중 데이터베이스에 저장할 항목
    print('15');

    return {
      'id': id,
      'conversation_id': conversationId,
      'jeju_text': jeju,
      'translated_text': translated,
      'timestamp': timestamp,
    };
  }

  factory ReceiveMessageModel.fromMap(Map<String, dynamic> map) {
    print('16');

    return ReceiveMessageModel(
      id: map['id'],
      conversationId: map['conversation_id'],
      jeju: map['jeju_text'],
      translated: map['translated_text'],
      timestamp: map['timestamp'],
    );
  }
}