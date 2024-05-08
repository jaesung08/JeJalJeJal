// lib/databases/database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phoneNumber => text()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TextEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().references(Conversations, #id)();
  TextColumn get jejuText => text()();
  TextColumn get translatedText => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Conversations, TextEntries])
class JejalDatabase extends _$JejalDatabase {
  JejalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // 모든 대화를 비동기적으로 가져옴(조회) - 통화 녹음 목록에 사용 - 통화 녹음 목록에 사용
  Future<List<Conversation>> getAllConversations() => select(conversations).get();

  // 모든 대화를 실시간으로 감시 & 변경사항을 업데이트하는 스트림을 반환 - 통화 녹음 목록에 사용
  Stream<List<Conversation>> watchAllConversations() => select(conversations).watch();

  // 대화를 데이터베이스에 저장
  Future<int> insertConversation(ConversationsCompanion conversation) => into(conversations).insert(conversation);

  // Texts 테이블에 데이터 삽입
  Future<int> insertText(TextEntriesCompanion text) => into(textEntries).insert(text);

  // 특정 대화를 클릭했을 때 conversationId 조회 - 특정 녹음 대화를 선택할 때 사용
  Future<Conversation> getConversationById(int id) {
    return (select(conversations)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  // 특정 conversationId에 해당하는 모든 Texts 데이터 조회
  Future<List<TextEntry>> getTextsByConversationId(int conversationId) {
    return (select(textEntries)..where((tbl) => tbl.conversationId.equals(conversationId))).get();
  }


}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

