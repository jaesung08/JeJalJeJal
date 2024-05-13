class SendMessageModel {
  int state;
  String androidId;
  String? phoneNumber;

  SendMessageModel({
    required this.state,
    required this.androidId,
    this.phoneNumber,
  });

  factory SendMessageModel.fromJson(Map<String, dynamic> jsonData) {
    print('17');

    return SendMessageModel(
      state: jsonData['state'],
      androidId: jsonData['androidId'],
      phoneNumber: jsonData['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    print('18');

    return {
      'state': state,
      'androidId': androidId,
      'phoneNumber': phoneNumber,
    };
  }
}