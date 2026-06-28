// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frameMeta = const VerificationMeta('frame');
  @override
  late final GeneratedColumn<String> frame = GeneratedColumn<String>(
    'frame',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, frame];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('frame')) {
      context.handle(
        _frameMeta,
        frame.isAcceptableOrUnknown(data['frame']!, _frameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      frame: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame'],
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final DateTime createdAt;
  final String? frame;
  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.frame,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || frame != null) {
      map['frame'] = Variable<String>(frame);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      frame: frame == null && nullToAbsent
          ? const Value.absent()
          : Value(frame),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      frame: serializer.fromJson<String?>(json['frame']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'frame': serializer.toJson<String?>(frame),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    Value<String?> frame = const Value.absent(),
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    frame: frame.present ? frame.value : this.frame,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      frame: data.frame.present ? data.frame.value : this.frame,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('frame: $frame')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, frame);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.frame == this.frame);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<String?> frame;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.frame = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
    this.frame = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<String>? frame,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (frame != null) 'frame': frame,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<String?>? frame,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      frame: frame ?? this.frame,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (frame.present) {
      map['frame'] = Variable<String>(frame.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('frame: $frame')
          ..write(')'))
        .toString();
  }
}

class $ProjectSourcesTable extends ProjectSources
    with TableInfo<$ProjectSourcesTable, ProjectSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceProviderIdMeta = const VerificationMeta(
    'sourceProviderId',
  );
  @override
  late final GeneratedColumn<String> sourceProviderId = GeneratedColumn<String>(
    'source_provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [projectId, sourceProviderId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('source_provider_id')) {
      context.handle(
        _sourceProviderIdMeta,
        sourceProviderId.isAcceptableOrUnknown(
          data['source_provider_id']!,
          _sourceProviderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceProviderIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectId, sourceProviderId};
  @override
  ProjectSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectSource(
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      sourceProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_provider_id'],
      )!,
    );
  }

  @override
  $ProjectSourcesTable createAlias(String alias) {
    return $ProjectSourcesTable(attachedDatabase, alias);
  }
}

