// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _recordingFilePathMeta =
      const VerificationMeta('recordingFilePath');
  @override
  late final GeneratedColumn<String> recordingFilePath =
      GeneratedColumn<String>('recording_file_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, phoneNumber, name, date, recordingFilePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('recording_file_path')) {
      context.handle(
          _recordingFilePathMeta,
          recordingFilePath.isAcceptableOrUnknown(
              data['recording_file_path']!, _recordingFilePathMeta));
    } else if (isInserting) {
      context.missing(_recordingFilePathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      recordingFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recording_file_path'])!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int id;
  final String phoneNumber;
  final String name;
  final DateTime date;
  final String recordingFilePath;
  const Conversation(
      {required this.id,
      required this.phoneNumber,
      required this.name,
      required this.date,
      required this.recordingFilePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['recording_file_path'] = Variable<String>(recordingFilePath);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      phoneNumber: Value(phoneNumber),
      name: Value(name),
      date: Value(date),
      recordingFilePath: Value(recordingFilePath),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      recordingFilePath: serializer.fromJson<String>(json['recordingFilePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'recordingFilePath': serializer.toJson<String>(recordingFilePath),
    };
  }

  Conversation copyWith(
          {int? id,
          String? phoneNumber,
          String? name,
          DateTime? date,
          String? recordingFilePath}) =>
      Conversation(
        id: id ?? this.id,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        name: name ?? this.name,
        date: date ?? this.date,
        recordingFilePath: recordingFilePath ?? this.recordingFilePath,
      );
  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('recordingFilePath: $recordingFilePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, phoneNumber, name, date, recordingFilePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.phoneNumber == this.phoneNumber &&
          other.name == this.name &&
          other.date == this.date &&
          other.recordingFilePath == this.recordingFilePath);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<String> phoneNumber;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<String> recordingFilePath;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.recordingFilePath = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    required String phoneNumber,
    required String name,
    required DateTime date,
    required String recordingFilePath,
  })  : phoneNumber = Value(phoneNumber),
        name = Value(name),
        date = Value(date),
        recordingFilePath = Value(recordingFilePath);
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<String>? phoneNumber,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<String>? recordingFilePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (recordingFilePath != null) 'recording_file_path': recordingFilePath,
    });
  }

  ConversationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? phoneNumber,
      Value<String>? name,
      Value<DateTime>? date,
      Value<String>? recordingFilePath}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      date: date ?? this.date,
      recordingFilePath: recordingFilePath ?? this.recordingFilePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (recordingFilePath.present) {
      map['recording_file_path'] = Variable<String>(recordingFilePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('recordingFilePath: $recordingFilePath')
          ..write(')'))
        .toString();
  }
}

