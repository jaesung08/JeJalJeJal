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
  TextColumn get recordingFilePath => text()();
}

class JejuTexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().references(Conversations, #id)();
  TextColumn get jejuText => text()();
  DateTimeColumn get timestamp => dateTime()();
}

class TranslatedTexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  // conversationId 를 외래키로 사용하여 Conversations 테이블과 연결
  IntColumn get conversationId => integer().references(Conversations, #id)();
  TextColumn get translatedText => text()();
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [Conversations, JejuTexts, TranslatedTexts])
class JejalDatabase extends _$JejalDatabase {
  JejalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Conversation>> getAllConversations() => select(conversations).get();
  Stream<List<Conversation>> watchAllConversations() => select(conversations).watch();
  Future<int> insertConversation(ConversationsCompanion conversation) => into(conversations).insert(conversation);

  // JejuTexts 테이블에 데이터 삽입
  Future<int> insertJejuText(JejuTextsCompanion jejuText) => into(jejuTexts).insert(jejuText);

  // TranslatedTexts 테이블에 데이터 삽입
  Future<int> insertTranslatedText(TranslatedTextsCompanion translatedText) => into(translatedTexts).insert(translatedText);

  // 특정 conversationId에 해당하는 모든 jejuTexts 데이터 조회
  Future<List<JejuText>> getJejuTextsByConversationId(int conversationId) {
    return (select(jejuTexts)..where((tbl) => tbl.conversationId.equals(conversationId))).get();
  }

  // 특정 conversationId에 해당하는 모든 TranslatedTexts 데이터 조회
  Future<List<TranslatedText>> getTranslatedTextsByConversationId(int conversationId) {
    return (select(translatedTexts)..where((tbl) => tbl.conversationId.equals(conversationId))).get();
  }

  // 특정 대화를 클릭했을 때 conversationId 조회
  Future<Conversation> getConversationById(int id) {
    return (select(conversations)..where((tbl) => tbl.id.equals(id))).getSingle();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