class ProjectSource extends DataClass implements Insertable<ProjectSource> {
  final int projectId;
  final String sourceProviderId;
  const ProjectSource({
    required this.projectId,
    required this.sourceProviderId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<int>(projectId);
    map['source_provider_id'] = Variable<String>(sourceProviderId);
    return map;
  }

  ProjectSourcesCompanion toCompanion(bool nullToAbsent) {
    return ProjectSourcesCompanion(
      projectId: Value(projectId),
      sourceProviderId: Value(sourceProviderId),
    );
  }

  factory ProjectSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectSource(
      projectId: serializer.fromJson<int>(json['projectId']),
      sourceProviderId: serializer.fromJson<String>(json['sourceProviderId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<int>(projectId),
      'sourceProviderId': serializer.toJson<String>(sourceProviderId),
    };
  }

  ProjectSource copyWith({int? projectId, String? sourceProviderId}) =>
      ProjectSource(
        projectId: projectId ?? this.projectId,
        sourceProviderId: sourceProviderId ?? this.sourceProviderId,
      );
  ProjectSource copyWithCompanion(ProjectSourcesCompanion data) {
    return ProjectSource(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      sourceProviderId: data.sourceProviderId.present
          ? data.sourceProviderId.value
          : this.sourceProviderId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectSource(')
          ..write('projectId: $projectId, ')
          ..write('sourceProviderId: $sourceProviderId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(projectId, sourceProviderId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectSource &&
          other.projectId == this.projectId &&
          other.sourceProviderId == this.sourceProviderId);
}

class ProjectSourcesCompanion extends UpdateCompanion<ProjectSource> {
  final Value<int> projectId;
  final Value<String> sourceProviderId;
  final Value<int> rowid;
  const ProjectSourcesCompanion({
    this.projectId = const Value.absent(),
    this.sourceProviderId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectSourcesCompanion.insert({
    required int projectId,
    required String sourceProviderId,
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       sourceProviderId = Value(sourceProviderId);
  static Insertable<ProjectSource> custom({
    Expression<int>? projectId,
    Expression<String>? sourceProviderId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (sourceProviderId != null) 'source_provider_id': sourceProviderId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectSourcesCompanion copyWith({
    Value<int>? projectId,
    Value<String>? sourceProviderId,
    Value<int>? rowid,
  }) {
    return ProjectSourcesCompanion(
      projectId: projectId ?? this.projectId,
      sourceProviderId: sourceProviderId ?? this.sourceProviderId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (sourceProviderId.present) {
      map['source_provider_id'] = Variable<String>(sourceProviderId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectSourcesCompanion(')
          ..write('projectId: $projectId, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredArtworkIdMeta =
      const VerificationMeta('preferredArtworkId');
  @override
  late final GeneratedColumn<int> preferredArtworkId = GeneratedColumn<int>(
    'preferred_artwork_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedFlavorTextIdMeta =
      const VerificationMeta('selectedFlavorTextId');
  @override
  late final GeneratedColumn<int> selectedFlavorTextId = GeneratedColumn<int>(
    'selected_flavor_text_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customFlavorTextMeta = const VerificationMeta(
    'customFlavorText',
  );
  @override
  late final GeneratedColumn<String> customFlavorText = GeneratedColumn<String>(
    'custom_flavor_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noFlavorTextMeta = const VerificationMeta(
    'noFlavorText',
  );
  @override
  late final GeneratedColumn<bool> noFlavorText = GeneratedColumn<bool>(
    'no_flavor_text',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("no_flavor_text" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _selectedSetCodeMeta = const VerificationMeta(
    'selectedSetCode',
  );
  @override
  late final GeneratedColumn<String> selectedSetCode = GeneratedColumn<String>(
    'selected_extension_set',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedSetLangMeta = const VerificationMeta(
    'selectedSetLang',
  );
  @override
  late final GeneratedColumn<String> selectedSetLang = GeneratedColumn<String>(
    'selected_extension_lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedSetIsVoidMeta = const VerificationMeta(
    'selectedSetIsVoid',
  );
  @override
  late final GeneratedColumn<bool> selectedSetIsVoid = GeneratedColumn<bool>(
    'selected_extension_is_void',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("selected_extension_is_void" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _layoutMeta = const VerificationMeta('layout');
  @override
  late final GeneratedColumn<String> layout = GeneratedColumn<String>(
    'layout',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardTypeMeta = const VerificationMeta(
    'cardType',
  );
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
    'card_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frameMeta = const VerificationMeta('frame');
  @override
  late final GeneratedColumn<String> frame = GeneratedColumn<String>(
    'frame',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scryfallIdMeta = const VerificationMeta(
    'scryfallId',
  );
  @override
  late final GeneratedColumn<String> scryfallId = GeneratedColumn<String>(
    'scryfall_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isUpToDateMeta = const VerificationMeta(
    'isUpToDate',
  );
  @override
  late final GeneratedColumn<bool> isUpToDate = GeneratedColumn<bool>(
    'is_up_to_date',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_up_to_date" IN (0, 1))',
    ),
  );
  static const VerificationMeta _selectedCollectorNumberMeta =
      const VerificationMeta('selectedCollectorNumber');
  @override
  late final GeneratedColumn<String> selectedCollectorNumber =
      GeneratedColumn<String>(
        'selected_collector_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dfcSiblingIdMeta = const VerificationMeta(
    'dfcSiblingId',
  );
  @override
  late final GeneratedColumn<int> dfcSiblingId = GeneratedColumn<int>(
    'dfc_sibling_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    name,
    normalizedName,
    preferredArtworkId,
    selectedFlavorTextId,
    customFlavorText,
    noFlavorText,
    selectedSetCode,
    selectedSetLang,
    selectedSetIsVoid,
    layout,
    cardType,
    frame,
    scryfallId,
    isUpToDate,
    selectedCollectorNumber,
    dfcSiblingId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('preferred_artwork_id')) {
      context.handle(
        _preferredArtworkIdMeta,
        preferredArtworkId.isAcceptableOrUnknown(
          data['preferred_artwork_id']!,
          _preferredArtworkIdMeta,
        ),
      );
    }
    if (data.containsKey('selected_flavor_text_id')) {
      context.handle(
        _selectedFlavorTextIdMeta,
        selectedFlavorTextId.isAcceptableOrUnknown(
          data['selected_flavor_text_id']!,
          _selectedFlavorTextIdMeta,
        ),
      );
    }
    if (data.containsKey('custom_flavor_text')) {
      context.handle(
        _customFlavorTextMeta,
        customFlavorText.isAcceptableOrUnknown(
          data['custom_flavor_text']!,
          _customFlavorTextMeta,
        ),
      );
    }
    if (data.containsKey('no_flavor_text')) {
      context.handle(
        _noFlavorTextMeta,
        noFlavorText.isAcceptableOrUnknown(
          data['no_flavor_text']!,
          _noFlavorTextMeta,
        ),
      );
    }
    if (data.containsKey('selected_extension_set')) {
      context.handle(
        _selectedSetCodeMeta,
        selectedSetCode.isAcceptableOrUnknown(
          data['selected_extension_set']!,
          _selectedSetCodeMeta,
        ),
      );
    }
    if (data.containsKey('selected_extension_lang')) {
      context.handle(
        _selectedSetLangMeta,
        selectedSetLang.isAcceptableOrUnknown(
          data['selected_extension_lang']!,
          _selectedSetLangMeta,
        ),
      );
    }
    if (data.containsKey('selected_extension_is_void')) {
      context.handle(
        _selectedSetIsVoidMeta,
        selectedSetIsVoid.isAcceptableOrUnknown(
          data['selected_extension_is_void']!,
          _selectedSetIsVoidMeta,
        ),
      );
    }
    if (data.containsKey('layout')) {
      context.handle(
        _layoutMeta,
        layout.isAcceptableOrUnknown(data['layout']!, _layoutMeta),
      );
    }
    if (data.containsKey('card_type')) {
      context.handle(
        _cardTypeMeta,
        cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta),
      );
    }
    if (data.containsKey('frame')) {
      context.handle(
        _frameMeta,
        frame.isAcceptableOrUnknown(data['frame']!, _frameMeta),
      );
    }
    if (data.containsKey('scryfall_id')) {
      context.handle(
        _scryfallIdMeta,
        scryfallId.isAcceptableOrUnknown(data['scryfall_id']!, _scryfallIdMeta),
      );
    }
    if (data.containsKey('is_up_to_date')) {
      context.handle(
        _isUpToDateMeta,
        isUpToDate.isAcceptableOrUnknown(
          data['is_up_to_date']!,
          _isUpToDateMeta,
        ),
      );
    }
    if (data.containsKey('selected_collector_number')) {
      context.handle(
        _selectedCollectorNumberMeta,
        selectedCollectorNumber.isAcceptableOrUnknown(
          data['selected_collector_number']!,
          _selectedCollectorNumberMeta,
        ),
      );
    }
    if (data.containsKey('dfc_sibling_id')) {
      context.handle(
        _dfcSiblingIdMeta,
        dfcSiblingId.isAcceptableOrUnknown(
          data['dfc_sibling_id']!,
          _dfcSiblingIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      preferredArtworkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred_artwork_id'],
      ),
      selectedFlavorTextId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_flavor_text_id'],
      ),
      customFlavorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_flavor_text'],
      ),
      noFlavorText: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}no_flavor_text'],
      )!,
      selectedSetCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_extension_set'],
      ),
      selectedSetLang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_extension_lang'],
      ),
      selectedSetIsVoid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}selected_extension_is_void'],
      )!,
      layout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout'],
      ),
      cardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_type'],
      ),
      frame: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame'],
      ),
      scryfallId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scryfall_id'],
      ),
      isUpToDate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_up_to_date'],
      ),
      selectedCollectorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_collector_number'],
      ),
      dfcSiblingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dfc_sibling_id'],
      ),
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final int id;
  final int projectId;
  final String name;
  final String normalizedName;
  final int? preferredArtworkId;
  final int? selectedFlavorTextId;
  final String? customFlavorText;
  final bool noFlavorText;
  final String? selectedSetCode;
  final String? selectedSetLang;
  final bool selectedSetIsVoid;
  final String? layout;
  final String? cardType;
  final String? frame;
  final String? scryfallId;
  final bool? isUpToDate;
  final String? selectedCollectorNumber;
  final int? dfcSiblingId;
  const Card({
    required this.id,
    required this.projectId,
    required this.name,
    required this.normalizedName,
    this.preferredArtworkId,
    this.selectedFlavorTextId,
    this.customFlavorText,
    required this.noFlavorText,
    this.selectedSetCode,
    this.selectedSetLang,
    required this.selectedSetIsVoid,
    this.layout,
    this.cardType,
    this.frame,
    this.scryfallId,
    this.isUpToDate,
    this.selectedCollectorNumber,
    this.dfcSiblingId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || preferredArtworkId != null) {
      map['preferred_artwork_id'] = Variable<int>(preferredArtworkId);
    }
    if (!nullToAbsent || selectedFlavorTextId != null) {
      map['selected_flavor_text_id'] = Variable<int>(selectedFlavorTextId);
    }
    if (!nullToAbsent || customFlavorText != null) {
      map['custom_flavor_text'] = Variable<String>(customFlavorText);
    }
    map['no_flavor_text'] = Variable<bool>(noFlavorText);
    if (!nullToAbsent || selectedSetCode != null) {
      map['selected_extension_set'] = Variable<String>(selectedSetCode);
    }
    if (!nullToAbsent || selectedSetLang != null) {
      map['selected_extension_lang'] = Variable<String>(selectedSetLang);
    }
    map['selected_extension_is_void'] = Variable<bool>(selectedSetIsVoid);
    if (!nullToAbsent || layout != null) {
      map['layout'] = Variable<String>(layout);
    }
    if (!nullToAbsent || cardType != null) {
      map['card_type'] = Variable<String>(cardType);
    }
    if (!nullToAbsent || frame != null) {
      map['frame'] = Variable<String>(frame);
    }
    if (!nullToAbsent || scryfallId != null) {
      map['scryfall_id'] = Variable<String>(scryfallId);
    }
    if (!nullToAbsent || isUpToDate != null) {
      map['is_up_to_date'] = Variable<bool>(isUpToDate);
    }
    if (!nullToAbsent || selectedCollectorNumber != null) {
      map['selected_collector_number'] = Variable<String>(
        selectedCollectorNumber,
      );
    }
    if (!nullToAbsent || dfcSiblingId != null) {
      map['dfc_sibling_id'] = Variable<int>(dfcSiblingId);
    }
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      preferredArtworkId: preferredArtworkId == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredArtworkId),
      selectedFlavorTextId: selectedFlavorTextId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedFlavorTextId),
      customFlavorText: customFlavorText == null && nullToAbsent
          ? const Value.absent()
          : Value(customFlavorText),
      noFlavorText: Value(noFlavorText),
      selectedSetCode: selectedSetCode == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedSetCode),
      selectedSetLang: selectedSetLang == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedSetLang),
      selectedSetIsVoid: Value(selectedSetIsVoid),
      layout: layout == null && nullToAbsent
          ? const Value.absent()
          : Value(layout),
      cardType: cardType == null && nullToAbsent
          ? const Value.absent()
          : Value(cardType),
      frame: frame == null && nullToAbsent
          ? const Value.absent()
          : Value(frame),
      scryfallId: scryfallId == null && nullToAbsent
          ? const Value.absent()
          : Value(scryfallId),
      isUpToDate: isUpToDate == null && nullToAbsent
          ? const Value.absent()
          : Value(isUpToDate),
      selectedCollectorNumber: selectedCollectorNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedCollectorNumber),
      dfcSiblingId: dfcSiblingId == null && nullToAbsent
          ? const Value.absent()
          : Value(dfcSiblingId),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      preferredArtworkId: serializer.fromJson<int?>(json['preferredArtworkId']),
      selectedFlavorTextId: serializer.fromJson<int?>(
        json['selectedFlavorTextId'],
      ),
      customFlavorText: serializer.fromJson<String?>(json['customFlavorText']),
      noFlavorText: serializer.fromJson<bool>(json['noFlavorText']),
      selectedSetCode: serializer.fromJson<String?>(json['selectedSetCode']),
      selectedSetLang: serializer.fromJson<String?>(json['selectedSetLang']),
      selectedSetIsVoid: serializer.fromJson<bool>(json['selectedSetIsVoid']),
      layout: serializer.fromJson<String?>(json['layout']),
      cardType: serializer.fromJson<String?>(json['cardType']),
      frame: serializer.fromJson<String?>(json['frame']),
      scryfallId: serializer.fromJson<String?>(json['scryfallId']),
      isUpToDate: serializer.fromJson<bool?>(json['isUpToDate']),
      selectedCollectorNumber: serializer.fromJson<String?>(
        json['selectedCollectorNumber'],
      ),
      dfcSiblingId: serializer.fromJson<int?>(json['dfcSiblingId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'preferredArtworkId': serializer.toJson<int?>(preferredArtworkId),
      'selectedFlavorTextId': serializer.toJson<int?>(selectedFlavorTextId),
      'customFlavorText': serializer.toJson<String?>(customFlavorText),
      'noFlavorText': serializer.toJson<bool>(noFlavorText),
      'selectedSetCode': serializer.toJson<String?>(selectedSetCode),
      'selectedSetLang': serializer.toJson<String?>(selectedSetLang),
      'selectedSetIsVoid': serializer.toJson<bool>(selectedSetIsVoid),
      'layout': serializer.toJson<String?>(layout),
      'cardType': serializer.toJson<String?>(cardType),
      'frame': serializer.toJson<String?>(frame),
      'scryfallId': serializer.toJson<String?>(scryfallId),
      'isUpToDate': serializer.toJson<bool?>(isUpToDate),
      'selectedCollectorNumber': serializer.toJson<String?>(
        selectedCollectorNumber,
      ),
      'dfcSiblingId': serializer.toJson<int?>(dfcSiblingId),
    };
  }

  Card copyWith({
    int? id,
    int? projectId,
    String? name,
    String? normalizedName,
    Value<int?> preferredArtworkId = const Value.absent(),
    Value<int?> selectedFlavorTextId = const Value.absent(),
    Value<String?> customFlavorText = const Value.absent(),
    bool? noFlavorText,
    Value<String?> selectedSetCode = const Value.absent(),
    Value<String?> selectedSetLang = const Value.absent(),
    bool? selectedSetIsVoid,
    Value<String?> layout = const Value.absent(),
    Value<String?> cardType = const Value.absent(),
    Value<String?> frame = const Value.absent(),
    Value<String?> scryfallId = const Value.absent(),
    Value<bool?> isUpToDate = const Value.absent(),
    Value<String?> selectedCollectorNumber = const Value.absent(),
    Value<int?> dfcSiblingId = const Value.absent(),
  }) => Card(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    preferredArtworkId: preferredArtworkId.present
        ? preferredArtworkId.value
        : this.preferredArtworkId,
    selectedFlavorTextId: selectedFlavorTextId.present
        ? selectedFlavorTextId.value
        : this.selectedFlavorTextId,
    customFlavorText: customFlavorText.present
        ? customFlavorText.value
        : this.customFlavorText,
    noFlavorText: noFlavorText ?? this.noFlavorText,
    selectedSetCode: selectedSetCode.present
        ? selectedSetCode.value
        : this.selectedSetCode,
    selectedSetLang: selectedSetLang.present
        ? selectedSetLang.value
        : this.selectedSetLang,
    selectedSetIsVoid: selectedSetIsVoid ?? this.selectedSetIsVoid,
    layout: layout.present ? layout.value : this.layout,
    cardType: cardType.present ? cardType.value : this.cardType,
    frame: frame.present ? frame.value : this.frame,
    scryfallId: scryfallId.present ? scryfallId.value : this.scryfallId,
    isUpToDate: isUpToDate.present ? isUpToDate.value : this.isUpToDate,
    selectedCollectorNumber: selectedCollectorNumber.present
        ? selectedCollectorNumber.value
        : this.selectedCollectorNumber,
    dfcSiblingId: dfcSiblingId.present ? dfcSiblingId.value : this.dfcSiblingId,
  );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      preferredArtworkId: data.preferredArtworkId.present
          ? data.preferredArtworkId.value
          : this.preferredArtworkId,
      selectedFlavorTextId: data.selectedFlavorTextId.present
          ? data.selectedFlavorTextId.value
          : this.selectedFlavorTextId,
      customFlavorText: data.customFlavorText.present
          ? data.customFlavorText.value
          : this.customFlavorText,
      noFlavorText: data.noFlavorText.present
          ? data.noFlavorText.value
          : this.noFlavorText,
      selectedSetCode: data.selectedSetCode.present
          ? data.selectedSetCode.value
          : this.selectedSetCode,
      selectedSetLang: data.selectedSetLang.present
          ? data.selectedSetLang.value
          : this.selectedSetLang,
      selectedSetIsVoid: data.selectedSetIsVoid.present
          ? data.selectedSetIsVoid.value
          : this.selectedSetIsVoid,
      layout: data.layout.present ? data.layout.value : this.layout,
      cardType: data.cardType.present ? data.cardType.value : this.cardType,
      frame: data.frame.present ? data.frame.value : this.frame,
      scryfallId: data.scryfallId.present
          ? data.scryfallId.value
          : this.scryfallId,
      isUpToDate: data.isUpToDate.present
          ? data.isUpToDate.value
          : this.isUpToDate,
      selectedCollectorNumber: data.selectedCollectorNumber.present
          ? data.selectedCollectorNumber.value
          : this.selectedCollectorNumber,
      dfcSiblingId: data.dfcSiblingId.present
          ? data.dfcSiblingId.value
          : this.dfcSiblingId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('preferredArtworkId: $preferredArtworkId, ')
          ..write('selectedFlavorTextId: $selectedFlavorTextId, ')
          ..write('customFlavorText: $customFlavorText, ')
          ..write('noFlavorText: $noFlavorText, ')
          ..write('selectedSetCode: $selectedSetCode, ')
          ..write('selectedSetLang: $selectedSetLang, ')
          ..write('selectedSetIsVoid: $selectedSetIsVoid, ')
          ..write('layout: $layout, ')
          ..write('cardType: $cardType, ')
          ..write('frame: $frame, ')
          ..write('scryfallId: $scryfallId, ')
          ..write('isUpToDate: $isUpToDate, ')
          ..write('selectedCollectorNumber: $selectedCollectorNumber, ')
          ..write('dfcSiblingId: $dfcSiblingId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    name,
    normalizedName,
    preferredArtworkId,
    selectedFlavorTextId,
    customFlavorText,
    noFlavorText,
    selectedSetCode,
    selectedSetLang,
    selectedSetIsVoid,
    layout,
    cardType,
    frame,
    scryfallId,
    isUpToDate,
    selectedCollectorNumber,
    dfcSiblingId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.preferredArtworkId == this.preferredArtworkId &&
          other.selectedFlavorTextId == this.selectedFlavorTextId &&
          other.customFlavorText == this.customFlavorText &&
          other.noFlavorText == this.noFlavorText &&
          other.selectedSetCode == this.selectedSetCode &&
          other.selectedSetLang == this.selectedSetLang &&
          other.selectedSetIsVoid == this.selectedSetIsVoid &&
          other.layout == this.layout &&
          other.cardType == this.cardType &&
          other.frame == this.frame &&
          other.scryfallId == this.scryfallId &&
          other.isUpToDate == this.isUpToDate &&
          other.selectedCollectorNumber == this.selectedCollectorNumber &&
          other.dfcSiblingId == this.dfcSiblingId);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<int?> preferredArtworkId;
  final Value<int?> selectedFlavorTextId;
  final Value<String?> customFlavorText;
  final Value<bool> noFlavorText;
  final Value<String?> selectedSetCode;
  final Value<String?> selectedSetLang;
  final Value<bool> selectedSetIsVoid;
  final Value<String?> layout;
  final Value<String?> cardType;
  final Value<String?> frame;
  final Value<String?> scryfallId;
  final Value<bool?> isUpToDate;
  final Value<String?> selectedCollectorNumber;
  final Value<int?> dfcSiblingId;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.preferredArtworkId = const Value.absent(),
    this.selectedFlavorTextId = const Value.absent(),
    this.customFlavorText = const Value.absent(),
    this.noFlavorText = const Value.absent(),
    this.selectedSetCode = const Value.absent(),
    this.selectedSetLang = const Value.absent(),
    this.selectedSetIsVoid = const Value.absent(),
    this.layout = const Value.absent(),
    this.cardType = const Value.absent(),
    this.frame = const Value.absent(),
    this.scryfallId = const Value.absent(),
    this.isUpToDate = const Value.absent(),
    this.selectedCollectorNumber = const Value.absent(),
    this.dfcSiblingId = const Value.absent(),
  });
  CardsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String name,
    required String normalizedName,
    this.preferredArtworkId = const Value.absent(),
    this.selectedFlavorTextId = const Value.absent(),
    this.customFlavorText = const Value.absent(),
    this.noFlavorText = const Value.absent(),
    this.selectedSetCode = const Value.absent(),
    this.selectedSetLang = const Value.absent(),
    this.selectedSetIsVoid = const Value.absent(),
    this.layout = const Value.absent(),
    this.cardType = const Value.absent(),
    this.frame = const Value.absent(),
    this.scryfallId = const Value.absent(),
    this.isUpToDate = const Value.absent(),
    this.selectedCollectorNumber = const Value.absent(),
    this.dfcSiblingId = const Value.absent(),
  }) : projectId = Value(projectId),
       name = Value(name),
       normalizedName = Value(normalizedName);
  static Insertable<Card> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<int>? preferredArtworkId,
    Expression<int>? selectedFlavorTextId,
    Expression<String>? customFlavorText,
    Expression<bool>? noFlavorText,
    Expression<String>? selectedSetCode,
    Expression<String>? selectedSetLang,
    Expression<bool>? selectedSetIsVoid,
    Expression<String>? layout,
    Expression<String>? cardType,
    Expression<String>? frame,
    Expression<String>? scryfallId,
    Expression<bool>? isUpToDate,
    Expression<String>? selectedCollectorNumber,
    Expression<int>? dfcSiblingId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (preferredArtworkId != null)
        'preferred_artwork_id': preferredArtworkId,
      if (selectedFlavorTextId != null)
        'selected_flavor_text_id': selectedFlavorTextId,
      if (customFlavorText != null) 'custom_flavor_text': customFlavorText,
      if (noFlavorText != null) 'no_flavor_text': noFlavorText,
      if (selectedSetCode != null) 'selected_extension_set': selectedSetCode,
      if (selectedSetLang != null) 'selected_extension_lang': selectedSetLang,
      if (selectedSetIsVoid != null)
        'selected_extension_is_void': selectedSetIsVoid,
      if (layout != null) 'layout': layout,
      if (cardType != null) 'card_type': cardType,
      if (frame != null) 'frame': frame,
      if (scryfallId != null) 'scryfall_id': scryfallId,
      if (isUpToDate != null) 'is_up_to_date': isUpToDate,
      if (selectedCollectorNumber != null)
        'selected_collector_number': selectedCollectorNumber,
      if (dfcSiblingId != null) 'dfc_sibling_id': dfcSiblingId,
    });
  }

  CardsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<int?>? preferredArtworkId,
    Value<int?>? selectedFlavorTextId,
    Value<String?>? customFlavorText,
    Value<bool>? noFlavorText,
    Value<String?>? selectedSetCode,
    Value<String?>? selectedSetLang,
    Value<bool>? selectedSetIsVoid,
    Value<String?>? layout,
    Value<String?>? cardType,
    Value<String?>? frame,
    Value<String?>? scryfallId,
    Value<bool?>? isUpToDate,
    Value<String?>? selectedCollectorNumber,
    Value<int?>? dfcSiblingId,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      preferredArtworkId: preferredArtworkId ?? this.preferredArtworkId,
      selectedFlavorTextId: selectedFlavorTextId ?? this.selectedFlavorTextId,
      customFlavorText: customFlavorText ?? this.customFlavorText,
      noFlavorText: noFlavorText ?? this.noFlavorText,
      selectedSetCode: selectedSetCode ?? this.selectedSetCode,
      selectedSetLang: selectedSetLang ?? this.selectedSetLang,
      selectedSetIsVoid: selectedSetIsVoid ?? this.selectedSetIsVoid,
      layout: layout ?? this.layout,
      cardType: cardType ?? this.cardType,
      frame: frame ?? this.frame,
      scryfallId: scryfallId ?? this.scryfallId,
      isUpToDate: isUpToDate ?? this.isUpToDate,
      selectedCollectorNumber:
          selectedCollectorNumber ?? this.selectedCollectorNumber,
      dfcSiblingId: dfcSiblingId ?? this.dfcSiblingId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (preferredArtworkId.present) {
      map['preferred_artwork_id'] = Variable<int>(preferredArtworkId.value);
    }
    if (selectedFlavorTextId.present) {
      map['selected_flavor_text_id'] = Variable<int>(
        selectedFlavorTextId.value,
      );
    }
    if (customFlavorText.present) {
      map['custom_flavor_text'] = Variable<String>(customFlavorText.value);
    }
    if (noFlavorText.present) {
      map['no_flavor_text'] = Variable<bool>(noFlavorText.value);
    }
    if (selectedSetCode.present) {
      map['selected_extension_set'] = Variable<String>(selectedSetCode.value);
    }
    if (selectedSetLang.present) {
      map['selected_extension_lang'] = Variable<String>(selectedSetLang.value);
    }
    if (selectedSetIsVoid.present) {
      map['selected_extension_is_void'] = Variable<bool>(
        selectedSetIsVoid.value,
      );
    }
    if (layout.present) {
      map['layout'] = Variable<String>(layout.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (frame.present) {
      map['frame'] = Variable<String>(frame.value);
    }
    if (scryfallId.present) {
      map['scryfall_id'] = Variable<String>(scryfallId.value);
    }
    if (isUpToDate.present) {
      map['is_up_to_date'] = Variable<bool>(isUpToDate.value);
    }
    if (selectedCollectorNumber.present) {
      map['selected_collector_number'] = Variable<String>(
        selectedCollectorNumber.value,
      );
    }
    if (dfcSiblingId.present) {
      map['dfc_sibling_id'] = Variable<int>(dfcSiblingId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('preferredArtworkId: $preferredArtworkId, ')
          ..write('selectedFlavorTextId: $selectedFlavorTextId, ')
          ..write('customFlavorText: $customFlavorText, ')
          ..write('noFlavorText: $noFlavorText, ')
          ..write('selectedSetCode: $selectedSetCode, ')
          ..write('selectedSetLang: $selectedSetLang, ')
          ..write('selectedSetIsVoid: $selectedSetIsVoid, ')
          ..write('layout: $layout, ')
          ..write('cardType: $cardType, ')
          ..write('frame: $frame, ')
          ..write('scryfallId: $scryfallId, ')
          ..write('isUpToDate: $isUpToDate, ')
          ..write('selectedCollectorNumber: $selectedCollectorNumber, ')
          ..write('dfcSiblingId: $dfcSiblingId')
          ..write(')'))
        .toString();
  }
}

class $ArtworksTable extends Artworks with TableInfo<$ArtworksTable, Artwork> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtworksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceProviderIdMeta = const VerificationMeta(
    'sourceProviderId',
  );
  @override
  late final GeneratedColumn<String> sourceProviderId = GeneratedColumn<String>(
    'source_provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printingSetMeta = const VerificationMeta(
    'printingSet',
  );
  @override
  late final GeneratedColumn<String> printingSet = GeneratedColumn<String>(
    'printing_set',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printingCollectorNumberMeta =
      const VerificationMeta('printingCollectorNumber');
  @override
  late final GeneratedColumn<String> printingCollectorNumber =
      GeneratedColumn<String>(
        'printing_collector_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _magicVilleRefMeta = const VerificationMeta(
    'magicVilleRef',
  );
  @override
  late final GeneratedColumn<String> magicVilleRef = GeneratedColumn<String>(
    'magic_ville_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDiscardedMeta = const VerificationMeta(
    'isDiscarded',
  );
  @override
  late final GeneratedColumn<bool> isDiscarded = GeneratedColumn<bool>(
    'is_discarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_discarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    sourceProviderId,
    remoteId,
    printingSet,
    printingCollectorNumber,
    magicVilleRef,
    artist,
    width,
    height,
    sourceUrl,
    localPath,
    downloadedAt,
    isDiscarded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artworks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Artwork> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('source_provider_id')) {
      context.handle(
        _sourceProviderIdMeta,
        sourceProviderId.isAcceptableOrUnknown(
          data['source_provider_id']!,
          _sourceProviderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceProviderIdMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('printing_set')) {
      context.handle(
        _printingSetMeta,
        printingSet.isAcceptableOrUnknown(
          data['printing_set']!,
          _printingSetMeta,
        ),
      );
    }
    if (data.containsKey('printing_collector_number')) {
      context.handle(
        _printingCollectorNumberMeta,
        printingCollectorNumber.isAcceptableOrUnknown(
          data['printing_collector_number']!,
          _printingCollectorNumberMeta,
        ),
      );
    }
    if (data.containsKey('magic_ville_ref')) {
      context.handle(
        _magicVilleRefMeta,
        magicVilleRef.isAcceptableOrUnknown(
          data['magic_ville_ref']!,
          _magicVilleRefMeta,
        ),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('is_discarded')) {
      context.handle(
        _isDiscardedMeta,
        isDiscarded.isAcceptableOrUnknown(
          data['is_discarded']!,
          _isDiscardedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Artwork map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Artwork(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      sourceProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_provider_id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      printingSet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printing_set'],
      ),
      printingCollectorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printing_collector_number'],
      ),
      magicVilleRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}magic_ville_ref'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      isDiscarded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_discarded'],
      )!,
    );
  }

  @override
  $ArtworksTable createAlias(String alias) {
    return $ArtworksTable(attachedDatabase, alias);
  }
}

class Artwork extends DataClass implements Insertable<Artwork> {
  final int id;
  final int cardId;
  final String sourceProviderId;
  final String? remoteId;
  final String? printingSet;
  final String? printingCollectorNumber;
  final String? magicVilleRef;
  final String artist;
  final int width;
  final int height;
  final String sourceUrl;
  final String localPath;
  final DateTime downloadedAt;
  final bool isDiscarded;
  const Artwork({
    required this.id,
    required this.cardId,
    required this.sourceProviderId,
    this.remoteId,
    this.printingSet,
    this.printingCollectorNumber,
    this.magicVilleRef,
    required this.artist,
    required this.width,
    required this.height,
    required this.sourceUrl,
    required this.localPath,
    required this.downloadedAt,
    required this.isDiscarded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['source_provider_id'] = Variable<String>(sourceProviderId);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || printingSet != null) {
      map['printing_set'] = Variable<String>(printingSet);
    }
    if (!nullToAbsent || printingCollectorNumber != null) {
      map['printing_collector_number'] = Variable<String>(
        printingCollectorNumber,
      );
    }
    if (!nullToAbsent || magicVilleRef != null) {
      map['magic_ville_ref'] = Variable<String>(magicVilleRef);
    }
    map['artist'] = Variable<String>(artist);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['source_url'] = Variable<String>(sourceUrl);
    map['local_path'] = Variable<String>(localPath);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    map['is_discarded'] = Variable<bool>(isDiscarded);
    return map;
  }

  ArtworksCompanion toCompanion(bool nullToAbsent) {
    return ArtworksCompanion(
      id: Value(id),
      cardId: Value(cardId),
      sourceProviderId: Value(sourceProviderId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      printingSet: printingSet == null && nullToAbsent
          ? const Value.absent()
          : Value(printingSet),
      printingCollectorNumber: printingCollectorNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(printingCollectorNumber),
      magicVilleRef: magicVilleRef == null && nullToAbsent
          ? const Value.absent()
          : Value(magicVilleRef),
      artist: Value(artist),
      width: Value(width),
      height: Value(height),
      sourceUrl: Value(sourceUrl),
      localPath: Value(localPath),
      downloadedAt: Value(downloadedAt),
      isDiscarded: Value(isDiscarded),
    );
  }

  factory Artwork.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Artwork(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      sourceProviderId: serializer.fromJson<String>(json['sourceProviderId']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      printingSet: serializer.fromJson<String?>(json['printingSet']),
      printingCollectorNumber: serializer.fromJson<String?>(
        json['printingCollectorNumber'],
      ),
      magicVilleRef: serializer.fromJson<String?>(json['magicVilleRef']),
      artist: serializer.fromJson<String>(json['artist']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      localPath: serializer.fromJson<String>(json['localPath']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      isDiscarded: serializer.fromJson<bool>(json['isDiscarded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'sourceProviderId': serializer.toJson<String>(sourceProviderId),
      'remoteId': serializer.toJson<String?>(remoteId),
      'printingSet': serializer.toJson<String?>(printingSet),
      'printingCollectorNumber': serializer.toJson<String?>(
        printingCollectorNumber,
      ),
      'magicVilleRef': serializer.toJson<String?>(magicVilleRef),
      'artist': serializer.toJson<String>(artist),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'localPath': serializer.toJson<String>(localPath),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'isDiscarded': serializer.toJson<bool>(isDiscarded),
    };
  }

  Artwork copyWith({
    int? id,
    int? cardId,
    String? sourceProviderId,
    Value<String?> remoteId = const Value.absent(),
    Value<String?> printingSet = const Value.absent(),
    Value<String?> printingCollectorNumber = const Value.absent(),
    Value<String?> magicVilleRef = const Value.absent(),
    String? artist,
    int? width,
    int? height,
    String? sourceUrl,
    String? localPath,
    DateTime? downloadedAt,
    bool? isDiscarded,
  }) => Artwork(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    sourceProviderId: sourceProviderId ?? this.sourceProviderId,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    printingSet: printingSet.present ? printingSet.value : this.printingSet,
    printingCollectorNumber: printingCollectorNumber.present
        ? printingCollectorNumber.value
        : this.printingCollectorNumber,
    magicVilleRef: magicVilleRef.present
        ? magicVilleRef.value
        : this.magicVilleRef,
    artist: artist ?? this.artist,
    width: width ?? this.width,
    height: height ?? this.height,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    localPath: localPath ?? this.localPath,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    isDiscarded: isDiscarded ?? this.isDiscarded,
  );
  Artwork copyWithCompanion(ArtworksCompanion data) {
    return Artwork(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      sourceProviderId: data.sourceProviderId.present
          ? data.sourceProviderId.value
          : this.sourceProviderId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      printingSet: data.printingSet.present
          ? data.printingSet.value
          : this.printingSet,
      printingCollectorNumber: data.printingCollectorNumber.present
          ? data.printingCollectorNumber.value
          : this.printingCollectorNumber,
      magicVilleRef: data.magicVilleRef.present
          ? data.magicVilleRef.value
          : this.magicVilleRef,
      artist: data.artist.present ? data.artist.value : this.artist,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      isDiscarded: data.isDiscarded.present
          ? data.isDiscarded.value
          : this.isDiscarded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Artwork(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('remoteId: $remoteId, ')
          ..write('printingSet: $printingSet, ')
          ..write('printingCollectorNumber: $printingCollectorNumber, ')
          ..write('magicVilleRef: $magicVilleRef, ')
          ..write('artist: $artist, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('localPath: $localPath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('isDiscarded: $isDiscarded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    sourceProviderId,
    remoteId,
    printingSet,
    printingCollectorNumber,
    magicVilleRef,
    artist,
    width,
    height,
    sourceUrl,
    localPath,
    downloadedAt,
    isDiscarded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Artwork &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.sourceProviderId == this.sourceProviderId &&
          other.remoteId == this.remoteId &&
          other.printingSet == this.printingSet &&
          other.printingCollectorNumber == this.printingCollectorNumber &&
          other.magicVilleRef == this.magicVilleRef &&
          other.artist == this.artist &&
          other.width == this.width &&
          other.height == this.height &&
          other.sourceUrl == this.sourceUrl &&
          other.localPath == this.localPath &&
          other.downloadedAt == this.downloadedAt &&
          other.isDiscarded == this.isDiscarded);
}

class ArtworksCompanion extends UpdateCompanion<Artwork> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> sourceProviderId;
  final Value<String?> remoteId;
  final Value<String?> printingSet;
  final Value<String?> printingCollectorNumber;
  final Value<String?> magicVilleRef;
  final Value<String> artist;
  final Value<int> width;
  final Value<int> height;
  final Value<String> sourceUrl;
  final Value<String> localPath;
  final Value<DateTime> downloadedAt;
  final Value<bool> isDiscarded;
  const ArtworksCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.sourceProviderId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.printingSet = const Value.absent(),
    this.printingCollectorNumber = const Value.absent(),
    this.magicVilleRef = const Value.absent(),
    this.artist = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.isDiscarded = const Value.absent(),
  });
  ArtworksCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String sourceProviderId,
    this.remoteId = const Value.absent(),
    this.printingSet = const Value.absent(),
    this.printingCollectorNumber = const Value.absent(),
    this.magicVilleRef = const Value.absent(),
    required String artist,
    required int width,
    required int height,
    required String sourceUrl,
    required String localPath,
    required DateTime downloadedAt,
    this.isDiscarded = const Value.absent(),
  }) : cardId = Value(cardId),
       sourceProviderId = Value(sourceProviderId),
       artist = Value(artist),
       width = Value(width),
       height = Value(height),
       sourceUrl = Value(sourceUrl),
       localPath = Value(localPath),
       downloadedAt = Value(downloadedAt);
  static Insertable<Artwork> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? sourceProviderId,
    Expression<String>? remoteId,
    Expression<String>? printingSet,
    Expression<String>? printingCollectorNumber,
    Expression<String>? magicVilleRef,
    Expression<String>? artist,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? sourceUrl,
    Expression<String>? localPath,
    Expression<DateTime>? downloadedAt,
    Expression<bool>? isDiscarded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (sourceProviderId != null) 'source_provider_id': sourceProviderId,
      if (remoteId != null) 'remote_id': remoteId,
      if (printingSet != null) 'printing_set': printingSet,
      if (printingCollectorNumber != null)
        'printing_collector_number': printingCollectorNumber,
      if (magicVilleRef != null) 'magic_ville_ref': magicVilleRef,
      if (artist != null) 'artist': artist,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (localPath != null) 'local_path': localPath,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (isDiscarded != null) 'is_discarded': isDiscarded,
    });
  }

  ArtworksCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<String>? sourceProviderId,
    Value<String?>? remoteId,
    Value<String?>? printingSet,
    Value<String?>? printingCollectorNumber,
    Value<String?>? magicVilleRef,
    Value<String>? artist,
    Value<int>? width,
    Value<int>? height,
    Value<String>? sourceUrl,
    Value<String>? localPath,
    Value<DateTime>? downloadedAt,
    Value<bool>? isDiscarded,
  }) {
    return ArtworksCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      sourceProviderId: sourceProviderId ?? this.sourceProviderId,
      remoteId: remoteId ?? this.remoteId,
      printingSet: printingSet ?? this.printingSet,
      printingCollectorNumber:
          printingCollectorNumber ?? this.printingCollectorNumber,
      magicVilleRef: magicVilleRef ?? this.magicVilleRef,
      artist: artist ?? this.artist,
      width: width ?? this.width,
      height: height ?? this.height,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      localPath: localPath ?? this.localPath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      isDiscarded: isDiscarded ?? this.isDiscarded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (sourceProviderId.present) {
      map['source_provider_id'] = Variable<String>(sourceProviderId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (printingSet.present) {
      map['printing_set'] = Variable<String>(printingSet.value);
    }
    if (printingCollectorNumber.present) {
      map['printing_collector_number'] = Variable<String>(
        printingCollectorNumber.value,
      );
    }
    if (magicVilleRef.present) {
      map['magic_ville_ref'] = Variable<String>(magicVilleRef.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (isDiscarded.present) {
      map['is_discarded'] = Variable<bool>(isDiscarded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtworksCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('remoteId: $remoteId, ')
          ..write('printingSet: $printingSet, ')
          ..write('printingCollectorNumber: $printingCollectorNumber, ')
          ..write('magicVilleRef: $magicVilleRef, ')
          ..write('artist: $artist, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('localPath: $localPath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('isDiscarded: $isDiscarded')
          ..write(')'))
        .toString();
  }
}

class $FlavorTextOptionsTable extends FlavorTextOptions
    with TableInfo<$FlavorTextOptionsTable, FlavorTextOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlavorTextOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceProviderIdMeta = const VerificationMeta(
    'sourceProviderId',
  );
  @override
  late final GeneratedColumn<String> sourceProviderId = GeneratedColumn<String>(
    'source_provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flavorMeta = const VerificationMeta('flavor');
  @override
  late final GeneratedColumn<String> flavor = GeneratedColumn<String>(
    'flavor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printingSetMeta = const VerificationMeta(
    'printingSet',
  );
  @override
  late final GeneratedColumn<String> printingSet = GeneratedColumn<String>(
    'printing_set',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printingCollectorNumberMeta =
      const VerificationMeta('printingCollectorNumber');
  @override
  late final GeneratedColumn<String> printingCollectorNumber =
      GeneratedColumn<String>(
        'printing_collector_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasLocalizationMeta = const VerificationMeta(
    'hasLocalization',
  );
  @override
  late final GeneratedColumn<bool> hasLocalization = GeneratedColumn<bool>(
    'has_localization',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_localization" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    sourceProviderId,
    flavor,
    printingSet,
    printingCollectorNumber,
    lang,
    hasLocalization,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flavor_text_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlavorTextOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('source_provider_id')) {
      context.handle(
        _sourceProviderIdMeta,
        sourceProviderId.isAcceptableOrUnknown(
          data['source_provider_id']!,
          _sourceProviderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceProviderIdMeta);
    }
    if (data.containsKey('flavor')) {
      context.handle(
        _flavorMeta,
        flavor.isAcceptableOrUnknown(data['flavor']!, _flavorMeta),
      );
    } else if (isInserting) {
      context.missing(_flavorMeta);
    }
    if (data.containsKey('printing_set')) {
      context.handle(
        _printingSetMeta,
        printingSet.isAcceptableOrUnknown(
          data['printing_set']!,
          _printingSetMeta,
        ),
      );
    }
    if (data.containsKey('printing_collector_number')) {
      context.handle(
        _printingCollectorNumberMeta,
        printingCollectorNumber.isAcceptableOrUnknown(
          data['printing_collector_number']!,
          _printingCollectorNumberMeta,
        ),
      );
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    }
    if (data.containsKey('has_localization')) {
      context.handle(
        _hasLocalizationMeta,
        hasLocalization.isAcceptableOrUnknown(
          data['has_localization']!,
          _hasLocalizationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlavorTextOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlavorTextOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      sourceProviderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_provider_id'],
      )!,
      flavor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor'],
      )!,
      printingSet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printing_set'],
      ),
      printingCollectorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printing_collector_number'],
      ),
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      ),
      hasLocalization: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_localization'],
      ),
    );
  }

  @override
  $FlavorTextOptionsTable createAlias(String alias) {
    return $FlavorTextOptionsTable(attachedDatabase, alias);
  }
}

class FlavorTextOption extends DataClass
    implements Insertable<FlavorTextOption> {
  final int id;
  final int cardId;
  final String sourceProviderId;
  final String flavor;
  final String? printingSet;
  final String? printingCollectorNumber;
  final String? lang;
  final bool? hasLocalization;
  const FlavorTextOption({
    required this.id,
    required this.cardId,
    required this.sourceProviderId,
    required this.flavor,
    this.printingSet,
    this.printingCollectorNumber,
    this.lang,
    this.hasLocalization,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['source_provider_id'] = Variable<String>(sourceProviderId);
    map['flavor'] = Variable<String>(flavor);
    if (!nullToAbsent || printingSet != null) {
      map['printing_set'] = Variable<String>(printingSet);
    }
    if (!nullToAbsent || printingCollectorNumber != null) {
      map['printing_collector_number'] = Variable<String>(
        printingCollectorNumber,
      );
    }
    if (!nullToAbsent || lang != null) {
      map['lang'] = Variable<String>(lang);
    }
    if (!nullToAbsent || hasLocalization != null) {
      map['has_localization'] = Variable<bool>(hasLocalization);
    }
    return map;
  }

  FlavorTextOptionsCompanion toCompanion(bool nullToAbsent) {
    return FlavorTextOptionsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      sourceProviderId: Value(sourceProviderId),
      flavor: Value(flavor),
      printingSet: printingSet == null && nullToAbsent
          ? const Value.absent()
          : Value(printingSet),
      printingCollectorNumber: printingCollectorNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(printingCollectorNumber),
      lang: lang == null && nullToAbsent ? const Value.absent() : Value(lang),
      hasLocalization: hasLocalization == null && nullToAbsent
          ? const Value.absent()
          : Value(hasLocalization),
    );
  }

  factory FlavorTextOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlavorTextOption(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      sourceProviderId: serializer.fromJson<String>(json['sourceProviderId']),
      flavor: serializer.fromJson<String>(json['flavor']),
      printingSet: serializer.fromJson<String?>(json['printingSet']),
      printingCollectorNumber: serializer.fromJson<String?>(
        json['printingCollectorNumber'],
      ),
      lang: serializer.fromJson<String?>(json['lang']),
      hasLocalization: serializer.fromJson<bool?>(json['hasLocalization']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'sourceProviderId': serializer.toJson<String>(sourceProviderId),
      'flavor': serializer.toJson<String>(flavor),
      'printingSet': serializer.toJson<String?>(printingSet),
      'printingCollectorNumber': serializer.toJson<String?>(
        printingCollectorNumber,
      ),
      'lang': serializer.toJson<String?>(lang),
      'hasLocalization': serializer.toJson<bool?>(hasLocalization),
    };
  }

  FlavorTextOption copyWith({
    int? id,
    int? cardId,
    String? sourceProviderId,
    String? flavor,
    Value<String?> printingSet = const Value.absent(),
    Value<String?> printingCollectorNumber = const Value.absent(),
    Value<String?> lang = const Value.absent(),
    Value<bool?> hasLocalization = const Value.absent(),
  }) => FlavorTextOption(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    sourceProviderId: sourceProviderId ?? this.sourceProviderId,
    flavor: flavor ?? this.flavor,
    printingSet: printingSet.present ? printingSet.value : this.printingSet,
    printingCollectorNumber: printingCollectorNumber.present
        ? printingCollectorNumber.value
        : this.printingCollectorNumber,
    lang: lang.present ? lang.value : this.lang,
    hasLocalization: hasLocalization.present
        ? hasLocalization.value
        : this.hasLocalization,
  );
  FlavorTextOption copyWithCompanion(FlavorTextOptionsCompanion data) {
    return FlavorTextOption(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      sourceProviderId: data.sourceProviderId.present
          ? data.sourceProviderId.value
          : this.sourceProviderId,
      flavor: data.flavor.present ? data.flavor.value : this.flavor,
      printingSet: data.printingSet.present
          ? data.printingSet.value
          : this.printingSet,
      printingCollectorNumber: data.printingCollectorNumber.present
          ? data.printingCollectorNumber.value
          : this.printingCollectorNumber,
      lang: data.lang.present ? data.lang.value : this.lang,
      hasLocalization: data.hasLocalization.present
          ? data.hasLocalization.value
          : this.hasLocalization,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlavorTextOption(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('flavor: $flavor, ')
          ..write('printingSet: $printingSet, ')
          ..write('printingCollectorNumber: $printingCollectorNumber, ')
          ..write('lang: $lang, ')
          ..write('hasLocalization: $hasLocalization')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    sourceProviderId,
    flavor,
    printingSet,
    printingCollectorNumber,
    lang,
    hasLocalization,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlavorTextOption &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.sourceProviderId == this.sourceProviderId &&
          other.flavor == this.flavor &&
          other.printingSet == this.printingSet &&
          other.printingCollectorNumber == this.printingCollectorNumber &&
          other.lang == this.lang &&
          other.hasLocalization == this.hasLocalization);
}

class FlavorTextOptionsCompanion extends UpdateCompanion<FlavorTextOption> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> sourceProviderId;
  final Value<String> flavor;
  final Value<String?> printingSet;
  final Value<String?> printingCollectorNumber;
  final Value<String?> lang;
  final Value<bool?> hasLocalization;
  const FlavorTextOptionsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.sourceProviderId = const Value.absent(),
    this.flavor = const Value.absent(),
    this.printingSet = const Value.absent(),
    this.printingCollectorNumber = const Value.absent(),
    this.lang = const Value.absent(),
    this.hasLocalization = const Value.absent(),
  });
  FlavorTextOptionsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String sourceProviderId,
    required String flavor,
    this.printingSet = const Value.absent(),
    this.printingCollectorNumber = const Value.absent(),
    this.lang = const Value.absent(),
    this.hasLocalization = const Value.absent(),
  }) : cardId = Value(cardId),
       sourceProviderId = Value(sourceProviderId),
       flavor = Value(flavor);
  static Insertable<FlavorTextOption> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? sourceProviderId,
    Expression<String>? flavor,
    Expression<String>? printingSet,
    Expression<String>? printingCollectorNumber,
    Expression<String>? lang,
    Expression<bool>? hasLocalization,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (sourceProviderId != null) 'source_provider_id': sourceProviderId,
      if (flavor != null) 'flavor': flavor,
      if (printingSet != null) 'printing_set': printingSet,
      if (printingCollectorNumber != null)
        'printing_collector_number': printingCollectorNumber,
      if (lang != null) 'lang': lang,
      if (hasLocalization != null) 'has_localization': hasLocalization,
    });
  }

  FlavorTextOptionsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<String>? sourceProviderId,
    Value<String>? flavor,
    Value<String?>? printingSet,
    Value<String?>? printingCollectorNumber,
    Value<String?>? lang,
    Value<bool?>? hasLocalization,
  }) {
    return FlavorTextOptionsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      sourceProviderId: sourceProviderId ?? this.sourceProviderId,
      flavor: flavor ?? this.flavor,
      printingSet: printingSet ?? this.printingSet,
      printingCollectorNumber:
          printingCollectorNumber ?? this.printingCollectorNumber,
      lang: lang ?? this.lang,
      hasLocalization: hasLocalization ?? this.hasLocalization,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (sourceProviderId.present) {
      map['source_provider_id'] = Variable<String>(sourceProviderId.value);
    }
    if (flavor.present) {
      map['flavor'] = Variable<String>(flavor.value);
    }
    if (printingSet.present) {
      map['printing_set'] = Variable<String>(printingSet.value);
    }
    if (printingCollectorNumber.present) {
      map['printing_collector_number'] = Variable<String>(
        printingCollectorNumber.value,
      );
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (hasLocalization.present) {
      map['has_localization'] = Variable<bool>(hasLocalization.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlavorTextOptionsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('sourceProviderId: $sourceProviderId, ')
          ..write('flavor: $flavor, ')
          ..write('printingSet: $printingSet, ')
          ..write('printingCollectorNumber: $printingCollectorNumber, ')
          ..write('lang: $lang, ')
          ..write('hasLocalization: $hasLocalization')
          ..write(')'))
        .toString();
  }
}

class $CardDiscoveredSetsTable extends CardDiscoveredSets
    with TableInfo<$CardDiscoveredSetsTable, CardDiscoveredSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardDiscoveredSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setCodeMeta = const VerificationMeta(
    'setCode',
  );
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
    'set_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cardId, setCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_discovered_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardDiscoveredSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('set_code')) {
      context.handle(
        _setCodeMeta,
        setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_setCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardDiscoveredSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardDiscoveredSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      setCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_code'],
      )!,
    );
  }

  @override
  $CardDiscoveredSetsTable createAlias(String alias) {
    return $CardDiscoveredSetsTable(attachedDatabase, alias);
  }
}