class $JejuTextsTable extends JejuTexts
    with TableInfo<$JejuTextsTable, JejuText> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JejuTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES conversations (id)'));
  static const VerificationMeta _jejuTextMeta =
      const VerificationMeta('jejuText');
  @override
  late final GeneratedColumn<String> jejuText = GeneratedColumn<String>(
      'jeju_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, conversationId, jejuText, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jeju_texts';
  @override
  VerificationContext validateIntegrity(Insertable<JejuText> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('jeju_text')) {
      context.handle(_jejuTextMeta,
          jejuText.isAcceptableOrUnknown(data['jeju_text']!, _jejuTextMeta));
    } else if (isInserting) {
      context.missing(_jejuTextMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JejuText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JejuText(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      jejuText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jeju_text'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $JejuTextsTable createAlias(String alias) {
    return $JejuTextsTable(attachedDatabase, alias);
  }
}

class JejuText extends DataClass implements Insertable<JejuText> {
  final int id;
  final int conversationId;
  final String jejuText;
  final DateTime timestamp;
  const JejuText(
      {required this.id,
      required this.conversationId,
      required this.jejuText,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['jeju_text'] = Variable<String>(jejuText);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  JejuTextsCompanion toCompanion(bool nullToAbsent) {
    return JejuTextsCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      jejuText: Value(jejuText),
      timestamp: Value(timestamp),
    );
  }

  factory JejuText.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JejuText(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      jejuText: serializer.fromJson<String>(json['jejuText']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'jejuText': serializer.toJson<String>(jejuText),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  JejuText copyWith(
          {int? id,
          int? conversationId,
          String? jejuText,
          DateTime? timestamp}) =>
      JejuText(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        jejuText: jejuText ?? this.jejuText,
        timestamp: timestamp ?? this.timestamp,
      );
  @override
  String toString() {
    return (StringBuffer('JejuText(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('jejuText: $jejuText, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, jejuText, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JejuText &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.jejuText == this.jejuText &&
          other.timestamp == this.timestamp);
}

class JejuTextsCompanion extends UpdateCompanion<JejuText> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String> jejuText;
  final Value<DateTime> timestamp;
  const JejuTextsCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.jejuText = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  JejuTextsCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required String jejuText,
    required DateTime timestamp,
  })  : conversationId = Value(conversationId),
        jejuText = Value(jejuText),
        timestamp = Value(timestamp);
  static Insertable<JejuText> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? jejuText,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (jejuText != null) 'jeju_text': jejuText,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  JejuTextsCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<String>? jejuText,
      Value<DateTime>? timestamp}) {
    return JejuTextsCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      jejuText: jejuText ?? this.jejuText,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (jejuText.present) {
      map['jeju_text'] = Variable<String>(jejuText.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JejuTextsCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('jejuText: $jejuText, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $TranslatedTextsTable extends TranslatedTexts
    with TableInfo<$TranslatedTextsTable, TranslatedText> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslatedTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES conversations (id)'));
  static const VerificationMeta _translatedTextMeta =
      const VerificationMeta('translatedText');
  @override
  late final GeneratedColumn<String> translatedText = GeneratedColumn<String>(
      'translated_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, conversationId, translatedText, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translated_texts';
  @override
  VerificationContext validateIntegrity(Insertable<TranslatedText> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('translated_text')) {
      context.handle(
          _translatedTextMeta,
          translatedText.isAcceptableOrUnknown(
              data['translated_text']!, _translatedTextMeta));
    } else if (isInserting) {
      context.missing(_translatedTextMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranslatedText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslatedText(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      translatedText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}translated_text'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $TranslatedTextsTable createAlias(String alias) {
    return $TranslatedTextsTable(attachedDatabase, alias);
  }
}

class TranslatedText extends DataClass implements Insertable<TranslatedText> {
  final int id;
  final int conversationId;
  final String translatedText;
  final DateTime timestamp;
  const TranslatedText(
      {required this.id,
      required this.conversationId,
      required this.translatedText,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['translated_text'] = Variable<String>(translatedText);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  TranslatedTextsCompanion toCompanion(bool nullToAbsent) {
    return TranslatedTextsCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      translatedText: Value(translatedText),
      timestamp: Value(timestamp),
    );
  }

  factory TranslatedText.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslatedText(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      translatedText: serializer.fromJson<String>(json['translatedText']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'translatedText': serializer.toJson<String>(translatedText),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TranslatedText copyWith(
          {int? id,
          int? conversationId,
          String? translatedText,
          DateTime? timestamp}) =>
      TranslatedText(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        translatedText: translatedText ?? this.translatedText,
        timestamp: timestamp ?? this.timestamp,
      );
  @override
  String toString() {
    return (StringBuffer('TranslatedText(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('translatedText: $translatedText, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, translatedText, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslatedText &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.translatedText == this.translatedText &&
          other.timestamp == this.timestamp);
}

class TranslatedTextsCompanion extends UpdateCompanion<TranslatedText> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<String> translatedText;
  final Value<DateTime> timestamp;
  const TranslatedTextsCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.translatedText = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  TranslatedTextsCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required String translatedText,
    required DateTime timestamp,
  })  : conversationId = Value(conversationId),
        translatedText = Value(translatedText),
        timestamp = Value(timestamp);
  static Insertable<TranslatedText> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? translatedText,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (translatedText != null) 'translated_text': translatedText,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  TranslatedTextsCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<String>? translatedText,
      Value<DateTime>? timestamp}) {
    return TranslatedTextsCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      translatedText: translatedText ?? this.translatedText,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (translatedText.present) {
      map['translated_text'] = Variable<String>(translatedText.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslatedTextsCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('translatedText: $translatedText, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$JejalDatabase extends GeneratedDatabase {
  _$JejalDatabase(QueryExecutor e) : super(e);
  _$JejalDatabaseManager get managers => _$JejalDatabaseManager(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $JejuTextsTable jejuTexts = $JejuTextsTable(this);
  late final $TranslatedTextsTable translatedTexts =
      $TranslatedTextsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [conversations, jejuTexts, translatedTexts];
}

typedef $$ConversationsTableInsertCompanionBuilder = ConversationsCompanion
    Function({
  Value<int> id,
  required String phoneNumber,
  required String name,
  required DateTime date,
  required String recordingFilePath,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<int> id,
  Value<String> phoneNumber,
  Value<String> name,
  Value<DateTime> date,
  Value<String> recordingFilePath,
});

class $$ConversationsTableTableManager extends RootTableManager<
    _$JejalDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableProcessedTableManager,
    $$ConversationsTableInsertCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder> {
  $$ConversationsTableTableManager(
      _$JejalDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ConversationsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ConversationsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ConversationsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> recordingFilePath = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            phoneNumber: phoneNumber,
            name: name,
            date: date,
            recordingFilePath: recordingFilePath,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String phoneNumber,
            required String name,
            required DateTime date,
            required String recordingFilePath,
          }) =>
              ConversationsCompanion.insert(
            id: id,
            phoneNumber: phoneNumber,
            name: name,
            date: date,
            recordingFilePath: recordingFilePath,
          ),
        ));
}

class $$ConversationsTableProcessedTableManager extends ProcessedTableManager<
    _$JejalDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableProcessedTableManager,
    $$ConversationsTableInsertCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder> {
  $$ConversationsTableProcessedTableManager(super.$state);
}

class $$ConversationsTableFilterComposer
    extends FilterComposer<_$JejalDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get phoneNumber => $state.composableBuilder(
      column: $state.table.phoneNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recordingFilePath => $state.composableBuilder(
      column: $state.table.recordingFilePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter jejuTextsRefs(
      ComposableFilter Function($$JejuTextsTableFilterComposer f) f) {
    final $$JejuTextsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.jejuTexts,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder, parentComposers) =>
            $$JejuTextsTableFilterComposer(ComposerState(
                $state.db, $state.db.jejuTexts, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter translatedTextsRefs(
      ComposableFilter Function($$TranslatedTextsTableFilterComposer f) f) {
    final $$TranslatedTextsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.translatedTexts,
            getReferencedColumn: (t) => t.conversationId,
            builder: (joinBuilder, parentComposers) =>
                $$TranslatedTextsTableFilterComposer(ComposerState($state.db,
                    $state.db.translatedTexts, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends OrderingComposer<_$JejalDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get phoneNumber => $state.composableBuilder(
      column: $state.table.phoneNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recordingFilePath => $state.composableBuilder(
      column: $state.table.recordingFilePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$JejuTextsTableInsertCompanionBuilder = JejuTextsCompanion Function({
  Value<int> id,
  required int conversationId,
  required String jejuText,
  required DateTime timestamp,
});
typedef $$JejuTextsTableUpdateCompanionBuilder = JejuTextsCompanion Function({
  Value<int> id,
  Value<int> conversationId,
  Value<String> jejuText,
  Value<DateTime> timestamp,
});

class $$JejuTextsTableTableManager extends RootTableManager<
    _$JejalDatabase,
    $JejuTextsTable,
    JejuText,
    $$JejuTextsTableFilterComposer,
    $$JejuTextsTableOrderingComposer,
    $$JejuTextsTableProcessedTableManager,
    $$JejuTextsTableInsertCompanionBuilder,
    $$JejuTextsTableUpdateCompanionBuilder> {
  $$JejuTextsTableTableManager(_$JejalDatabase db, $JejuTextsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$JejuTextsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$JejuTextsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$JejuTextsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int> conversationId = const Value.absent(),
            Value<String> jejuText = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              JejuTextsCompanion(
            id: id,
            conversationId: conversationId,
            jejuText: jejuText,
            timestamp: timestamp,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int conversationId,
            required String jejuText,
            required DateTime timestamp,
          }) =>
              JejuTextsCompanion.insert(
            id: id,
            conversationId: conversationId,
            jejuText: jejuText,
            timestamp: timestamp,
          ),
        ));
}

class $$JejuTextsTableProcessedTableManager extends ProcessedTableManager<
    _$JejalDatabase,
    $JejuTextsTable,
    JejuText,
    $$JejuTextsTableFilterComposer,
    $$JejuTextsTableOrderingComposer,
    $$JejuTextsTableProcessedTableManager,
    $$JejuTextsTableInsertCompanionBuilder,
    $$JejuTextsTableUpdateCompanionBuilder> {
  $$JejuTextsTableProcessedTableManager(super.$state);
}

class $$JejuTextsTableFilterComposer
    extends FilterComposer<_$JejalDatabase, $JejuTextsTable> {
  $$JejuTextsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get jejuText => $state.composableBuilder(
      column: $state.table.jejuText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $state.db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ConversationsTableFilterComposer(ComposerState($state.db,
                $state.db.conversations, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$JejuTextsTableOrderingComposer
    extends OrderingComposer<_$JejalDatabase, $JejuTextsTable> {
  $$JejuTextsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get jejuText => $state.composableBuilder(
      column: $state.table.jejuText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.conversationId,
            referencedTable: $state.db.conversations,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ConversationsTableOrderingComposer(ComposerState($state.db,
                    $state.db.conversations, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$TranslatedTextsTableInsertCompanionBuilder = TranslatedTextsCompanion
    Function({
  Value<int> id,
  required int conversationId,
  required String translatedText,
  required DateTime timestamp,
});
typedef $$TranslatedTextsTableUpdateCompanionBuilder = TranslatedTextsCompanion
    Function({
  Value<int> id,
  Value<int> conversationId,
  Value<String> translatedText,
  Value<DateTime> timestamp,
});

class $$TranslatedTextsTableTableManager extends RootTableManager<
    _$JejalDatabase,
    $TranslatedTextsTable,
    TranslatedText,
    $$TranslatedTextsTableFilterComposer,
    $$TranslatedTextsTableOrderingComposer,
    $$TranslatedTextsTableProcessedTableManager,
    $$TranslatedTextsTableInsertCompanionBuilder,
    $$TranslatedTextsTableUpdateCompanionBuilder> {
  $$TranslatedTextsTableTableManager(
      _$JejalDatabase db, $TranslatedTextsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TranslatedTextsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TranslatedTextsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$TranslatedTextsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<int> conversationId = const Value.absent(),
            Value<String> translatedText = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              TranslatedTextsCompanion(
            id: id,
            conversationId: conversationId,
            translatedText: translatedText,
            timestamp: timestamp,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required int conversationId,
            required String translatedText,
            required DateTime timestamp,
          }) =>
              TranslatedTextsCompanion.insert(
            id: id,
            conversationId: conversationId,
            translatedText: translatedText,
            timestamp: timestamp,
          ),
        ));
}

class $$TranslatedTextsTableProcessedTableManager extends ProcessedTableManager<
    _$JejalDatabase,
    $TranslatedTextsTable,
    TranslatedText,
    $$TranslatedTextsTableFilterComposer,
    $$TranslatedTextsTableOrderingComposer,
    $$TranslatedTextsTableProcessedTableManager,
    $$TranslatedTextsTableInsertCompanionBuilder,
    $$TranslatedTextsTableUpdateCompanionBuilder> {
  $$TranslatedTextsTableProcessedTableManager(super.$state);
}

class $$TranslatedTextsTableFilterComposer
    extends FilterComposer<_$JejalDatabase, $TranslatedTextsTable> {
  $$TranslatedTextsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get translatedText => $state.composableBuilder(
      column: $state.table.translatedText,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $state.db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ConversationsTableFilterComposer(ComposerState($state.db,
                $state.db.conversations, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TranslatedTextsTableOrderingComposer
    extends OrderingComposer<_$JejalDatabase, $TranslatedTextsTable> {
  $$TranslatedTextsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get translatedText => $state.composableBuilder(
      column: $state.table.translatedText,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.conversationId,
            referencedTable: $state.db.conversations,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$ConversationsTableOrderingComposer(ComposerState($state.db,
                    $state.db.conversations, joinBuilder, parentComposers)));
    return composer;
  }
}

class _$JejalDatabaseManager {
  final _$JejalDatabase _db;
  _$JejalDatabaseManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$JejuTextsTableTableManager get jejuTexts =>
      $$JejuTextsTableTableManager(_db, _db.jejuTexts);
  $$TranslatedTextsTableTableManager get translatedTexts =>
      $$TranslatedTextsTableTableManager(_db, _db.translatedTexts);
}
