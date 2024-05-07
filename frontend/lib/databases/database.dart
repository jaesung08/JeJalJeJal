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
  Future<int> insertConversation(Conversation conversation) => into(conversations).insert(conversation);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