class CardDiscoveredSet extends DataClass
    implements Insertable<CardDiscoveredSet> {
  final int id;
  final int cardId;
  final String setCode;
  const CardDiscoveredSet({
    required this.id,
    required this.cardId,
    required this.setCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['set_code'] = Variable<String>(setCode);
    return map;
  }

  CardDiscoveredSetsCompanion toCompanion(bool nullToAbsent) {
    return CardDiscoveredSetsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      setCode: Value(setCode),
    );
  }

  factory CardDiscoveredSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardDiscoveredSet(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      setCode: serializer.fromJson<String>(json['setCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'setCode': serializer.toJson<String>(setCode),
    };
  }

  CardDiscoveredSet copyWith({int? id, int? cardId, String? setCode}) =>
      CardDiscoveredSet(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        setCode: setCode ?? this.setCode,
      );
  CardDiscoveredSet copyWithCompanion(CardDiscoveredSetsCompanion data) {
    return CardDiscoveredSet(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      setCode: data.setCode.present ? data.setCode.value : this.setCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardDiscoveredSet(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('setCode: $setCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cardId, setCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardDiscoveredSet &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.setCode == this.setCode);
}

class CardDiscoveredSetsCompanion extends UpdateCompanion<CardDiscoveredSet> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> setCode;
  const CardDiscoveredSetsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.setCode = const Value.absent(),
  });
  CardDiscoveredSetsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String setCode,
  }) : cardId = Value(cardId),
       setCode = Value(setCode);
  static Insertable<CardDiscoveredSet> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? setCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (setCode != null) 'set_code': setCode,
    });
  }

  CardDiscoveredSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<String>? setCode,
  }) {
    return CardDiscoveredSetsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      setCode: setCode ?? this.setCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardDiscoveredSetsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('setCode: $setCode')
          ..write(')'))
        .toString();
  }
}

