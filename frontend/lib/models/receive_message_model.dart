class ReceiveMessageModel {
  int? id;
  int? conversationId;
  String? jeju;
  String? translated;
  String? timestamp;
  bool? isFinish;

  bool get isTranslated => translated != "wait";

  ReceiveMessageModel({
    this.id,
    this.conversationId,
    this.jeju,
    this.translated,
    this.timestamp,
    this.isFinish,
  });

  ReceiveMessageModel copyWith({
    String? translated,
  }) {
    return ReceiveMessageModel(
      id: id,
      conversationId: conversationId,
      jeju: jeju,
      translated: translated ?? this.translated,
      timestamp: timestamp,
      isFinish: isFinish,
    );
  }

  ReceiveMessageModel.fromJson(Map<String, dynamic> json) {
    jeju = json['jeju'];
    translated = json['translated'];
    isFinish = json['isFinish'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jeju'] = this.jeju;
    data['translated'] = this.translated;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'jeju_text': jeju,
      'translated_text': translated,
      'timestamp': timestamp,
    };
  }

  factory ReceiveMessageModel.fromMap(Map<String, dynamic> map) {
    return ReceiveMessageModel(
      id: map['id'],
      conversationId: map['conversation_id'],
      jeju: map['jeju_text'],
      translated: map['translated_text'],
      timestamp: map['timestamp'],
    );
  }
}