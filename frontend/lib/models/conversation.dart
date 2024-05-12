class Conversation {
  final int? id;
  final String phoneNumber;
  final String name;
  final String date;

  Conversation({
    this.id,
    required this.phoneNumber,
    required this.name,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'date': date,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    print('5');
    return Conversation(
      id: map['id'],
      phoneNumber: map['phone_number'],
      name: map['name'],
      date: map['date'],
    );
  }
}