class $CardDiscoveredPrintingsTable extends CardDiscoveredPrintings
    with TableInfo<$CardDiscoveredPrintingsTable, CardDiscoveredPrinting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardDiscoveredPrintingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setCodeMeta = const VerificationMeta(
    'setCode',
  );
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
    'set_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _releasedAtMeta = const VerificationMeta(
    'releasedAt',
  );
  @override
  late final GeneratedColumn<String> releasedAt = GeneratedColumn<String>(
    'released_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistsMeta = const VerificationMeta(
    'artists',
  );
  @override
  late final GeneratedColumn<String> artists = GeneratedColumn<String>(
    'artists',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _printDataIdMeta = const VerificationMeta(
    'printDataId',
  );
  @override
  late final GeneratedColumn<int> printDataId = GeneratedColumn<int>(
    'print_data_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorNumberMeta = const VerificationMeta(
    'collectorNumber',
  );
  @override
  late final GeneratedColumn<String> collectorNumber = GeneratedColumn<String>(
    'collector_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    setCode,
    lang,
    setName,
    releasedAt,
    artists,
    printDataId,
    collectorNumber,
    rarity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_discovered_printings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardDiscoveredPrinting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('set_code')) {
      context.handle(
        _setCodeMeta,
        setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_setCodeMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    } else if (isInserting) {
      context.missing(_setNameMeta);
    }
    if (data.containsKey('released_at')) {
      context.handle(
        _releasedAtMeta,
        releasedAt.isAcceptableOrUnknown(data['released_at']!, _releasedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_releasedAtMeta);
    }
    if (data.containsKey('artists')) {
      context.handle(
        _artistsMeta,
        artists.isAcceptableOrUnknown(data['artists']!, _artistsMeta),
      );
    }
    if (data.containsKey('print_data_id')) {
      context.handle(
        _printDataIdMeta,
        printDataId.isAcceptableOrUnknown(
          data['print_data_id']!,
          _printDataIdMeta,
        ),
      );
    }
    if (data.containsKey('collector_number')) {
      context.handle(
        _collectorNumberMeta,
        collectorNumber.isAcceptableOrUnknown(
          data['collector_number']!,
          _collectorNumberMeta,
        ),
      );
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardDiscoveredPrinting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardDiscoveredPrinting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      setCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_code'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      )!,
      releasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}released_at'],
      )!,
      artists: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artists'],
      ),
      printDataId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}print_data_id'],
      ),
      collectorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_number'],
      ),
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      ),
    );
  }

  @override
  $CardDiscoveredPrintingsTable createAlias(String alias) {
    return $CardDiscoveredPrintingsTable(attachedDatabase, alias);
  }
}

class CardDiscoveredPrinting extends DataClass
    implements Insertable<CardDiscoveredPrinting> {
  final int id;
  final int cardId;
  final String setCode;
  final String lang;
  final String setName;
  final String releasedAt;
  final String? artists;
  final int? printDataId;
  final String? collectorNumber;
  final String? rarity;
  const CardDiscoveredPrinting({
    required this.id,
    required this.cardId,
    required this.setCode,
    required this.lang,
    required this.setName,
    required this.releasedAt,
    this.artists,
    this.printDataId,
    this.collectorNumber,
    this.rarity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['set_code'] = Variable<String>(setCode);
    map['lang'] = Variable<String>(lang);
    map['set_name'] = Variable<String>(setName);
    map['released_at'] = Variable<String>(releasedAt);
    if (!nullToAbsent || artists != null) {
      map['artists'] = Variable<String>(artists);
    }
    if (!nullToAbsent || printDataId != null) {
      map['print_data_id'] = Variable<int>(printDataId);
    }
    if (!nullToAbsent || collectorNumber != null) {
      map['collector_number'] = Variable<String>(collectorNumber);
    }
    if (!nullToAbsent || rarity != null) {
      map['rarity'] = Variable<String>(rarity);
    }
    return map;
  }

  CardDiscoveredPrintingsCompanion toCompanion(bool nullToAbsent) {
    return CardDiscoveredPrintingsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      setCode: Value(setCode),
      lang: Value(lang),
      setName: Value(setName),
      releasedAt: Value(releasedAt),
      artists: artists == null && nullToAbsent
          ? const Value.absent()
          : Value(artists),
      printDataId: printDataId == null && nullToAbsent
          ? const Value.absent()
          : Value(printDataId),
      collectorNumber: collectorNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorNumber),
      rarity: rarity == null && nullToAbsent
          ? const Value.absent()
          : Value(rarity),
    );
  }

  factory CardDiscoveredPrinting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardDiscoveredPrinting(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      setCode: serializer.fromJson<String>(json['setCode']),
      lang: serializer.fromJson<String>(json['lang']),
      setName: serializer.fromJson<String>(json['setName']),
      releasedAt: serializer.fromJson<String>(json['releasedAt']),
      artists: serializer.fromJson<String?>(json['artists']),
      printDataId: serializer.fromJson<int?>(json['printDataId']),
      collectorNumber: serializer.fromJson<String?>(json['collectorNumber']),
      rarity: serializer.fromJson<String?>(json['rarity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'setCode': serializer.toJson<String>(setCode),
      'lang': serializer.toJson<String>(lang),
      'setName': serializer.toJson<String>(setName),
      'releasedAt': serializer.toJson<String>(releasedAt),
      'artists': serializer.toJson<String?>(artists),
      'printDataId': serializer.toJson<int?>(printDataId),
      'collectorNumber': serializer.toJson<String?>(collectorNumber),
      'rarity': serializer.toJson<String?>(rarity),
    };
  }

  CardDiscoveredPrinting copyWith({
    int? id,
    int? cardId,
    String? setCode,
    String? lang,
    String? setName,
    String? releasedAt,
    Value<String?> artists = const Value.absent(),
    Value<int?> printDataId = const Value.absent(),
    Value<String?> collectorNumber = const Value.absent(),
    Value<String?> rarity = const Value.absent(),
  }) => CardDiscoveredPrinting(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    setCode: setCode ?? this.setCode,
    lang: lang ?? this.lang,
    setName: setName ?? this.setName,
    releasedAt: releasedAt ?? this.releasedAt,
    artists: artists.present ? artists.value : this.artists,
    printDataId: printDataId.present ? printDataId.value : this.printDataId,
    collectorNumber: collectorNumber.present
        ? collectorNumber.value
        : this.collectorNumber,
    rarity: rarity.present ? rarity.value : this.rarity,
  );
  CardDiscoveredPrinting copyWithCompanion(
    CardDiscoveredPrintingsCompanion data,
  ) {
    return CardDiscoveredPrinting(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      setCode: data.setCode.present ? data.setCode.value : this.setCode,
      lang: data.lang.present ? data.lang.value : this.lang,
      setName: data.setName.present ? data.setName.value : this.setName,
      releasedAt: data.releasedAt.present
          ? data.releasedAt.value
          : this.releasedAt,
      artists: data.artists.present ? data.artists.value : this.artists,
      printDataId: data.printDataId.present
          ? data.printDataId.value
          : this.printDataId,
      collectorNumber: data.collectorNumber.present
          ? data.collectorNumber.value
          : this.collectorNumber,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardDiscoveredPrinting(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('setCode: $setCode, ')
          ..write('lang: $lang, ')
          ..write('setName: $setName, ')
          ..write('releasedAt: $releasedAt, ')
          ..write('artists: $artists, ')
          ..write('printDataId: $printDataId, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('rarity: $rarity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    setCode,
    lang,
    setName,
    releasedAt,
    artists,
    printDataId,
    collectorNumber,
    rarity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardDiscoveredPrinting &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.setCode == this.setCode &&
          other.lang == this.lang &&
          other.setName == this.setName &&
          other.releasedAt == this.releasedAt &&
          other.artists == this.artists &&
          other.printDataId == this.printDataId &&
          other.collectorNumber == this.collectorNumber &&
          other.rarity == this.rarity);
}

class CardDiscoveredPrintingsCompanion
    extends UpdateCompanion<CardDiscoveredPrinting> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> setCode;
  final Value<String> lang;
  final Value<String> setName;
  final Value<String> releasedAt;
  final Value<String?> artists;
  final Value<int?> printDataId;
  final Value<String?> collectorNumber;
  final Value<String?> rarity;
  const CardDiscoveredPrintingsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.setCode = const Value.absent(),
    this.lang = const Value.absent(),
    this.setName = const Value.absent(),
    this.releasedAt = const Value.absent(),
    this.artists = const Value.absent(),
    this.printDataId = const Value.absent(),
    this.collectorNumber = const Value.absent(),
    this.rarity = const Value.absent(),
  });
  CardDiscoveredPrintingsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String setCode,
    required String lang,
    required String setName,
    required String releasedAt,
    this.artists = const Value.absent(),
    this.printDataId = const Value.absent(),
    this.collectorNumber = const Value.absent(),
    this.rarity = const Value.absent(),
  }) : cardId = Value(cardId),
       setCode = Value(setCode),
       lang = Value(lang),
       setName = Value(setName),
       releasedAt = Value(releasedAt);
  static Insertable<CardDiscoveredPrinting> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? setCode,
    Expression<String>? lang,
    Expression<String>? setName,
    Expression<String>? releasedAt,
    Expression<String>? artists,
    Expression<int>? printDataId,
    Expression<String>? collectorNumber,
    Expression<String>? rarity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (setCode != null) 'set_code': setCode,
      if (lang != null) 'lang': lang,
      if (setName != null) 'set_name': setName,
      if (releasedAt != null) 'released_at': releasedAt,
      if (artists != null) 'artists': artists,
      if (printDataId != null) 'print_data_id': printDataId,
      if (collectorNumber != null) 'collector_number': collectorNumber,
      if (rarity != null) 'rarity': rarity,
    });
  }

  CardDiscoveredPrintingsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<String>? setCode,
    Value<String>? lang,
    Value<String>? setName,
    Value<String>? releasedAt,
    Value<String?>? artists,
    Value<int?>? printDataId,
    Value<String?>? collectorNumber,
    Value<String?>? rarity,
  }) {
    return CardDiscoveredPrintingsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      setCode: setCode ?? this.setCode,
      lang: lang ?? this.lang,
      setName: setName ?? this.setName,
      releasedAt: releasedAt ?? this.releasedAt,
      artists: artists ?? this.artists,
      printDataId: printDataId ?? this.printDataId,
      collectorNumber: collectorNumber ?? this.collectorNumber,
      rarity: rarity ?? this.rarity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (releasedAt.present) {
      map['released_at'] = Variable<String>(releasedAt.value);
    }
    if (artists.present) {
      map['artists'] = Variable<String>(artists.value);
    }
    if (printDataId.present) {
      map['print_data_id'] = Variable<int>(printDataId.value);
    }
    if (collectorNumber.present) {
      map['collector_number'] = Variable<String>(collectorNumber.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardDiscoveredPrintingsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('setCode: $setCode, ')
          ..write('lang: $lang, ')
          ..write('setName: $setName, ')
          ..write('releasedAt: $releasedAt, ')
          ..write('artists: $artists, ')
          ..write('printDataId: $printDataId, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('rarity: $rarity')
          ..write(')'))
        .toString();
  }
}

class $CardPrintDataTable extends CardPrintData
    with TableInfo<$CardPrintDataTable, PrintData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardPrintDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flavorNameMeta = const VerificationMeta(
    'flavorName',
  );
  @override
  late final GeneratedColumn<String> flavorName = GeneratedColumn<String>(
    'flavor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manaCostMeta = const VerificationMeta(
    'manaCost',
  );
  @override
  late final GeneratedColumn<String> manaCost = GeneratedColumn<String>(
    'mana_cost',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeLineMeta = const VerificationMeta(
    'typeLine',
  );
  @override
  late final GeneratedColumn<String> typeLine = GeneratedColumn<String>(
    'type_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oracleTextMeta = const VerificationMeta(
    'oracleText',
  );
  @override
  late final GeneratedColumn<String> oracleText = GeneratedColumn<String>(
    'oracle_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flavorTextMeta = const VerificationMeta(
    'flavorText',
  );
  @override
  late final GeneratedColumn<String> flavorText = GeneratedColumn<String>(
    'flavor_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<String> power = GeneratedColumn<String>(
    'power',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toughnessMeta = const VerificationMeta(
    'toughness',
  );
  @override
  late final GeneratedColumn<String> toughness = GeneratedColumn<String>(
    'toughness',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loyaltyMeta = const VerificationMeta(
    'loyalty',
  );
  @override
  late final GeneratedColumn<String> loyalty = GeneratedColumn<String>(
    'loyalty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorsMeta = const VerificationMeta('colors');
  @override
  late final GeneratedColumn<String> colors = GeneratedColumn<String>(
    'colors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorIdentityMeta = const VerificationMeta(
    'colorIdentity',
  );
  @override
  late final GeneratedColumn<String> colorIdentity = GeneratedColumn<String>(
    'color_identity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _layoutMeta = const VerificationMeta('layout');
  @override
  late final GeneratedColumn<String> layout = GeneratedColumn<String>(
    'layout',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    contentHash,
    lang,
    name,
    flavorName,
    manaCost,
    typeLine,
    oracleText,
    flavorText,
    power,
    toughness,
    loyalty,
    colors,
    colorIdentity,
    keywords,
    layout,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_print_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrintData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    } else if (isInserting) {
      context.missing(_langMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('flavor_name')) {
      context.handle(
        _flavorNameMeta,
        flavorName.isAcceptableOrUnknown(data['flavor_name']!, _flavorNameMeta),
      );
    }
    if (data.containsKey('mana_cost')) {
      context.handle(
        _manaCostMeta,
        manaCost.isAcceptableOrUnknown(data['mana_cost']!, _manaCostMeta),
      );
    }
    if (data.containsKey('type_line')) {
      context.handle(
        _typeLineMeta,
        typeLine.isAcceptableOrUnknown(data['type_line']!, _typeLineMeta),
      );
    }
    if (data.containsKey('oracle_text')) {
      context.handle(
        _oracleTextMeta,
        oracleText.isAcceptableOrUnknown(data['oracle_text']!, _oracleTextMeta),
      );
    }
    if (data.containsKey('flavor_text')) {
      context.handle(
        _flavorTextMeta,
        flavorText.isAcceptableOrUnknown(data['flavor_text']!, _flavorTextMeta),
      );
    }
    if (data.containsKey('power')) {
      context.handle(
        _powerMeta,
        power.isAcceptableOrUnknown(data['power']!, _powerMeta),
      );
    }
    if (data.containsKey('toughness')) {
      context.handle(
        _toughnessMeta,
        toughness.isAcceptableOrUnknown(data['toughness']!, _toughnessMeta),
      );
    }
    if (data.containsKey('loyalty')) {
      context.handle(
        _loyaltyMeta,
        loyalty.isAcceptableOrUnknown(data['loyalty']!, _loyaltyMeta),
      );
    }
    if (data.containsKey('colors')) {
      context.handle(
        _colorsMeta,
        colors.isAcceptableOrUnknown(data['colors']!, _colorsMeta),
      );
    }
    if (data.containsKey('color_identity')) {
      context.handle(
        _colorIdentityMeta,
        colorIdentity.isAcceptableOrUnknown(
          data['color_identity']!,
          _colorIdentityMeta,
        ),
      );
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    }
    if (data.containsKey('layout')) {
      context.handle(
        _layoutMeta,
        layout.isAcceptableOrUnknown(data['layout']!, _layoutMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrintData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrintData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      flavorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_name'],
      ),
      manaCost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mana_cost'],
      ),
      typeLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_line'],
      ),
      oracleText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oracle_text'],
      ),
      flavorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_text'],
      ),
      power: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}power'],
      ),
      toughness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toughness'],
      ),
      loyalty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loyalty'],
      ),
      colors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colors'],
      ),
      colorIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_identity'],
      ),
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      ),
      layout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout'],
      ),
    );
  }

  @override
  $CardPrintDataTable createAlias(String alias) {
    return $CardPrintDataTable(attachedDatabase, alias);
  }
}

class PrintData extends DataClass implements Insertable<PrintData> {
  final int id;
  final int cardId;
  final String contentHash;
  final String lang;
  final String name;
  final String? flavorName;
  final String? manaCost;
  final String? typeLine;
  final String? oracleText;
  final String? flavorText;
  final String? power;
  final String? toughness;
  final String? loyalty;
  final String? colors;
  final String? colorIdentity;
  final String? keywords;
  final String? layout;
  const PrintData({
    required this.id,
    required this.cardId,
    required this.contentHash,
    required this.lang,
    required this.name,
    this.flavorName,
    this.manaCost,
    this.typeLine,
    this.oracleText,
    this.flavorText,
    this.power,
    this.toughness,
    this.loyalty,
    this.colors,
    this.colorIdentity,
    this.keywords,
    this.layout,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['content_hash'] = Variable<String>(contentHash);
    map['lang'] = Variable<String>(lang);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || flavorName != null) {
      map['flavor_name'] = Variable<String>(flavorName);
    }
    if (!nullToAbsent || manaCost != null) {
      map['mana_cost'] = Variable<String>(manaCost);
    }
    if (!nullToAbsent || typeLine != null) {
      map['type_line'] = Variable<String>(typeLine);
    }
    if (!nullToAbsent || oracleText != null) {
      map['oracle_text'] = Variable<String>(oracleText);
    }
    if (!nullToAbsent || flavorText != null) {
      map['flavor_text'] = Variable<String>(flavorText);
    }
    if (!nullToAbsent || power != null) {
      map['power'] = Variable<String>(power);
    }
    if (!nullToAbsent || toughness != null) {
      map['toughness'] = Variable<String>(toughness);
    }
    if (!nullToAbsent || loyalty != null) {
      map['loyalty'] = Variable<String>(loyalty);
    }
    if (!nullToAbsent || colors != null) {
      map['colors'] = Variable<String>(colors);
    }
    if (!nullToAbsent || colorIdentity != null) {
      map['color_identity'] = Variable<String>(colorIdentity);
    }
    if (!nullToAbsent || keywords != null) {
      map['keywords'] = Variable<String>(keywords);
    }
    if (!nullToAbsent || layout != null) {
      map['layout'] = Variable<String>(layout);
    }
    return map;
  }

