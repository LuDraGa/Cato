// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTrackerCollection on Isar {
  IsarCollection<Tracker> get trackers => this.collection();
}

const TrackerSchema = CollectionSchema(
  name: r'Tracker',
  id: 7807881673085184336,
  properties: {
    r'allowedVisualizations': PropertySchema(
      id: 0,
      name: r'allowedVisualizations',
      type: IsarType.stringList,
    ),
    r'countsForCompletion': PropertySchema(
      id: 1,
      name: r'countsForCompletion',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'domainUid': PropertySchema(
      id: 3,
      name: r'domainUid',
      type: IsarType.string,
    ),
    r'frequency': PropertySchema(
      id: 4,
      name: r'frequency',
      type: IsarType.string,
    ),
    r'heatmapMode': PropertySchema(
      id: 5,
      name: r'heatmapMode',
      type: IsarType.string,
    ),
    r'icon': PropertySchema(
      id: 6,
      name: r'icon',
      type: IsarType.string,
    ),
    r'inputSchema': PropertySchema(
      id: 7,
      name: r'inputSchema',
      type: IsarType.objectList,
      target: r'InputFieldSchema',
    ),
    r'isActive': PropertySchema(
      id: 8,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'promptTimes': PropertySchema(
      id: 10,
      name: r'promptTimes',
      type: IsarType.stringList,
    ),
    r'scoreContribution': PropertySchema(
      id: 11,
      name: r'scoreContribution',
      type: IsarType.bool,
    ),
    r'scoreKey': PropertySchema(
      id: 12,
      name: r'scoreKey',
      type: IsarType.string,
    ),
    r'scoreMax': PropertySchema(
      id: 13,
      name: r'scoreMax',
      type: IsarType.long,
    ),
    r'scoreMin': PropertySchema(
      id: 14,
      name: r'scoreMin',
      type: IsarType.long,
    ),
    r'sortOrder': PropertySchema(
      id: 15,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'sortedInputSchema': PropertySchema(
      id: 16,
      name: r'sortedInputSchema',
      type: IsarType.objectList,
      target: r'InputFieldSchema',
    ),
    r'uid': PropertySchema(
      id: 17,
      name: r'uid',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 18,
      name: r'version',
      type: IsarType.long,
    )
  },
  estimateSize: _trackerEstimateSize,
  serialize: _trackerSerialize,
  deserialize: _trackerDeserialize,
  deserializeProp: _trackerDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'domainUid': IndexSchema(
      id: -2458834398006697833,
      name: r'domainUid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'domainUid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'InputFieldSchema': InputFieldSchemaSchema},
  getId: _trackerGetId,
  getLinks: _trackerGetLinks,
  attach: _trackerAttach,
  version: '3.1.0+1',
);

int _trackerEstimateSize(
  Tracker object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.allowedVisualizations.length * 3;
  {
    for (var i = 0; i < object.allowedVisualizations.length; i++) {
      final value = object.allowedVisualizations[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.domainUid.length * 3;
  bytesCount += 3 + object.frequency.length * 3;
  bytesCount += 3 + object.heatmapMode.length * 3;
  bytesCount += 3 + object.icon.length * 3;
  bytesCount += 3 + object.inputSchema.length * 3;
  {
    final offsets = allOffsets[InputFieldSchema]!;
    for (var i = 0; i < object.inputSchema.length; i++) {
      final value = object.inputSchema[i];
      bytesCount +=
          InputFieldSchemaSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.promptTimes.length * 3;
  {
    for (var i = 0; i < object.promptTimes.length; i++) {
      final value = object.promptTimes[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.scoreKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sortedInputSchema.length * 3;
  {
    final offsets = allOffsets[InputFieldSchema]!;
    for (var i = 0; i < object.sortedInputSchema.length; i++) {
      final value = object.sortedInputSchema[i];
      bytesCount +=
          InputFieldSchemaSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _trackerSerialize(
  Tracker object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.allowedVisualizations);
  writer.writeBool(offsets[1], object.countsForCompletion);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.domainUid);
  writer.writeString(offsets[4], object.frequency);
  writer.writeString(offsets[5], object.heatmapMode);
  writer.writeString(offsets[6], object.icon);
  writer.writeObjectList<InputFieldSchema>(
    offsets[7],
    allOffsets,
    InputFieldSchemaSchema.serialize,
    object.inputSchema,
  );
  writer.writeBool(offsets[8], object.isActive);
  writer.writeString(offsets[9], object.name);
  writer.writeStringList(offsets[10], object.promptTimes);
  writer.writeBool(offsets[11], object.scoreContribution);
  writer.writeString(offsets[12], object.scoreKey);
  writer.writeLong(offsets[13], object.scoreMax);
  writer.writeLong(offsets[14], object.scoreMin);
  writer.writeLong(offsets[15], object.sortOrder);
  writer.writeObjectList<InputFieldSchema>(
    offsets[16],
    allOffsets,
    InputFieldSchemaSchema.serialize,
    object.sortedInputSchema,
  );
  writer.writeString(offsets[17], object.uid);
  writer.writeLong(offsets[18], object.version);
}

Tracker _trackerDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Tracker();
  object.allowedVisualizations = reader.readStringList(offsets[0]) ?? [];
  object.countsForCompletion = reader.readBool(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.domainUid = reader.readString(offsets[3]);
  object.frequency = reader.readString(offsets[4]);
  object.heatmapMode = reader.readString(offsets[5]);
  object.icon = reader.readString(offsets[6]);
  object.inputSchema = reader.readObjectList<InputFieldSchema>(
        offsets[7],
        InputFieldSchemaSchema.deserialize,
        allOffsets,
        InputFieldSchema(),
      ) ??
      [];
  object.isActive = reader.readBool(offsets[8]);
  object.isarId = id;
  object.name = reader.readString(offsets[9]);
  object.promptTimes = reader.readStringList(offsets[10]) ?? [];
  object.scoreContribution = reader.readBool(offsets[11]);
  object.scoreKey = reader.readStringOrNull(offsets[12]);
  object.scoreMax = reader.readLong(offsets[13]);
  object.scoreMin = reader.readLong(offsets[14]);
  object.sortOrder = reader.readLong(offsets[15]);
  object.uid = reader.readString(offsets[17]);
  object.version = reader.readLong(offsets[18]);
  return object;
}

P _trackerDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readObjectList<InputFieldSchema>(
            offset,
            InputFieldSchemaSchema.deserialize,
            allOffsets,
            InputFieldSchema(),
          ) ??
          []) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readObjectList<InputFieldSchema>(
            offset,
            InputFieldSchemaSchema.deserialize,
            allOffsets,
            InputFieldSchema(),
          ) ??
          []) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _trackerGetId(Tracker object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _trackerGetLinks(Tracker object) {
  return [];
}

void _trackerAttach(IsarCollection<dynamic> col, Id id, Tracker object) {
  object.isarId = id;
}

extension TrackerByIndex on IsarCollection<Tracker> {
  Future<Tracker?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  Tracker? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<Tracker?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<Tracker?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(Tracker object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(Tracker object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<Tracker> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<Tracker> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension TrackerQueryWhereSort on QueryBuilder<Tracker, Tracker, QWhere> {
  QueryBuilder<Tracker, Tracker, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TrackerQueryWhere on QueryBuilder<Tracker, Tracker, QWhereClause> {
  QueryBuilder<Tracker, Tracker, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterWhereClause> isarIdGreaterThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterWhereClause> isarIdLessThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterWhereClause> uidEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterWhereClause> uidNotEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterWhereClause> domainUidEqualTo(
      String domainUid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'domainUid',
        value: [domainUid],
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterWhereClause> domainUidNotEqualTo(
      String domainUid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'domainUid',
              lower: [],
              upper: [domainUid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'domainUid',
              lower: [domainUid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'domainUid',
              lower: [domainUid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'domainUid',
              lower: [],
              upper: [domainUid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TrackerQueryFilter
    on QueryBuilder<Tracker, Tracker, QFilterCondition> {
  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowedVisualizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'allowedVisualizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'allowedVisualizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'allowedVisualizations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'allowedVisualizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'allowedVisualizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'allowedVisualizations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'allowedVisualizations',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowedVisualizations',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'allowedVisualizations',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedVisualizations',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedVisualizations',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedVisualizations',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedVisualizations',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedVisualizations',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      allowedVisualizationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedVisualizations',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      countsForCompletionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'countsForCompletion',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'domainUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'domainUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'domainUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'domainUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'domainUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'domainUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'domainUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'domainUid',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> domainUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'domainUid',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frequency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> frequencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frequency',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heatmapMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heatmapMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heatmapMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heatmapMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'heatmapMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'heatmapMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'heatmapMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'heatmapMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> heatmapModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heatmapMode',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      heatmapModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'heatmapMode',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'icon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'icon',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> iconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      inputSchemaLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inputSchema',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> inputSchemaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inputSchema',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      inputSchemaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inputSchema',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      inputSchemaLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inputSchema',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      inputSchemaLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inputSchema',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      inputSchemaLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inputSchema',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'promptTimes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'promptTimes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'promptTimes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'promptTimes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'promptTimes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'promptTimes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'promptTimes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'promptTimes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'promptTimes',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'promptTimes',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'promptTimes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> promptTimesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'promptTimes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'promptTimes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'promptTimes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'promptTimes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      promptTimesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'promptTimes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      scoreContributionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreContribution',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scoreKey',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scoreKey',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scoreKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scoreKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scoreKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scoreKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scoreKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scoreKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scoreKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreKey',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scoreKey',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreMaxEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreMaxGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scoreMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreMaxLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scoreMax',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreMaxBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scoreMax',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreMinEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scoreMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scoreMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scoreMin',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> scoreMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scoreMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> sortOrderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      sortedInputSchemaLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedInputSchema',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      sortedInputSchemaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedInputSchema',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      sortedInputSchemaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedInputSchema',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      sortedInputSchemaLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedInputSchema',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      sortedInputSchemaLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedInputSchema',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      sortedInputSchemaLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedInputSchema',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> versionEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TrackerQueryObject
    on QueryBuilder<Tracker, Tracker, QFilterCondition> {
  QueryBuilder<Tracker, Tracker, QAfterFilterCondition> inputSchemaElement(
      FilterQuery<InputFieldSchema> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'inputSchema');
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterFilterCondition>
      sortedInputSchemaElement(FilterQuery<InputFieldSchema> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'sortedInputSchema');
    });
  }
}

extension TrackerQueryLinks
    on QueryBuilder<Tracker, Tracker, QFilterCondition> {}

extension TrackerQuerySortBy on QueryBuilder<Tracker, Tracker, QSortBy> {
  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByCountsForCompletion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countsForCompletion', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByCountsForCompletionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countsForCompletion', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByDomainUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainUid', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByDomainUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainUid', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByHeatmapMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heatmapMode', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByHeatmapModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heatmapMode', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByScoreContribution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreContribution', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByScoreContributionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreContribution', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByScoreKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreKey', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByScoreKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreKey', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByScoreMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreMax', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByScoreMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreMax', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByScoreMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreMin', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByScoreMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreMin', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension TrackerQuerySortThenBy
    on QueryBuilder<Tracker, Tracker, QSortThenBy> {
  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByCountsForCompletion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countsForCompletion', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByCountsForCompletionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'countsForCompletion', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByDomainUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainUid', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByDomainUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainUid', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByHeatmapMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heatmapMode', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByHeatmapModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heatmapMode', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByScoreContribution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreContribution', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByScoreContributionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreContribution', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByScoreKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreKey', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByScoreKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreKey', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByScoreMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreMax', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByScoreMaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreMax', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByScoreMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreMin', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByScoreMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scoreMin', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Tracker, Tracker, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension TrackerQueryWhereDistinct
    on QueryBuilder<Tracker, Tracker, QDistinct> {
  QueryBuilder<Tracker, Tracker, QDistinct> distinctByAllowedVisualizations() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowedVisualizations');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByCountsForCompletion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'countsForCompletion');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByDomainUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByFrequency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByHeatmapMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heatmapMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByIcon(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'icon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByPromptTimes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'promptTimes');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByScoreContribution() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scoreContribution');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByScoreKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scoreKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByScoreMax() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scoreMax');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByScoreMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scoreMin');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tracker, Tracker, QDistinct> distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension TrackerQueryProperty
    on QueryBuilder<Tracker, Tracker, QQueryProperty> {
  QueryBuilder<Tracker, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<Tracker, List<String>, QQueryOperations>
      allowedVisualizationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowedVisualizations');
    });
  }

  QueryBuilder<Tracker, bool, QQueryOperations> countsForCompletionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'countsForCompletion');
    });
  }

  QueryBuilder<Tracker, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Tracker, String, QQueryOperations> domainUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainUid');
    });
  }

  QueryBuilder<Tracker, String, QQueryOperations> frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<Tracker, String, QQueryOperations> heatmapModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heatmapMode');
    });
  }

  QueryBuilder<Tracker, String, QQueryOperations> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'icon');
    });
  }

  QueryBuilder<Tracker, List<InputFieldSchema>, QQueryOperations>
      inputSchemaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputSchema');
    });
  }

  QueryBuilder<Tracker, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<Tracker, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Tracker, List<String>, QQueryOperations> promptTimesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'promptTimes');
    });
  }

  QueryBuilder<Tracker, bool, QQueryOperations> scoreContributionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scoreContribution');
    });
  }

  QueryBuilder<Tracker, String?, QQueryOperations> scoreKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scoreKey');
    });
  }

  QueryBuilder<Tracker, int, QQueryOperations> scoreMaxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scoreMax');
    });
  }

  QueryBuilder<Tracker, int, QQueryOperations> scoreMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scoreMin');
    });
  }

  QueryBuilder<Tracker, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<Tracker, List<InputFieldSchema>, QQueryOperations>
      sortedInputSchemaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortedInputSchema');
    });
  }

  QueryBuilder<Tracker, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<Tracker, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
