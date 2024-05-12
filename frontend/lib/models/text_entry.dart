class TextEntry {
  final int? id;
  final int conversationId;
  final String jejuText;
  final String translatedText;
  final String timestamp;

  TextEntry({
    this.id,
    required this.conversationId,
    required this.jejuText,
    required this.translatedText,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    print('19');

    return {
      'id': id,
      'conversation_id': conversationId,
      'jeju_text': jejuText,
      'translated_text': translatedText,
      'timestamp': timestamp,
    };
  }

  factory TextEntry.fromMap(Map<String, dynamic> map) {
    print('20');

    return TextEntry(
      id: map['id'],
      conversationId: map['conversation_id'],
      jejuText: map['jeju_text'],
      translatedText: map['translated_text'],
      timestamp: map['timestamp'],
    );
  }
}