  CardPrintDataCompanion toCompanion(bool nullToAbsent) {
    return CardPrintDataCompanion(
      id: Value(id),
      cardId: Value(cardId),
      contentHash: Value(contentHash),
      lang: Value(lang),
      name: Value(name),
      flavorName: flavorName == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorName),
      manaCost: manaCost == null && nullToAbsent
          ? const Value.absent()
          : Value(manaCost),
      typeLine: typeLine == null && nullToAbsent
          ? const Value.absent()
          : Value(typeLine),
      oracleText: oracleText == null && nullToAbsent
          ? const Value.absent()
          : Value(oracleText),
      flavorText: flavorText == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorText),
      power: power == null && nullToAbsent
          ? const Value.absent()
          : Value(power),
      toughness: toughness == null && nullToAbsent
          ? const Value.absent()
          : Value(toughness),
      loyalty: loyalty == null && nullToAbsent
          ? const Value.absent()
          : Value(loyalty),
      colors: colors == null && nullToAbsent
          ? const Value.absent()
          : Value(colors),
      colorIdentity: colorIdentity == null && nullToAbsent
          ? const Value.absent()
          : Value(colorIdentity),
      keywords: keywords == null && nullToAbsent
          ? const Value.absent()
          : Value(keywords),
      layout: layout == null && nullToAbsent
          ? const Value.absent()
          : Value(layout),
    );
  }

  factory PrintData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrintData(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      lang: serializer.fromJson<String>(json['lang']),
      name: serializer.fromJson<String>(json['name']),
      flavorName: serializer.fromJson<String?>(json['flavorName']),
      manaCost: serializer.fromJson<String?>(json['manaCost']),
      typeLine: serializer.fromJson<String?>(json['typeLine']),
      oracleText: serializer.fromJson<String?>(json['oracleText']),
      flavorText: serializer.fromJson<String?>(json['flavorText']),
      power: serializer.fromJson<String?>(json['power']),
      toughness: serializer.fromJson<String?>(json['toughness']),
      loyalty: serializer.fromJson<String?>(json['loyalty']),
      colors: serializer.fromJson<String?>(json['colors']),
      colorIdentity: serializer.fromJson<String?>(json['colorIdentity']),
      keywords: serializer.fromJson<String?>(json['keywords']),
      layout: serializer.fromJson<String?>(json['layout']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'contentHash': serializer.toJson<String>(contentHash),
      'lang': serializer.toJson<String>(lang),
      'name': serializer.toJson<String>(name),
      'flavorName': serializer.toJson<String?>(flavorName),
      'manaCost': serializer.toJson<String?>(manaCost),
      'typeLine': serializer.toJson<String?>(typeLine),
      'oracleText': serializer.toJson<String?>(oracleText),
      'flavorText': serializer.toJson<String?>(flavorText),
      'power': serializer.toJson<String?>(power),
      'toughness': serializer.toJson<String?>(toughness),
      'loyalty': serializer.toJson<String?>(loyalty),
      'colors': serializer.toJson<String?>(colors),
      'colorIdentity': serializer.toJson<String?>(colorIdentity),
      'keywords': serializer.toJson<String?>(keywords),
      'layout': serializer.toJson<String?>(layout),
    };
  }

  PrintData copyWith({
    int? id,
    int? cardId,
    String? contentHash,
    String? lang,
    String? name,
    Value<String?> flavorName = const Value.absent(),
    Value<String?> manaCost = const Value.absent(),
    Value<String?> typeLine = const Value.absent(),
    Value<String?> oracleText = const Value.absent(),
    Value<String?> flavorText = const Value.absent(),
    Value<String?> power = const Value.absent(),
    Value<String?> toughness = const Value.absent(),
    Value<String?> loyalty = const Value.absent(),
    Value<String?> colors = const Value.absent(),
    Value<String?> colorIdentity = const Value.absent(),
    Value<String?> keywords = const Value.absent(),
    Value<String?> layout = const Value.absent(),
  }) => PrintData(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    contentHash: contentHash ?? this.contentHash,
    lang: lang ?? this.lang,
    name: name ?? this.name,
    flavorName: flavorName.present ? flavorName.value : this.flavorName,
    manaCost: manaCost.present ? manaCost.value : this.manaCost,
    typeLine: typeLine.present ? typeLine.value : this.typeLine,
    oracleText: oracleText.present ? oracleText.value : this.oracleText,
    flavorText: flavorText.present ? flavorText.value : this.flavorText,
    power: power.present ? power.value : this.power,
    toughness: toughness.present ? toughness.value : this.toughness,
    loyalty: loyalty.present ? loyalty.value : this.loyalty,
    colors: colors.present ? colors.value : this.colors,
    colorIdentity: colorIdentity.present
        ? colorIdentity.value
        : this.colorIdentity,
    keywords: keywords.present ? keywords.value : this.keywords,
    layout: layout.present ? layout.value : this.layout,
  );
  PrintData copyWithCompanion(CardPrintDataCompanion data) {
    return PrintData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      lang: data.lang.present ? data.lang.value : this.lang,
      name: data.name.present ? data.name.value : this.name,
      flavorName: data.flavorName.present
          ? data.flavorName.value
          : this.flavorName,
      manaCost: data.manaCost.present ? data.manaCost.value : this.manaCost,
      typeLine: data.typeLine.present ? data.typeLine.value : this.typeLine,
      oracleText: data.oracleText.present
          ? data.oracleText.value
          : this.oracleText,
      flavorText: data.flavorText.present
          ? data.flavorText.value
          : this.flavorText,
      power: data.power.present ? data.power.value : this.power,
      toughness: data.toughness.present ? data.toughness.value : this.toughness,
      loyalty: data.loyalty.present ? data.loyalty.value : this.loyalty,
      colors: data.colors.present ? data.colors.value : this.colors,
      colorIdentity: data.colorIdentity.present
          ? data.colorIdentity.value
          : this.colorIdentity,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      layout: data.layout.present ? data.layout.value : this.layout,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrintData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('contentHash: $contentHash, ')
          ..write('lang: $lang, ')
          ..write('name: $name, ')
          ..write('flavorName: $flavorName, ')
          ..write('manaCost: $manaCost, ')
          ..write('typeLine: $typeLine, ')
          ..write('oracleText: $oracleText, ')
          ..write('flavorText: $flavorText, ')
          ..write('power: $power, ')
          ..write('toughness: $toughness, ')
          ..write('loyalty: $loyalty, ')
          ..write('colors: $colors, ')
          ..write('colorIdentity: $colorIdentity, ')
          ..write('keywords: $keywords, ')
          ..write('layout: $layout')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    contentHash,
    lang,
    name,
    flavorName,
    manaCost,
    typeLine,
    oracleText,
    flavorText,
    power,
    toughness,
    loyalty,
    colors,
    colorIdentity,
    keywords,
    layout,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrintData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.contentHash == this.contentHash &&
          other.lang == this.lang &&
          other.name == this.name &&
          other.flavorName == this.flavorName &&
          other.manaCost == this.manaCost &&
          other.typeLine == this.typeLine &&
          other.oracleText == this.oracleText &&
          other.flavorText == this.flavorText &&
          other.power == this.power &&
          other.toughness == this.toughness &&
          other.loyalty == this.loyalty &&
          other.colors == this.colors &&
          other.colorIdentity == this.colorIdentity &&
          other.keywords == this.keywords &&
          other.layout == this.layout);
}

class CardPrintDataCompanion extends UpdateCompanion<PrintData> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<String> contentHash;
  final Value<String> lang;
  final Value<String> name;
  final Value<String?> flavorName;
  final Value<String?> manaCost;
  final Value<String?> typeLine;
  final Value<String?> oracleText;
  final Value<String?> flavorText;
  final Value<String?> power;
  final Value<String?> toughness;
  final Value<String?> loyalty;
  final Value<String?> colors;
  final Value<String?> colorIdentity;
  final Value<String?> keywords;
  final Value<String?> layout;
  const CardPrintDataCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.lang = const Value.absent(),
    this.name = const Value.absent(),
    this.flavorName = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.typeLine = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.power = const Value.absent(),
    this.toughness = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.colors = const Value.absent(),
    this.colorIdentity = const Value.absent(),
    this.keywords = const Value.absent(),
    this.layout = const Value.absent(),
  });
  CardPrintDataCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required String contentHash,
    required String lang,
    required String name,
    this.flavorName = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.typeLine = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.power = const Value.absent(),
    this.toughness = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.colors = const Value.absent(),
    this.colorIdentity = const Value.absent(),
    this.keywords = const Value.absent(),
    this.layout = const Value.absent(),
  }) : cardId = Value(cardId),
       contentHash = Value(contentHash),
       lang = Value(lang),
       name = Value(name);
  static Insertable<PrintData> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<String>? contentHash,
    Expression<String>? lang,
    Expression<String>? name,
    Expression<String>? flavorName,
    Expression<String>? manaCost,
    Expression<String>? typeLine,
    Expression<String>? oracleText,
    Expression<String>? flavorText,
    Expression<String>? power,
    Expression<String>? toughness,
    Expression<String>? loyalty,
    Expression<String>? colors,
    Expression<String>? colorIdentity,
    Expression<String>? keywords,
    Expression<String>? layout,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (contentHash != null) 'content_hash': contentHash,
      if (lang != null) 'lang': lang,
      if (name != null) 'name': name,
      if (flavorName != null) 'flavor_name': flavorName,
      if (manaCost != null) 'mana_cost': manaCost,
      if (typeLine != null) 'type_line': typeLine,
      if (oracleText != null) 'oracle_text': oracleText,
      if (flavorText != null) 'flavor_text': flavorText,
      if (power != null) 'power': power,
      if (toughness != null) 'toughness': toughness,
      if (loyalty != null) 'loyalty': loyalty,
      if (colors != null) 'colors': colors,
      if (colorIdentity != null) 'color_identity': colorIdentity,
      if (keywords != null) 'keywords': keywords,
      if (layout != null) 'layout': layout,
    });
  }

  CardPrintDataCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<String>? contentHash,
    Value<String>? lang,
    Value<String>? name,
    Value<String?>? flavorName,
    Value<String?>? manaCost,
    Value<String?>? typeLine,
    Value<String?>? oracleText,
    Value<String?>? flavorText,
    Value<String?>? power,
    Value<String?>? toughness,
    Value<String?>? loyalty,
    Value<String?>? colors,
    Value<String?>? colorIdentity,
    Value<String?>? keywords,
    Value<String?>? layout,
  }) {
    return CardPrintDataCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      contentHash: contentHash ?? this.contentHash,
      lang: lang ?? this.lang,
      name: name ?? this.name,
      flavorName: flavorName ?? this.flavorName,
      manaCost: manaCost ?? this.manaCost,
      typeLine: typeLine ?? this.typeLine,
      oracleText: oracleText ?? this.oracleText,
      flavorText: flavorText ?? this.flavorText,
      power: power ?? this.power,
      toughness: toughness ?? this.toughness,
      loyalty: loyalty ?? this.loyalty,
      colors: colors ?? this.colors,
      colorIdentity: colorIdentity ?? this.colorIdentity,
      keywords: keywords ?? this.keywords,
      layout: layout ?? this.layout,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (flavorName.present) {
      map['flavor_name'] = Variable<String>(flavorName.value);
    }
    if (manaCost.present) {
      map['mana_cost'] = Variable<String>(manaCost.value);
    }
    if (typeLine.present) {
      map['type_line'] = Variable<String>(typeLine.value);
    }
    if (oracleText.present) {
      map['oracle_text'] = Variable<String>(oracleText.value);
    }
    if (flavorText.present) {
      map['flavor_text'] = Variable<String>(flavorText.value);
    }
    if (power.present) {
      map['power'] = Variable<String>(power.value);
    }
    if (toughness.present) {
      map['toughness'] = Variable<String>(toughness.value);
    }
    if (loyalty.present) {
      map['loyalty'] = Variable<String>(loyalty.value);
    }
    if (colors.present) {
      map['colors'] = Variable<String>(colors.value);
    }
    if (colorIdentity.present) {
      map['color_identity'] = Variable<String>(colorIdentity.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (layout.present) {
      map['layout'] = Variable<String>(layout.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardPrintDataCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('contentHash: $contentHash, ')
          ..write('lang: $lang, ')
          ..write('name: $name, ')
          ..write('flavorName: $flavorName, ')
          ..write('manaCost: $manaCost, ')
          ..write('typeLine: $typeLine, ')
          ..write('oracleText: $oracleText, ')
          ..write('flavorText: $flavorText, ')
          ..write('power: $power, ')
          ..write('toughness: $toughness, ')
          ..write('loyalty: $loyalty, ')
          ..write('colors: $colors, ')
          ..write('colorIdentity: $colorIdentity, ')
          ..write('keywords: $keywords, ')
          ..write('layout: $layout')
          ..write(')'))
        .toString();
  }
}

class $CardUsedPrintDataTable extends CardUsedPrintData
    with TableInfo<$CardUsedPrintDataTable, UsedPrintData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardUsedPrintDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flavorNameMeta = const VerificationMeta(
    'flavorName',
  );
  @override
  late final GeneratedColumn<String> flavorName = GeneratedColumn<String>(
    'flavor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manaCostMeta = const VerificationMeta(
    'manaCost',
  );
  @override
  late final GeneratedColumn<String> manaCost = GeneratedColumn<String>(
    'mana_cost',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeLineMeta = const VerificationMeta(
    'typeLine',
  );
  @override
  late final GeneratedColumn<String> typeLine = GeneratedColumn<String>(
    'type_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oracleTextMeta = const VerificationMeta(
    'oracleText',
  );
  @override
  late final GeneratedColumn<String> oracleText = GeneratedColumn<String>(
    'oracle_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flavorTextMeta = const VerificationMeta(
    'flavorText',
  );
  @override
  late final GeneratedColumn<String> flavorText = GeneratedColumn<String>(
    'flavor_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<String> power = GeneratedColumn<String>(
    'power',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toughnessMeta = const VerificationMeta(
    'toughness',
  );
  @override
  late final GeneratedColumn<String> toughness = GeneratedColumn<String>(
    'toughness',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loyaltyMeta = const VerificationMeta(
    'loyalty',
  );
  @override
  late final GeneratedColumn<String> loyalty = GeneratedColumn<String>(
    'loyalty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorsMeta = const VerificationMeta('colors');
  @override
  late final GeneratedColumn<String> colors = GeneratedColumn<String>(
    'colors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorIdentityMeta = const VerificationMeta(
    'colorIdentity',
  );
  @override
  late final GeneratedColumn<String> colorIdentity = GeneratedColumn<String>(
    'color_identity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _layoutMeta = const VerificationMeta('layout');
  @override
  late final GeneratedColumn<String> layout = GeneratedColumn<String>(
    'layout',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setCodeMeta = const VerificationMeta(
    'setCode',
  );
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
    'set_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectorNumberMeta = const VerificationMeta(
    'collectorNumber',
  );
  @override
  late final GeneratedColumn<String> collectorNumber = GeneratedColumn<String>(
    'collector_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    lang,
    name,
    flavorName,
    manaCost,
    typeLine,
    oracleText,
    flavorText,
    power,
    toughness,
    loyalty,
    colors,
    colorIdentity,
    keywords,
    layout,
    setCode,
    setName,
    collectorNumber,
    rarity,
    artist,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_used_print_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsedPrintData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('flavor_name')) {
      context.handle(
        _flavorNameMeta,
        flavorName.isAcceptableOrUnknown(data['flavor_name']!, _flavorNameMeta),
      );
    }
    if (data.containsKey('mana_cost')) {
      context.handle(
        _manaCostMeta,
        manaCost.isAcceptableOrUnknown(data['mana_cost']!, _manaCostMeta),
      );
    }
    if (data.containsKey('type_line')) {
      context.handle(
        _typeLineMeta,
        typeLine.isAcceptableOrUnknown(data['type_line']!, _typeLineMeta),
      );
    }
    if (data.containsKey('oracle_text')) {
      context.handle(
        _oracleTextMeta,
        oracleText.isAcceptableOrUnknown(data['oracle_text']!, _oracleTextMeta),
      );
    }
    if (data.containsKey('flavor_text')) {
      context.handle(
        _flavorTextMeta,
        flavorText.isAcceptableOrUnknown(data['flavor_text']!, _flavorTextMeta),
      );
    }
    if (data.containsKey('power')) {
      context.handle(
        _powerMeta,
        power.isAcceptableOrUnknown(data['power']!, _powerMeta),
      );
    }
    if (data.containsKey('toughness')) {
      context.handle(
        _toughnessMeta,
        toughness.isAcceptableOrUnknown(data['toughness']!, _toughnessMeta),
      );
    }
    if (data.containsKey('loyalty')) {
      context.handle(
        _loyaltyMeta,
        loyalty.isAcceptableOrUnknown(data['loyalty']!, _loyaltyMeta),
      );
    }
    if (data.containsKey('colors')) {
      context.handle(
        _colorsMeta,
        colors.isAcceptableOrUnknown(data['colors']!, _colorsMeta),
      );
    }
    if (data.containsKey('color_identity')) {
      context.handle(
        _colorIdentityMeta,
        colorIdentity.isAcceptableOrUnknown(
          data['color_identity']!,
          _colorIdentityMeta,
        ),
      );
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    }
    if (data.containsKey('layout')) {
      context.handle(
        _layoutMeta,
        layout.isAcceptableOrUnknown(data['layout']!, _layoutMeta),
      );
    }
    if (data.containsKey('set_code')) {
      context.handle(
        _setCodeMeta,
        setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta),
      );
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    }
    if (data.containsKey('collector_number')) {
      context.handle(
        _collectorNumberMeta,
        collectorNumber.isAcceptableOrUnknown(
          data['collector_number']!,
          _collectorNumberMeta,
        ),
      );
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  UsedPrintData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsedPrintData(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_id'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      flavorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_name'],
      ),
      manaCost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mana_cost'],
      ),
      typeLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_line'],
      ),
      oracleText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oracle_text'],
      ),
      flavorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_text'],
      ),
      power: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}power'],
      ),
      toughness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}toughness'],
      ),
      loyalty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loyalty'],
      ),
      colors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colors'],
      ),
      colorIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_identity'],
      ),
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      ),
      layout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}layout'],
      ),
      setCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_code'],
      ),
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      ),
      collectorNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collector_number'],
      ),
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
    );
  }

  @override
  $CardUsedPrintDataTable createAlias(String alias) {
    return $CardUsedPrintDataTable(attachedDatabase, alias);
  }
}

class UsedPrintData extends DataClass implements Insertable<UsedPrintData> {
  final int cardId;
  final String? lang;
  final String? name;
  final String? flavorName;
  final String? manaCost;
  final String? typeLine;
  final String? oracleText;
  final String? flavorText;
  final String? power;
  final String? toughness;
  final String? loyalty;
  final String? colors;
  final String? colorIdentity;
  final String? keywords;
  final String? layout;
  final String? setCode;
  final String? setName;
  final String? collectorNumber;
  final String? rarity;
  final String? artist;
  const UsedPrintData({
    required this.cardId,
    this.lang,
    this.name,
    this.flavorName,
    this.manaCost,
    this.typeLine,
    this.oracleText,
    this.flavorText,
    this.power,
    this.toughness,
    this.loyalty,
    this.colors,
    this.colorIdentity,
    this.keywords,
    this.layout,
    this.setCode,
    this.setName,
    this.collectorNumber,
    this.rarity,
    this.artist,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<int>(cardId);
    if (!nullToAbsent || lang != null) {
      map['lang'] = Variable<String>(lang);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || flavorName != null) {
      map['flavor_name'] = Variable<String>(flavorName);
    }
    if (!nullToAbsent || manaCost != null) {
      map['mana_cost'] = Variable<String>(manaCost);
    }
    if (!nullToAbsent || typeLine != null) {
      map['type_line'] = Variable<String>(typeLine);
    }
    if (!nullToAbsent || oracleText != null) {
      map['oracle_text'] = Variable<String>(oracleText);
    }
    if (!nullToAbsent || flavorText != null) {
      map['flavor_text'] = Variable<String>(flavorText);
    }
    if (!nullToAbsent || power != null) {
      map['power'] = Variable<String>(power);
    }
    if (!nullToAbsent || toughness != null) {
      map['toughness'] = Variable<String>(toughness);
    }
    if (!nullToAbsent || loyalty != null) {
      map['loyalty'] = Variable<String>(loyalty);
    }
    if (!nullToAbsent || colors != null) {
      map['colors'] = Variable<String>(colors);
    }
    if (!nullToAbsent || colorIdentity != null) {
      map['color_identity'] = Variable<String>(colorIdentity);
    }
    if (!nullToAbsent || keywords != null) {
      map['keywords'] = Variable<String>(keywords);
    }
    if (!nullToAbsent || layout != null) {
      map['layout'] = Variable<String>(layout);
    }
    if (!nullToAbsent || setCode != null) {
      map['set_code'] = Variable<String>(setCode);
    }
    if (!nullToAbsent || setName != null) {
      map['set_name'] = Variable<String>(setName);
    }
    if (!nullToAbsent || collectorNumber != null) {
      map['collector_number'] = Variable<String>(collectorNumber);
    }
    if (!nullToAbsent || rarity != null) {
      map['rarity'] = Variable<String>(rarity);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    return map;
  }

  CardUsedPrintDataCompanion toCompanion(bool nullToAbsent) {
    return CardUsedPrintDataCompanion(
      cardId: Value(cardId),
      lang: lang == null && nullToAbsent ? const Value.absent() : Value(lang),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      flavorName: flavorName == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorName),
      manaCost: manaCost == null && nullToAbsent
          ? const Value.absent()
          : Value(manaCost),
      typeLine: typeLine == null && nullToAbsent
          ? const Value.absent()
          : Value(typeLine),
      oracleText: oracleText == null && nullToAbsent
          ? const Value.absent()
          : Value(oracleText),
      flavorText: flavorText == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorText),
      power: power == null && nullToAbsent
          ? const Value.absent()
          : Value(power),
      toughness: toughness == null && nullToAbsent
          ? const Value.absent()
          : Value(toughness),
      loyalty: loyalty == null && nullToAbsent
          ? const Value.absent()
          : Value(loyalty),
      colors: colors == null && nullToAbsent
          ? const Value.absent()
          : Value(colors),
      colorIdentity: colorIdentity == null && nullToAbsent
          ? const Value.absent()
          : Value(colorIdentity),
      keywords: keywords == null && nullToAbsent
          ? const Value.absent()
          : Value(keywords),
      layout: layout == null && nullToAbsent
          ? const Value.absent()
          : Value(layout),
      setCode: setCode == null && nullToAbsent
          ? const Value.absent()
          : Value(setCode),
      setName: setName == null && nullToAbsent
          ? const Value.absent()
          : Value(setName),
      collectorNumber: collectorNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(collectorNumber),
      rarity: rarity == null && nullToAbsent
          ? const Value.absent()
          : Value(rarity),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
    );
  }

  factory UsedPrintData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsedPrintData(
      cardId: serializer.fromJson<int>(json['cardId']),
      lang: serializer.fromJson<String?>(json['lang']),
      name: serializer.fromJson<String?>(json['name']),
      flavorName: serializer.fromJson<String?>(json['flavorName']),
      manaCost: serializer.fromJson<String?>(json['manaCost']),
      typeLine: serializer.fromJson<String?>(json['typeLine']),
      oracleText: serializer.fromJson<String?>(json['oracleText']),
      flavorText: serializer.fromJson<String?>(json['flavorText']),
      power: serializer.fromJson<String?>(json['power']),
      toughness: serializer.fromJson<String?>(json['toughness']),
      loyalty: serializer.fromJson<String?>(json['loyalty']),
      colors: serializer.fromJson<String?>(json['colors']),
      colorIdentity: serializer.fromJson<String?>(json['colorIdentity']),
      keywords: serializer.fromJson<String?>(json['keywords']),
      layout: serializer.fromJson<String?>(json['layout']),
      setCode: serializer.fromJson<String?>(json['setCode']),
      setName: serializer.fromJson<String?>(json['setName']),
      collectorNumber: serializer.fromJson<String?>(json['collectorNumber']),
      rarity: serializer.fromJson<String?>(json['rarity']),
      artist: serializer.fromJson<String?>(json['artist']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<int>(cardId),
      'lang': serializer.toJson<String?>(lang),
      'name': serializer.toJson<String?>(name),
      'flavorName': serializer.toJson<String?>(flavorName),
      'manaCost': serializer.toJson<String?>(manaCost),
      'typeLine': serializer.toJson<String?>(typeLine),
      'oracleText': serializer.toJson<String?>(oracleText),
      'flavorText': serializer.toJson<String?>(flavorText),
      'power': serializer.toJson<String?>(power),
      'toughness': serializer.toJson<String?>(toughness),
      'loyalty': serializer.toJson<String?>(loyalty),
      'colors': serializer.toJson<String?>(colors),
      'colorIdentity': serializer.toJson<String?>(colorIdentity),
      'keywords': serializer.toJson<String?>(keywords),
      'layout': serializer.toJson<String?>(layout),
      'setCode': serializer.toJson<String?>(setCode),
      'setName': serializer.toJson<String?>(setName),
      'collectorNumber': serializer.toJson<String?>(collectorNumber),
      'rarity': serializer.toJson<String?>(rarity),
      'artist': serializer.toJson<String?>(artist),
    };
  }

  UsedPrintData copyWith({
    int? cardId,
    Value<String?> lang = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> flavorName = const Value.absent(),
    Value<String?> manaCost = const Value.absent(),
    Value<String?> typeLine = const Value.absent(),
    Value<String?> oracleText = const Value.absent(),
    Value<String?> flavorText = const Value.absent(),
    Value<String?> power = const Value.absent(),
    Value<String?> toughness = const Value.absent(),
    Value<String?> loyalty = const Value.absent(),
    Value<String?> colors = const Value.absent(),
    Value<String?> colorIdentity = const Value.absent(),
    Value<String?> keywords = const Value.absent(),
    Value<String?> layout = const Value.absent(),
    Value<String?> setCode = const Value.absent(),
    Value<String?> setName = const Value.absent(),
    Value<String?> collectorNumber = const Value.absent(),
    Value<String?> rarity = const Value.absent(),
    Value<String?> artist = const Value.absent(),
  }) => UsedPrintData(
    cardId: cardId ?? this.cardId,
    lang: lang.present ? lang.value : this.lang,
    name: name.present ? name.value : this.name,
    flavorName: flavorName.present ? flavorName.value : this.flavorName,
    manaCost: manaCost.present ? manaCost.value : this.manaCost,
    typeLine: typeLine.present ? typeLine.value : this.typeLine,
    oracleText: oracleText.present ? oracleText.value : this.oracleText,
    flavorText: flavorText.present ? flavorText.value : this.flavorText,
    power: power.present ? power.value : this.power,
    toughness: toughness.present ? toughness.value : this.toughness,
    loyalty: loyalty.present ? loyalty.value : this.loyalty,
    colors: colors.present ? colors.value : this.colors,
    colorIdentity: colorIdentity.present
        ? colorIdentity.value
        : this.colorIdentity,
    keywords: keywords.present ? keywords.value : this.keywords,
    layout: layout.present ? layout.value : this.layout,
    setCode: setCode.present ? setCode.value : this.setCode,
    setName: setName.present ? setName.value : this.setName,
    collectorNumber: collectorNumber.present
        ? collectorNumber.value
        : this.collectorNumber,
    rarity: rarity.present ? rarity.value : this.rarity,
    artist: artist.present ? artist.value : this.artist,
  );
  UsedPrintData copyWithCompanion(CardUsedPrintDataCompanion data) {
    return UsedPrintData(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      lang: data.lang.present ? data.lang.value : this.lang,
      name: data.name.present ? data.name.value : this.name,
      flavorName: data.flavorName.present
          ? data.flavorName.value
          : this.flavorName,
      manaCost: data.manaCost.present ? data.manaCost.value : this.manaCost,
      typeLine: data.typeLine.present ? data.typeLine.value : this.typeLine,
      oracleText: data.oracleText.present
          ? data.oracleText.value
          : this.oracleText,
      flavorText: data.flavorText.present
          ? data.flavorText.value
          : this.flavorText,
      power: data.power.present ? data.power.value : this.power,
      toughness: data.toughness.present ? data.toughness.value : this.toughness,
      loyalty: data.loyalty.present ? data.loyalty.value : this.loyalty,
      colors: data.colors.present ? data.colors.value : this.colors,
      colorIdentity: data.colorIdentity.present
          ? data.colorIdentity.value
          : this.colorIdentity,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      layout: data.layout.present ? data.layout.value : this.layout,
      setCode: data.setCode.present ? data.setCode.value : this.setCode,
      setName: data.setName.present ? data.setName.value : this.setName,
      collectorNumber: data.collectorNumber.present
          ? data.collectorNumber.value
          : this.collectorNumber,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      artist: data.artist.present ? data.artist.value : this.artist,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsedPrintData(')
          ..write('cardId: $cardId, ')
          ..write('lang: $lang, ')
          ..write('name: $name, ')
          ..write('flavorName: $flavorName, ')
          ..write('manaCost: $manaCost, ')
          ..write('typeLine: $typeLine, ')
          ..write('oracleText: $oracleText, ')
          ..write('flavorText: $flavorText, ')
          ..write('power: $power, ')
          ..write('toughness: $toughness, ')
          ..write('loyalty: $loyalty, ')
          ..write('colors: $colors, ')
          ..write('colorIdentity: $colorIdentity, ')
          ..write('keywords: $keywords, ')
          ..write('layout: $layout, ')
          ..write('setCode: $setCode, ')
          ..write('setName: $setName, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('rarity: $rarity, ')
          ..write('artist: $artist')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cardId,
    lang,
    name,
    flavorName,
    manaCost,
    typeLine,
    oracleText,
    flavorText,
    power,
    toughness,
    loyalty,
    colors,
    colorIdentity,
    keywords,
    layout,
    setCode,
    setName,
    collectorNumber,
    rarity,
    artist,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsedPrintData &&
          other.cardId == this.cardId &&
          other.lang == this.lang &&
          other.name == this.name &&
          other.flavorName == this.flavorName &&
          other.manaCost == this.manaCost &&
          other.typeLine == this.typeLine &&
          other.oracleText == this.oracleText &&
          other.flavorText == this.flavorText &&
          other.power == this.power &&
          other.toughness == this.toughness &&
          other.loyalty == this.loyalty &&
          other.colors == this.colors &&
          other.colorIdentity == this.colorIdentity &&
          other.keywords == this.keywords &&
          other.layout == this.layout &&
          other.setCode == this.setCode &&
          other.setName == this.setName &&
          other.collectorNumber == this.collectorNumber &&
          other.rarity == this.rarity &&
          other.artist == this.artist);
}

class CardUsedPrintDataCompanion extends UpdateCompanion<UsedPrintData> {
  final Value<int> cardId;
  final Value<String?> lang;
  final Value<String?> name;
  final Value<String?> flavorName;
  final Value<String?> manaCost;
  final Value<String?> typeLine;
  final Value<String?> oracleText;
  final Value<String?> flavorText;
  final Value<String?> power;
  final Value<String?> toughness;
  final Value<String?> loyalty;
  final Value<String?> colors;
  final Value<String?> colorIdentity;
  final Value<String?> keywords;
  final Value<String?> layout;
  final Value<String?> setCode;
  final Value<String?> setName;
  final Value<String?> collectorNumber;
  final Value<String?> rarity;
  final Value<String?> artist;
  const CardUsedPrintDataCompanion({
    this.cardId = const Value.absent(),
    this.lang = const Value.absent(),
    this.name = const Value.absent(),
    this.flavorName = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.typeLine = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.power = const Value.absent(),
    this.toughness = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.colors = const Value.absent(),
    this.colorIdentity = const Value.absent(),
    this.keywords = const Value.absent(),
    this.layout = const Value.absent(),
    this.setCode = const Value.absent(),
    this.setName = const Value.absent(),
    this.collectorNumber = const Value.absent(),
    this.rarity = const Value.absent(),
    this.artist = const Value.absent(),
  });
  CardUsedPrintDataCompanion.insert({
    this.cardId = const Value.absent(),
    this.lang = const Value.absent(),
    this.name = const Value.absent(),
    this.flavorName = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.typeLine = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.flavorText = const Value.absent(),
    this.power = const Value.absent(),
    this.toughness = const Value.absent(),
    this.loyalty = const Value.absent(),
    this.colors = const Value.absent(),
    this.colorIdentity = const Value.absent(),
    this.keywords = const Value.absent(),
    this.layout = const Value.absent(),
    this.setCode = const Value.absent(),
    this.setName = const Value.absent(),
    this.collectorNumber = const Value.absent(),
    this.rarity = const Value.absent(),
    this.artist = const Value.absent(),
  });
  static Insertable<UsedPrintData> custom({
    Expression<int>? cardId,
    Expression<String>? lang,
    Expression<String>? name,
    Expression<String>? flavorName,
    Expression<String>? manaCost,
    Expression<String>? typeLine,
    Expression<String>? oracleText,
    Expression<String>? flavorText,
    Expression<String>? power,
    Expression<String>? toughness,
    Expression<String>? loyalty,
    Expression<String>? colors,
    Expression<String>? colorIdentity,
    Expression<String>? keywords,
    Expression<String>? layout,
    Expression<String>? setCode,
    Expression<String>? setName,
    Expression<String>? collectorNumber,
    Expression<String>? rarity,
    Expression<String>? artist,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (lang != null) 'lang': lang,
      if (name != null) 'name': name,
      if (flavorName != null) 'flavor_name': flavorName,
      if (manaCost != null) 'mana_cost': manaCost,
      if (typeLine != null) 'type_line': typeLine,
      if (oracleText != null) 'oracle_text': oracleText,
      if (flavorText != null) 'flavor_text': flavorText,
      if (power != null) 'power': power,
      if (toughness != null) 'toughness': toughness,
      if (loyalty != null) 'loyalty': loyalty,
      if (colors != null) 'colors': colors,
      if (colorIdentity != null) 'color_identity': colorIdentity,
      if (keywords != null) 'keywords': keywords,
      if (layout != null) 'layout': layout,
      if (setCode != null) 'set_code': setCode,
      if (setName != null) 'set_name': setName,
      if (collectorNumber != null) 'collector_number': collectorNumber,
      if (rarity != null) 'rarity': rarity,
      if (artist != null) 'artist': artist,
    });
  }

  CardUsedPrintDataCompanion copyWith({
    Value<int>? cardId,
    Value<String?>? lang,
    Value<String?>? name,
    Value<String?>? flavorName,
    Value<String?>? manaCost,
    Value<String?>? typeLine,
    Value<String?>? oracleText,
    Value<String?>? flavorText,
    Value<String?>? power,
    Value<String?>? toughness,
    Value<String?>? loyalty,
    Value<String?>? colors,
    Value<String?>? colorIdentity,
    Value<String?>? keywords,
    Value<String?>? layout,
    Value<String?>? setCode,
    Value<String?>? setName,
    Value<String?>? collectorNumber,
    Value<String?>? rarity,
    Value<String?>? artist,
  }) {
    return CardUsedPrintDataCompanion(
      cardId: cardId ?? this.cardId,
      lang: lang ?? this.lang,
      name: name ?? this.name,
      flavorName: flavorName ?? this.flavorName,
      manaCost: manaCost ?? this.manaCost,
      typeLine: typeLine ?? this.typeLine,
      oracleText: oracleText ?? this.oracleText,
      flavorText: flavorText ?? this.flavorText,
      power: power ?? this.power,
      toughness: toughness ?? this.toughness,
      loyalty: loyalty ?? this.loyalty,
      colors: colors ?? this.colors,
      colorIdentity: colorIdentity ?? this.colorIdentity,
      keywords: keywords ?? this.keywords,
      layout: layout ?? this.layout,
      setCode: setCode ?? this.setCode,
      setName: setName ?? this.setName,
      collectorNumber: collectorNumber ?? this.collectorNumber,
      rarity: rarity ?? this.rarity,
      artist: artist ?? this.artist,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (flavorName.present) {
      map['flavor_name'] = Variable<String>(flavorName.value);
    }
    if (manaCost.present) {
      map['mana_cost'] = Variable<String>(manaCost.value);
    }
    if (typeLine.present) {
      map['type_line'] = Variable<String>(typeLine.value);
    }
    if (oracleText.present) {
      map['oracle_text'] = Variable<String>(oracleText.value);
    }
    if (flavorText.present) {
      map['flavor_text'] = Variable<String>(flavorText.value);
    }
    if (power.present) {
      map['power'] = Variable<String>(power.value);
    }
    if (toughness.present) {
      map['toughness'] = Variable<String>(toughness.value);
    }
    if (loyalty.present) {
      map['loyalty'] = Variable<String>(loyalty.value);
    }
    if (colors.present) {
      map['colors'] = Variable<String>(colors.value);
    }
    if (colorIdentity.present) {
      map['color_identity'] = Variable<String>(colorIdentity.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (layout.present) {
      map['layout'] = Variable<String>(layout.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (collectorNumber.present) {
      map['collector_number'] = Variable<String>(collectorNumber.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardUsedPrintDataCompanion(')
          ..write('cardId: $cardId, ')
          ..write('lang: $lang, ')
          ..write('name: $name, ')
          ..write('flavorName: $flavorName, ')
          ..write('manaCost: $manaCost, ')
          ..write('typeLine: $typeLine, ')
          ..write('oracleText: $oracleText, ')
          ..write('flavorText: $flavorText, ')
          ..write('power: $power, ')
          ..write('toughness: $toughness, ')
          ..write('loyalty: $loyalty, ')
          ..write('colors: $colors, ')
          ..write('colorIdentity: $colorIdentity, ')
          ..write('keywords: $keywords, ')
          ..write('layout: $layout, ')
          ..write('setCode: $setCode, ')
          ..write('setName: $setName, ')
          ..write('collectorNumber: $collectorNumber, ')
          ..write('rarity: $rarity, ')
          ..write('artist: $artist')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ProjectSourcesTable projectSources = $ProjectSourcesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $ArtworksTable artworks = $ArtworksTable(this);
  late final $FlavorTextOptionsTable flavorTextOptions =
      $FlavorTextOptionsTable(this);
  late final $CardDiscoveredSetsTable cardDiscoveredSets =
      $CardDiscoveredSetsTable(this);
  late final $CardDiscoveredPrintingsTable cardDiscoveredPrintings =
      $CardDiscoveredPrintingsTable(this);
  late final $CardPrintDataTable cardPrintData = $CardPrintDataTable(this);
  late final $CardUsedPrintDataTable cardUsedPrintData =
      $CardUsedPrintDataTable(this);
  late final ProjectsDao projectsDao = ProjectsDao(this as AppDatabase);
  late final CardsDao cardsDao = CardsDao(this as AppDatabase);
  late final ArtworksDao artworksDao = ArtworksDao(this as AppDatabase);
  late final FlavorTextDao flavorTextDao = FlavorTextDao(this as AppDatabase);
  late final CardDiscoveredSetsDao cardDiscoveredSetsDao =
      CardDiscoveredSetsDao(this as AppDatabase);
  late final CardDiscoveredPrintingsDao cardDiscoveredPrintingsDao =
      CardDiscoveredPrintingsDao(this as AppDatabase);
  late final PrintDataDao printDataDao = PrintDataDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    projectSources,
    cards,
    artworks,
    flavorTextOptions,
    cardDiscoveredSets,
    cardDiscoveredPrintings,
    cardPrintData,
    cardUsedPrintData,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      required String name,
      required DateTime createdAt,
      Value<String?> frame,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<String?> frame,
    });

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get frame =>
      $composableBuilder(column: $table.frame, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> frame = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                frame: frame,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime createdAt,
                Value<String?> frame = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                frame: frame,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$ProjectSourcesTableCreateCompanionBuilder =
    ProjectSourcesCompanion Function({
      required int projectId,
      required String sourceProviderId,
      Value<int> rowid,
    });
typedef $$ProjectSourcesTableUpdateCompanionBuilder =
    ProjectSourcesCompanion Function({
      Value<int> projectId,
      Value<String> sourceProviderId,
      Value<int> rowid,
    });

class $$ProjectSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectSourcesTable> {
  $$ProjectSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectSourcesTable> {
  $$ProjectSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectSourcesTable> {
  $$ProjectSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => column,
  );
}

class $$ProjectSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectSourcesTable,
          ProjectSource,
          $$ProjectSourcesTableFilterComposer,
          $$ProjectSourcesTableOrderingComposer,
          $$ProjectSourcesTableAnnotationComposer,
          $$ProjectSourcesTableCreateCompanionBuilder,
          $$ProjectSourcesTableUpdateCompanionBuilder,
          (
            ProjectSource,
            BaseReferences<_$AppDatabase, $ProjectSourcesTable, ProjectSource>,
          ),
          ProjectSource,
          PrefetchHooks Function()
        > {
  $$ProjectSourcesTableTableManager(
    _$AppDatabase db,
    $ProjectSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> projectId = const Value.absent(),
                Value<String> sourceProviderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectSourcesCompanion(
                projectId: projectId,
                sourceProviderId: sourceProviderId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int projectId,
                required String sourceProviderId,
                Value<int> rowid = const Value.absent(),
              }) => ProjectSourcesCompanion.insert(
                projectId: projectId,
                sourceProviderId: sourceProviderId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectSourcesTable,
      ProjectSource,
      $$ProjectSourcesTableFilterComposer,
      $$ProjectSourcesTableOrderingComposer,
      $$ProjectSourcesTableAnnotationComposer,
      $$ProjectSourcesTableCreateCompanionBuilder,
      $$ProjectSourcesTableUpdateCompanionBuilder,
      (
        ProjectSource,
        BaseReferences<_$AppDatabase, $ProjectSourcesTable, ProjectSource>,
      ),
      ProjectSource,
      PrefetchHooks Function()
    >;
typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      Value<int> id,
      required int projectId,
      required String name,
      required String normalizedName,
      Value<int?> preferredArtworkId,
      Value<int?> selectedFlavorTextId,
      Value<String?> customFlavorText,
      Value<bool> noFlavorText,
      Value<String?> selectedSetCode,
      Value<String?> selectedSetLang,
      Value<bool> selectedSetIsVoid,
      Value<String?> layout,
      Value<String?> cardType,
      Value<String?> frame,
      Value<String?> scryfallId,
      Value<bool?> isUpToDate,
      Value<String?> selectedCollectorNumber,
      Value<int?> dfcSiblingId,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String> name,
      Value<String> normalizedName,
      Value<int?> preferredArtworkId,
      Value<int?> selectedFlavorTextId,
      Value<String?> customFlavorText,
      Value<bool> noFlavorText,
      Value<String?> selectedSetCode,
      Value<String?> selectedSetLang,
      Value<bool> selectedSetIsVoid,
      Value<String?> layout,
      Value<String?> cardType,
      Value<String?> frame,
      Value<String?> scryfallId,
      Value<bool?> isUpToDate,
      Value<String?> selectedCollectorNumber,
      Value<int?> dfcSiblingId,
    });

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferredArtworkId => $composableBuilder(
    column: $table.preferredArtworkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedFlavorTextId => $composableBuilder(
    column: $table.selectedFlavorTextId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customFlavorText => $composableBuilder(
    column: $table.customFlavorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get noFlavorText => $composableBuilder(
    column: $table.noFlavorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedSetCode => $composableBuilder(
    column: $table.selectedSetCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedSetLang => $composableBuilder(
    column: $table.selectedSetLang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get selectedSetIsVoid => $composableBuilder(
    column: $table.selectedSetIsVoid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layout => $composableBuilder(
    column: $table.layout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUpToDate => $composableBuilder(
    column: $table.isUpToDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedCollectorNumber => $composableBuilder(
    column: $table.selectedCollectorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dfcSiblingId => $composableBuilder(
    column: $table.dfcSiblingId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferredArtworkId => $composableBuilder(
    column: $table.preferredArtworkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedFlavorTextId => $composableBuilder(
    column: $table.selectedFlavorTextId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customFlavorText => $composableBuilder(
    column: $table.customFlavorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get noFlavorText => $composableBuilder(
    column: $table.noFlavorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedSetCode => $composableBuilder(
    column: $table.selectedSetCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedSetLang => $composableBuilder(
    column: $table.selectedSetLang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get selectedSetIsVoid => $composableBuilder(
    column: $table.selectedSetIsVoid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layout => $composableBuilder(
    column: $table.layout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frame => $composableBuilder(
    column: $table.frame,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUpToDate => $composableBuilder(
    column: $table.isUpToDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedCollectorNumber => $composableBuilder(
    column: $table.selectedCollectorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dfcSiblingId => $composableBuilder(
    column: $table.dfcSiblingId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preferredArtworkId => $composableBuilder(
    column: $table.preferredArtworkId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedFlavorTextId => $composableBuilder(
    column: $table.selectedFlavorTextId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customFlavorText => $composableBuilder(
    column: $table.customFlavorText,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get noFlavorText => $composableBuilder(
    column: $table.noFlavorText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedSetCode => $composableBuilder(
    column: $table.selectedSetCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedSetLang => $composableBuilder(
    column: $table.selectedSetLang,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get selectedSetIsVoid => $composableBuilder(
    column: $table.selectedSetIsVoid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get layout =>
      $composableBuilder(column: $table.layout, builder: (column) => column);

  GeneratedColumn<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => column);

  GeneratedColumn<String> get frame =>
      $composableBuilder(column: $table.frame, builder: (column) => column);

  GeneratedColumn<String> get scryfallId => $composableBuilder(
    column: $table.scryfallId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUpToDate => $composableBuilder(
    column: $table.isUpToDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedCollectorNumber => $composableBuilder(
    column: $table.selectedCollectorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dfcSiblingId => $composableBuilder(
    column: $table.dfcSiblingId,
    builder: (column) => column,
  );
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          Card,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (Card, BaseReferences<_$AppDatabase, $CardsTable, Card>),
          Card,
          PrefetchHooks Function()
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int?> preferredArtworkId = const Value.absent(),
                Value<int?> selectedFlavorTextId = const Value.absent(),
                Value<String?> customFlavorText = const Value.absent(),
                Value<bool> noFlavorText = const Value.absent(),
                Value<String?> selectedSetCode = const Value.absent(),
                Value<String?> selectedSetLang = const Value.absent(),
                Value<bool> selectedSetIsVoid = const Value.absent(),
                Value<String?> layout = const Value.absent(),
                Value<String?> cardType = const Value.absent(),
                Value<String?> frame = const Value.absent(),
                Value<String?> scryfallId = const Value.absent(),
                Value<bool?> isUpToDate = const Value.absent(),
                Value<String?> selectedCollectorNumber = const Value.absent(),
                Value<int?> dfcSiblingId = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                projectId: projectId,
                name: name,
                normalizedName: normalizedName,
                preferredArtworkId: preferredArtworkId,
                selectedFlavorTextId: selectedFlavorTextId,
                customFlavorText: customFlavorText,
                noFlavorText: noFlavorText,
                selectedSetCode: selectedSetCode,
                selectedSetLang: selectedSetLang,
                selectedSetIsVoid: selectedSetIsVoid,
                layout: layout,
                cardType: cardType,
                frame: frame,
                scryfallId: scryfallId,
                isUpToDate: isUpToDate,
                selectedCollectorNumber: selectedCollectorNumber,
                dfcSiblingId: dfcSiblingId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                required String name,
                required String normalizedName,
                Value<int?> preferredArtworkId = const Value.absent(),
                Value<int?> selectedFlavorTextId = const Value.absent(),
                Value<String?> customFlavorText = const Value.absent(),
                Value<bool> noFlavorText = const Value.absent(),
                Value<String?> selectedSetCode = const Value.absent(),
                Value<String?> selectedSetLang = const Value.absent(),
                Value<bool> selectedSetIsVoid = const Value.absent(),
                Value<String?> layout = const Value.absent(),
                Value<String?> cardType = const Value.absent(),
                Value<String?> frame = const Value.absent(),
                Value<String?> scryfallId = const Value.absent(),
                Value<bool?> isUpToDate = const Value.absent(),
                Value<String?> selectedCollectorNumber = const Value.absent(),
                Value<int?> dfcSiblingId = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                normalizedName: normalizedName,
                preferredArtworkId: preferredArtworkId,
                selectedFlavorTextId: selectedFlavorTextId,
                customFlavorText: customFlavorText,
                noFlavorText: noFlavorText,
                selectedSetCode: selectedSetCode,
                selectedSetLang: selectedSetLang,
                selectedSetIsVoid: selectedSetIsVoid,
                layout: layout,
                cardType: cardType,
                frame: frame,
                scryfallId: scryfallId,
                isUpToDate: isUpToDate,
                selectedCollectorNumber: selectedCollectorNumber,
                dfcSiblingId: dfcSiblingId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      Card,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (Card, BaseReferences<_$AppDatabase, $CardsTable, Card>),
      Card,
      PrefetchHooks Function()
    >;
typedef $$ArtworksTableCreateCompanionBuilder =
    ArtworksCompanion Function({
      Value<int> id,
      required int cardId,
      required String sourceProviderId,
      Value<String?> remoteId,
      Value<String?> printingSet,
      Value<String?> printingCollectorNumber,
      Value<String?> magicVilleRef,
      required String artist,
      required int width,
      required int height,
      required String sourceUrl,
      required String localPath,
      required DateTime downloadedAt,
      Value<bool> isDiscarded,
    });
typedef $$ArtworksTableUpdateCompanionBuilder =
    ArtworksCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<String> sourceProviderId,
      Value<String?> remoteId,
      Value<String?> printingSet,
      Value<String?> printingCollectorNumber,
      Value<String?> magicVilleRef,
      Value<String> artist,
      Value<int> width,
      Value<int> height,
      Value<String> sourceUrl,
      Value<String> localPath,
      Value<DateTime> downloadedAt,
      Value<bool> isDiscarded,
    });

class $$ArtworksTableFilterComposer
    extends Composer<_$AppDatabase, $ArtworksTable> {
  $$ArtworksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printingSet => $composableBuilder(
    column: $table.printingSet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printingCollectorNumber => $composableBuilder(
    column: $table.printingCollectorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get magicVilleRef => $composableBuilder(
    column: $table.magicVilleRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDiscarded => $composableBuilder(
    column: $table.isDiscarded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtworksTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtworksTable> {
  $$ArtworksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printingSet => $composableBuilder(
    column: $table.printingSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printingCollectorNumber => $composableBuilder(
    column: $table.printingCollectorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get magicVilleRef => $composableBuilder(
    column: $table.magicVilleRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDiscarded => $composableBuilder(
    column: $table.isDiscarded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtworksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtworksTable> {
  $$ArtworksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get printingSet => $composableBuilder(
    column: $table.printingSet,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printingCollectorNumber => $composableBuilder(
    column: $table.printingCollectorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get magicVilleRef => $composableBuilder(
    column: $table.magicVilleRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDiscarded => $composableBuilder(
    column: $table.isDiscarded,
    builder: (column) => column,
  );
}

class $$ArtworksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtworksTable,
          Artwork,
          $$ArtworksTableFilterComposer,
          $$ArtworksTableOrderingComposer,
          $$ArtworksTableAnnotationComposer,
          $$ArtworksTableCreateCompanionBuilder,
          $$ArtworksTableUpdateCompanionBuilder,
          (Artwork, BaseReferences<_$AppDatabase, $ArtworksTable, Artwork>),
          Artwork,
          PrefetchHooks Function()
        > {
  $$ArtworksTableTableManager(_$AppDatabase db, $ArtworksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtworksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtworksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtworksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> sourceProviderId = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> printingSet = const Value.absent(),
                Value<String?> printingCollectorNumber = const Value.absent(),
                Value<String?> magicVilleRef = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<bool> isDiscarded = const Value.absent(),
              }) => ArtworksCompanion(
                id: id,
                cardId: cardId,
                sourceProviderId: sourceProviderId,
                remoteId: remoteId,
                printingSet: printingSet,
                printingCollectorNumber: printingCollectorNumber,
                magicVilleRef: magicVilleRef,
                artist: artist,
                width: width,
                height: height,
                sourceUrl: sourceUrl,
                localPath: localPath,
                downloadedAt: downloadedAt,
                isDiscarded: isDiscarded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required String sourceProviderId,
                Value<String?> remoteId = const Value.absent(),
                Value<String?> printingSet = const Value.absent(),
                Value<String?> printingCollectorNumber = const Value.absent(),
                Value<String?> magicVilleRef = const Value.absent(),
                required String artist,
                required int width,
                required int height,
                required String sourceUrl,
                required String localPath,
                required DateTime downloadedAt,
                Value<bool> isDiscarded = const Value.absent(),
              }) => ArtworksCompanion.insert(
                id: id,
                cardId: cardId,
                sourceProviderId: sourceProviderId,
                remoteId: remoteId,
                printingSet: printingSet,
                printingCollectorNumber: printingCollectorNumber,
                magicVilleRef: magicVilleRef,
                artist: artist,
                width: width,
                height: height,
                sourceUrl: sourceUrl,
                localPath: localPath,
                downloadedAt: downloadedAt,
                isDiscarded: isDiscarded,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtworksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtworksTable,
      Artwork,
      $$ArtworksTableFilterComposer,
      $$ArtworksTableOrderingComposer,
      $$ArtworksTableAnnotationComposer,
      $$ArtworksTableCreateCompanionBuilder,
      $$ArtworksTableUpdateCompanionBuilder,
      (Artwork, BaseReferences<_$AppDatabase, $ArtworksTable, Artwork>),
      Artwork,
      PrefetchHooks Function()
    >;
typedef $$FlavorTextOptionsTableCreateCompanionBuilder =
    FlavorTextOptionsCompanion Function({
      Value<int> id,
      required int cardId,
      required String sourceProviderId,
      required String flavor,
      Value<String?> printingSet,
      Value<String?> printingCollectorNumber,
      Value<String?> lang,
      Value<bool?> hasLocalization,
    });
typedef $$FlavorTextOptionsTableUpdateCompanionBuilder =
    FlavorTextOptionsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<String> sourceProviderId,
      Value<String> flavor,
      Value<String?> printingSet,
      Value<String?> printingCollectorNumber,
      Value<String?> lang,
      Value<bool?> hasLocalization,
    });

class $$FlavorTextOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $FlavorTextOptionsTable> {
  $$FlavorTextOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavor => $composableBuilder(
    column: $table.flavor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printingSet => $composableBuilder(
    column: $table.printingSet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printingCollectorNumber => $composableBuilder(
    column: $table.printingCollectorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasLocalization => $composableBuilder(
    column: $table.hasLocalization,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlavorTextOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlavorTextOptionsTable> {
  $$FlavorTextOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavor => $composableBuilder(
    column: $table.flavor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printingSet => $composableBuilder(
    column: $table.printingSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printingCollectorNumber => $composableBuilder(
    column: $table.printingCollectorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasLocalization => $composableBuilder(
    column: $table.hasLocalization,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlavorTextOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlavorTextOptionsTable> {
  $$FlavorTextOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get sourceProviderId => $composableBuilder(
    column: $table.sourceProviderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavor =>
      $composableBuilder(column: $table.flavor, builder: (column) => column);

  GeneratedColumn<String> get printingSet => $composableBuilder(
    column: $table.printingSet,
    builder: (column) => column,
  );

  GeneratedColumn<String> get printingCollectorNumber => $composableBuilder(
    column: $table.printingCollectorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<bool> get hasLocalization => $composableBuilder(
    column: $table.hasLocalization,
    builder: (column) => column,
  );
}

class $$FlavorTextOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlavorTextOptionsTable,
          FlavorTextOption,
          $$FlavorTextOptionsTableFilterComposer,
          $$FlavorTextOptionsTableOrderingComposer,
          $$FlavorTextOptionsTableAnnotationComposer,
          $$FlavorTextOptionsTableCreateCompanionBuilder,
          $$FlavorTextOptionsTableUpdateCompanionBuilder,
          (
            FlavorTextOption,
            BaseReferences<
              _$AppDatabase,
              $FlavorTextOptionsTable,
              FlavorTextOption
            >,
          ),
          FlavorTextOption,
          PrefetchHooks Function()
        > {
  $$FlavorTextOptionsTableTableManager(
    _$AppDatabase db,
    $FlavorTextOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlavorTextOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlavorTextOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlavorTextOptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> sourceProviderId = const Value.absent(),
                Value<String> flavor = const Value.absent(),
                Value<String?> printingSet = const Value.absent(),
                Value<String?> printingCollectorNumber = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<bool?> hasLocalization = const Value.absent(),
              }) => FlavorTextOptionsCompanion(
                id: id,
                cardId: cardId,
                sourceProviderId: sourceProviderId,
                flavor: flavor,
                printingSet: printingSet,
                printingCollectorNumber: printingCollectorNumber,
                lang: lang,
                hasLocalization: hasLocalization,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required String sourceProviderId,
                required String flavor,
                Value<String?> printingSet = const Value.absent(),
                Value<String?> printingCollectorNumber = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<bool?> hasLocalization = const Value.absent(),
              }) => FlavorTextOptionsCompanion.insert(
                id: id,
                cardId: cardId,
                sourceProviderId: sourceProviderId,
                flavor: flavor,
                printingSet: printingSet,
                printingCollectorNumber: printingCollectorNumber,
                lang: lang,
                hasLocalization: hasLocalization,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlavorTextOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlavorTextOptionsTable,
      FlavorTextOption,
      $$FlavorTextOptionsTableFilterComposer,
      $$FlavorTextOptionsTableOrderingComposer,
      $$FlavorTextOptionsTableAnnotationComposer,
      $$FlavorTextOptionsTableCreateCompanionBuilder,
      $$FlavorTextOptionsTableUpdateCompanionBuilder,
      (
        FlavorTextOption,
        BaseReferences<
          _$AppDatabase,
          $FlavorTextOptionsTable,
          FlavorTextOption
        >,
      ),
      FlavorTextOption,
      PrefetchHooks Function()
    >;
typedef $$CardDiscoveredSetsTableCreateCompanionBuilder =
    CardDiscoveredSetsCompanion Function({
      Value<int> id,
      required int cardId,
      required String setCode,
    });
typedef $$CardDiscoveredSetsTableUpdateCompanionBuilder =
    CardDiscoveredSetsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<String> setCode,
    });

class $$CardDiscoveredSetsTableFilterComposer
    extends Composer<_$AppDatabase, $CardDiscoveredSetsTable> {
  $$CardDiscoveredSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardDiscoveredSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardDiscoveredSetsTable> {
  $$CardDiscoveredSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardDiscoveredSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardDiscoveredSetsTable> {
  $$CardDiscoveredSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);
}

class $$CardDiscoveredSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardDiscoveredSetsTable,
          CardDiscoveredSet,
          $$CardDiscoveredSetsTableFilterComposer,
          $$CardDiscoveredSetsTableOrderingComposer,
          $$CardDiscoveredSetsTableAnnotationComposer,
          $$CardDiscoveredSetsTableCreateCompanionBuilder,
          $$CardDiscoveredSetsTableUpdateCompanionBuilder,
          (
            CardDiscoveredSet,
            BaseReferences<
              _$AppDatabase,
              $CardDiscoveredSetsTable,
              CardDiscoveredSet
            >,
          ),
          CardDiscoveredSet,
          PrefetchHooks Function()
        > {
  $$CardDiscoveredSetsTableTableManager(
    _$AppDatabase db,
    $CardDiscoveredSetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardDiscoveredSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardDiscoveredSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardDiscoveredSetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> setCode = const Value.absent(),
              }) => CardDiscoveredSetsCompanion(
                id: id,
                cardId: cardId,
                setCode: setCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required String setCode,
              }) => CardDiscoveredSetsCompanion.insert(
                id: id,
                cardId: cardId,
                setCode: setCode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardDiscoveredSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardDiscoveredSetsTable,
      CardDiscoveredSet,
      $$CardDiscoveredSetsTableFilterComposer,
      $$CardDiscoveredSetsTableOrderingComposer,
      $$CardDiscoveredSetsTableAnnotationComposer,
      $$CardDiscoveredSetsTableCreateCompanionBuilder,
      $$CardDiscoveredSetsTableUpdateCompanionBuilder,
      (
        CardDiscoveredSet,
        BaseReferences<
          _$AppDatabase,
          $CardDiscoveredSetsTable,
          CardDiscoveredSet
        >,
      ),
      CardDiscoveredSet,
      PrefetchHooks Function()
    >;
typedef $$CardDiscoveredPrintingsTableCreateCompanionBuilder =
    CardDiscoveredPrintingsCompanion Function({
      Value<int> id,
      required int cardId,
      required String setCode,
      required String lang,
      required String setName,
      required String releasedAt,
      Value<String?> artists,
      Value<int?> printDataId,
      Value<String?> collectorNumber,
      Value<String?> rarity,
    });
typedef $$CardDiscoveredPrintingsTableUpdateCompanionBuilder =
    CardDiscoveredPrintingsCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<String> setCode,
      Value<String> lang,
      Value<String> setName,
      Value<String> releasedAt,
      Value<String?> artists,
      Value<int?> printDataId,
      Value<String?> collectorNumber,
      Value<String?> rarity,
    });

class $$CardDiscoveredPrintingsTableFilterComposer
    extends Composer<_$AppDatabase, $CardDiscoveredPrintingsTable> {
  $$CardDiscoveredPrintingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artists => $composableBuilder(
    column: $table.artists,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get printDataId => $composableBuilder(
    column: $table.printDataId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardDiscoveredPrintingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardDiscoveredPrintingsTable> {
  $$CardDiscoveredPrintingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artists => $composableBuilder(
    column: $table.artists,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get printDataId => $composableBuilder(
    column: $table.printDataId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardDiscoveredPrintingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardDiscoveredPrintingsTable> {
  $$CardDiscoveredPrintingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artists =>
      $composableBuilder(column: $table.artists, builder: (column) => column);

  GeneratedColumn<int> get printDataId => $composableBuilder(
    column: $table.printDataId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);
}

class $$CardDiscoveredPrintingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardDiscoveredPrintingsTable,
          CardDiscoveredPrinting,
          $$CardDiscoveredPrintingsTableFilterComposer,
          $$CardDiscoveredPrintingsTableOrderingComposer,
          $$CardDiscoveredPrintingsTableAnnotationComposer,
          $$CardDiscoveredPrintingsTableCreateCompanionBuilder,
          $$CardDiscoveredPrintingsTableUpdateCompanionBuilder,
          (
            CardDiscoveredPrinting,
            BaseReferences<
              _$AppDatabase,
              $CardDiscoveredPrintingsTable,
              CardDiscoveredPrinting
            >,
          ),
          CardDiscoveredPrinting,
          PrefetchHooks Function()
        > {
  $$CardDiscoveredPrintingsTableTableManager(
    _$AppDatabase db,
    $CardDiscoveredPrintingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardDiscoveredPrintingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CardDiscoveredPrintingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CardDiscoveredPrintingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> setCode = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> releasedAt = const Value.absent(),
                Value<String?> artists = const Value.absent(),
                Value<int?> printDataId = const Value.absent(),
                Value<String?> collectorNumber = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
              }) => CardDiscoveredPrintingsCompanion(
                id: id,
                cardId: cardId,
                setCode: setCode,
                lang: lang,
                setName: setName,
                releasedAt: releasedAt,
                artists: artists,
                printDataId: printDataId,
                collectorNumber: collectorNumber,
                rarity: rarity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required String setCode,
                required String lang,
                required String setName,
                required String releasedAt,
                Value<String?> artists = const Value.absent(),
                Value<int?> printDataId = const Value.absent(),
                Value<String?> collectorNumber = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
              }) => CardDiscoveredPrintingsCompanion.insert(
                id: id,
                cardId: cardId,
                setCode: setCode,
                lang: lang,
                setName: setName,
                releasedAt: releasedAt,
                artists: artists,
                printDataId: printDataId,
                collectorNumber: collectorNumber,
                rarity: rarity,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardDiscoveredPrintingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardDiscoveredPrintingsTable,
      CardDiscoveredPrinting,
      $$CardDiscoveredPrintingsTableFilterComposer,
      $$CardDiscoveredPrintingsTableOrderingComposer,
      $$CardDiscoveredPrintingsTableAnnotationComposer,
      $$CardDiscoveredPrintingsTableCreateCompanionBuilder,
      $$CardDiscoveredPrintingsTableUpdateCompanionBuilder,
      (
        CardDiscoveredPrinting,
        BaseReferences<
          _$AppDatabase,
          $CardDiscoveredPrintingsTable,
          CardDiscoveredPrinting
        >,
      ),
      CardDiscoveredPrinting,
      PrefetchHooks Function()
    >;
typedef $$CardPrintDataTableCreateCompanionBuilder =
    CardPrintDataCompanion Function({
      Value<int> id,
      required int cardId,
      required String contentHash,
      required String lang,
      required String name,
      Value<String?> flavorName,
      Value<String?> manaCost,
      Value<String?> typeLine,
      Value<String?> oracleText,
      Value<String?> flavorText,
      Value<String?> power,
      Value<String?> toughness,
      Value<String?> loyalty,
      Value<String?> colors,
      Value<String?> colorIdentity,
      Value<String?> keywords,
      Value<String?> layout,
    });
typedef $$CardPrintDataTableUpdateCompanionBuilder =
    CardPrintDataCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<String> contentHash,
      Value<String> lang,
      Value<String> name,
      Value<String?> flavorName,
      Value<String?> manaCost,
      Value<String?> typeLine,
      Value<String?> oracleText,
      Value<String?> flavorText,
      Value<String?> power,
      Value<String?> toughness,
      Value<String?> loyalty,
      Value<String?> colors,
      Value<String?> colorIdentity,
      Value<String?> keywords,
      Value<String?> layout,
    });

class $$CardPrintDataTableFilterComposer
    extends Composer<_$AppDatabase, $CardPrintDataTable> {
  $$CardPrintDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manaCost => $composableBuilder(
    column: $table.manaCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toughness => $composableBuilder(
    column: $table.toughness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colors => $composableBuilder(
    column: $table.colors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorIdentity => $composableBuilder(
    column: $table.colorIdentity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layout => $composableBuilder(
    column: $table.layout,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardPrintDataTableOrderingComposer
    extends Composer<_$AppDatabase, $CardPrintDataTable> {
  $$CardPrintDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manaCost => $composableBuilder(
    column: $table.manaCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toughness => $composableBuilder(
    column: $table.toughness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colors => $composableBuilder(
    column: $table.colors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorIdentity => $composableBuilder(
    column: $table.colorIdentity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layout => $composableBuilder(
    column: $table.layout,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardPrintDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardPrintDataTable> {
  $$CardPrintDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manaCost =>
      $composableBuilder(column: $table.manaCost, builder: (column) => column);

  GeneratedColumn<String> get typeLine =>
      $composableBuilder(column: $table.typeLine, builder: (column) => column);

  GeneratedColumn<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get power =>
      $composableBuilder(column: $table.power, builder: (column) => column);

  GeneratedColumn<String> get toughness =>
      $composableBuilder(column: $table.toughness, builder: (column) => column);

  GeneratedColumn<String> get loyalty =>
      $composableBuilder(column: $table.loyalty, builder: (column) => column);

  GeneratedColumn<String> get colors =>
      $composableBuilder(column: $table.colors, builder: (column) => column);

  GeneratedColumn<String> get colorIdentity => $composableBuilder(
    column: $table.colorIdentity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<String> get layout =>
      $composableBuilder(column: $table.layout, builder: (column) => column);
}

class $$CardPrintDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardPrintDataTable,
          PrintData,
          $$CardPrintDataTableFilterComposer,
          $$CardPrintDataTableOrderingComposer,
          $$CardPrintDataTableAnnotationComposer,
          $$CardPrintDataTableCreateCompanionBuilder,
          $$CardPrintDataTableUpdateCompanionBuilder,
          (
            PrintData,
            BaseReferences<_$AppDatabase, $CardPrintDataTable, PrintData>,
          ),
          PrintData,
          PrefetchHooks Function()
        > {
  $$CardPrintDataTableTableManager(_$AppDatabase db, $CardPrintDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardPrintDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardPrintDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardPrintDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> flavorName = const Value.absent(),
                Value<String?> manaCost = const Value.absent(),
                Value<String?> typeLine = const Value.absent(),
                Value<String?> oracleText = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<String?> power = const Value.absent(),
                Value<String?> toughness = const Value.absent(),
                Value<String?> loyalty = const Value.absent(),
                Value<String?> colors = const Value.absent(),
                Value<String?> colorIdentity = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<String?> layout = const Value.absent(),
              }) => CardPrintDataCompanion(
                id: id,
                cardId: cardId,
                contentHash: contentHash,
                lang: lang,
                name: name,
                flavorName: flavorName,
                manaCost: manaCost,
                typeLine: typeLine,
                oracleText: oracleText,
                flavorText: flavorText,
                power: power,
                toughness: toughness,
                loyalty: loyalty,
                colors: colors,
                colorIdentity: colorIdentity,
                keywords: keywords,
                layout: layout,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                required String contentHash,
                required String lang,
                required String name,
                Value<String?> flavorName = const Value.absent(),
                Value<String?> manaCost = const Value.absent(),
                Value<String?> typeLine = const Value.absent(),
                Value<String?> oracleText = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<String?> power = const Value.absent(),
                Value<String?> toughness = const Value.absent(),
                Value<String?> loyalty = const Value.absent(),
                Value<String?> colors = const Value.absent(),
                Value<String?> colorIdentity = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<String?> layout = const Value.absent(),
              }) => CardPrintDataCompanion.insert(
                id: id,
                cardId: cardId,
                contentHash: contentHash,
                lang: lang,
                name: name,
                flavorName: flavorName,
                manaCost: manaCost,
                typeLine: typeLine,
                oracleText: oracleText,
                flavorText: flavorText,
                power: power,
                toughness: toughness,
                loyalty: loyalty,
                colors: colors,
                colorIdentity: colorIdentity,
                keywords: keywords,
                layout: layout,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardPrintDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardPrintDataTable,
      PrintData,
      $$CardPrintDataTableFilterComposer,
      $$CardPrintDataTableOrderingComposer,
      $$CardPrintDataTableAnnotationComposer,
      $$CardPrintDataTableCreateCompanionBuilder,
      $$CardPrintDataTableUpdateCompanionBuilder,
      (
        PrintData,
        BaseReferences<_$AppDatabase, $CardPrintDataTable, PrintData>,
      ),
      PrintData,
      PrefetchHooks Function()
    >;
typedef $$CardUsedPrintDataTableCreateCompanionBuilder =
    CardUsedPrintDataCompanion Function({
      Value<int> cardId,
      Value<String?> lang,
      Value<String?> name,
      Value<String?> flavorName,
      Value<String?> manaCost,
      Value<String?> typeLine,
      Value<String?> oracleText,
      Value<String?> flavorText,
      Value<String?> power,
      Value<String?> toughness,
      Value<String?> loyalty,
      Value<String?> colors,
      Value<String?> colorIdentity,
      Value<String?> keywords,
      Value<String?> layout,
      Value<String?> setCode,
      Value<String?> setName,
      Value<String?> collectorNumber,
      Value<String?> rarity,
      Value<String?> artist,
    });
typedef $$CardUsedPrintDataTableUpdateCompanionBuilder =
    CardUsedPrintDataCompanion Function({
      Value<int> cardId,
      Value<String?> lang,
      Value<String?> name,
      Value<String?> flavorName,
      Value<String?> manaCost,
      Value<String?> typeLine,
      Value<String?> oracleText,
      Value<String?> flavorText,
      Value<String?> power,
      Value<String?> toughness,
      Value<String?> loyalty,
      Value<String?> colors,
      Value<String?> colorIdentity,
      Value<String?> keywords,
      Value<String?> layout,
      Value<String?> setCode,
      Value<String?> setName,
      Value<String?> collectorNumber,
      Value<String?> rarity,
      Value<String?> artist,
    });

class $$CardUsedPrintDataTableFilterComposer
    extends Composer<_$AppDatabase, $CardUsedPrintDataTable> {
  $$CardUsedPrintDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manaCost => $composableBuilder(
    column: $table.manaCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toughness => $composableBuilder(
    column: $table.toughness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colors => $composableBuilder(
    column: $table.colors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorIdentity => $composableBuilder(
    column: $table.colorIdentity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get layout => $composableBuilder(
    column: $table.layout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardUsedPrintDataTableOrderingComposer
    extends Composer<_$AppDatabase, $CardUsedPrintDataTable> {
  $$CardUsedPrintDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manaCost => $composableBuilder(
    column: $table.manaCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeLine => $composableBuilder(
    column: $table.typeLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get power => $composableBuilder(
    column: $table.power,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toughness => $composableBuilder(
    column: $table.toughness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loyalty => $composableBuilder(
    column: $table.loyalty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colors => $composableBuilder(
    column: $table.colors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorIdentity => $composableBuilder(
    column: $table.colorIdentity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get layout => $composableBuilder(
    column: $table.layout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setCode => $composableBuilder(
    column: $table.setCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardUsedPrintDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardUsedPrintDataTable> {
  $$CardUsedPrintDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get flavorName => $composableBuilder(
    column: $table.flavorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manaCost =>
      $composableBuilder(column: $table.manaCost, builder: (column) => column);

  GeneratedColumn<String> get typeLine =>
      $composableBuilder(column: $table.typeLine, builder: (column) => column);

  GeneratedColumn<String> get oracleText => $composableBuilder(
    column: $table.oracleText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavorText => $composableBuilder(
    column: $table.flavorText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get power =>
      $composableBuilder(column: $table.power, builder: (column) => column);

  GeneratedColumn<String> get toughness =>
      $composableBuilder(column: $table.toughness, builder: (column) => column);

  GeneratedColumn<String> get loyalty =>
      $composableBuilder(column: $table.loyalty, builder: (column) => column);

  GeneratedColumn<String> get colors =>
      $composableBuilder(column: $table.colors, builder: (column) => column);

  GeneratedColumn<String> get colorIdentity => $composableBuilder(
    column: $table.colorIdentity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<String> get layout =>
      $composableBuilder(column: $table.layout, builder: (column) => column);

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get collectorNumber => $composableBuilder(
    column: $table.collectorNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);
}

class $$CardUsedPrintDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardUsedPrintDataTable,
          UsedPrintData,
          $$CardUsedPrintDataTableFilterComposer,
          $$CardUsedPrintDataTableOrderingComposer,
          $$CardUsedPrintDataTableAnnotationComposer,
          $$CardUsedPrintDataTableCreateCompanionBuilder,
          $$CardUsedPrintDataTableUpdateCompanionBuilder,
          (
            UsedPrintData,
            BaseReferences<
              _$AppDatabase,
              $CardUsedPrintDataTable,
              UsedPrintData
            >,
          ),
          UsedPrintData,
          PrefetchHooks Function()
        > {
  $$CardUsedPrintDataTableTableManager(
    _$AppDatabase db,
    $CardUsedPrintDataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardUsedPrintDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardUsedPrintDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardUsedPrintDataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> cardId = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> flavorName = const Value.absent(),
                Value<String?> manaCost = const Value.absent(),
                Value<String?> typeLine = const Value.absent(),
                Value<String?> oracleText = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<String?> power = const Value.absent(),
                Value<String?> toughness = const Value.absent(),
                Value<String?> loyalty = const Value.absent(),
                Value<String?> colors = const Value.absent(),
                Value<String?> colorIdentity = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<String?> layout = const Value.absent(),
                Value<String?> setCode = const Value.absent(),
                Value<String?> setName = const Value.absent(),
                Value<String?> collectorNumber = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
                Value<String?> artist = const Value.absent(),
              }) => CardUsedPrintDataCompanion(
                cardId: cardId,
                lang: lang,
                name: name,
                flavorName: flavorName,
                manaCost: manaCost,
                typeLine: typeLine,
                oracleText: oracleText,
                flavorText: flavorText,
                power: power,
                toughness: toughness,
                loyalty: loyalty,
                colors: colors,
                colorIdentity: colorIdentity,
                keywords: keywords,
                layout: layout,
                setCode: setCode,
                setName: setName,
                collectorNumber: collectorNumber,
                rarity: rarity,
                artist: artist,
              ),
          createCompanionCallback:
              ({
                Value<int> cardId = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> flavorName = const Value.absent(),
                Value<String?> manaCost = const Value.absent(),
                Value<String?> typeLine = const Value.absent(),
                Value<String?> oracleText = const Value.absent(),
                Value<String?> flavorText = const Value.absent(),
                Value<String?> power = const Value.absent(),
                Value<String?> toughness = const Value.absent(),
                Value<String?> loyalty = const Value.absent(),
                Value<String?> colors = const Value.absent(),
                Value<String?> colorIdentity = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<String?> layout = const Value.absent(),
                Value<String?> setCode = const Value.absent(),
                Value<String?> setName = const Value.absent(),
                Value<String?> collectorNumber = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
                Value<String?> artist = const Value.absent(),
              }) => CardUsedPrintDataCompanion.insert(
                cardId: cardId,
                lang: lang,
                name: name,
                flavorName: flavorName,
                manaCost: manaCost,
                typeLine: typeLine,
                oracleText: oracleText,
                flavorText: flavorText,
                power: power,
                toughness: toughness,
                loyalty: loyalty,
                colors: colors,
                colorIdentity: colorIdentity,
                keywords: keywords,
                layout: layout,
                setCode: setCode,
                setName: setName,
                collectorNumber: collectorNumber,
                rarity: rarity,
                artist: artist,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardUsedPrintDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardUsedPrintDataTable,
      UsedPrintData,
      $$CardUsedPrintDataTableFilterComposer,
      $$CardUsedPrintDataTableOrderingComposer,
      $$CardUsedPrintDataTableAnnotationComposer,
      $$CardUsedPrintDataTableCreateCompanionBuilder,
      $$CardUsedPrintDataTableUpdateCompanionBuilder,
      (
        UsedPrintData,
        BaseReferences<_$AppDatabase, $CardUsedPrintDataTable, UsedPrintData>,
      ),
      UsedPrintData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ProjectSourcesTableTableManager get projectSources =>
      $$ProjectSourcesTableTableManager(_db, _db.projectSources);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$ArtworksTableTableManager get artworks =>
      $$ArtworksTableTableManager(_db, _db.artworks);
  $$FlavorTextOptionsTableTableManager get flavorTextOptions =>
      $$FlavorTextOptionsTableTableManager(_db, _db.flavorTextOptions);
  $$CardDiscoveredSetsTableTableManager get cardDiscoveredSets =>
      $$CardDiscoveredSetsTableTableManager(_db, _db.cardDiscoveredSets);
  $$CardDiscoveredPrintingsTableTableManager get cardDiscoveredPrintings =>
      $$CardDiscoveredPrintingsTableTableManager(
        _db,
        _db.cardDiscoveredPrintings,
      );
  $$CardPrintDataTableTableManager get cardPrintData =>
      $$CardPrintDataTableTableManager(_db, _db.cardPrintData);
  $$CardUsedPrintDataTableTableManager get cardUsedPrintData =>
      $$CardUsedPrintDataTableTableManager(_db, _db.cardUsedPrintData);
}
