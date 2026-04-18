// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEventCollection on Isar {
  IsarCollection<Event> get events => this.collection();
}

const EventSchema = CollectionSchema(
  name: r'Event',
  id: 2102939193127251002,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'effectiveDate': PropertySchema(
      id: 1,
      name: r'effectiveDate',
      type: IsarType.dateTime,
    ),
    r'effectiveTime': PropertySchema(
      id: 2,
      name: r'effectiveTime',
      type: IsarType.dateTime,
    ),
    r'isBackfill': PropertySchema(
      id: 3,
      name: r'isBackfill',
      type: IsarType.bool,
    ),
    r'metrics': PropertySchema(
      id: 4,
      name: r'metrics',
      type: IsarType.objectList,
      target: r'MetricValue',
    ),
    r'trackerUid': PropertySchema(
      id: 5,
      name: r'trackerUid',
      type: IsarType.string,
    ),
    r'trackerVersion': PropertySchema(
      id: 6,
      name: r'trackerVersion',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(
      id: 7,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _eventEstimateSize,
  serialize: _eventSerialize,
  deserialize: _eventDeserialize,
  deserializeProp: _eventDeserializeProp,
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
    r'trackerUid_effectiveDate': IndexSchema(
      id: -8409262744669191356,
      name: r'trackerUid_effectiveDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'trackerUid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'effectiveDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'effectiveDate': IndexSchema(
      id: -7077868408091942357,
      name: r'effectiveDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'effectiveDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'MetricValue': MetricValueSchema},
  getId: _eventGetId,
  getLinks: _eventGetLinks,
  attach: _eventAttach,
  version: '3.1.0+1',
);

int _eventEstimateSize(
  Event object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.metrics.length * 3;
  {
    final offsets = allOffsets[MetricValue]!;
    for (var i = 0; i < object.metrics.length; i++) {
      final value = object.metrics[i];
      bytesCount += MetricValueSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.trackerUid.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _eventSerialize(
  Event object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.effectiveDate);
  writer.writeDateTime(offsets[2], object.effectiveTime);
  writer.writeBool(offsets[3], object.isBackfill);
  writer.writeObjectList<MetricValue>(
    offsets[4],
    allOffsets,
    MetricValueSchema.serialize,
    object.metrics,
  );
  writer.writeString(offsets[5], object.trackerUid);
  writer.writeLong(offsets[6], object.trackerVersion);
  writer.writeString(offsets[7], object.uid);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

Event _eventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Event();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.effectiveDate = reader.readDateTime(offsets[1]);
  object.effectiveTime = reader.readDateTimeOrNull(offsets[2]);
  object.isBackfill = reader.readBool(offsets[3]);
  object.isarId = id;
  object.metrics = reader.readObjectList<MetricValue>(
        offsets[4],
        MetricValueSchema.deserialize,
        allOffsets,
        MetricValue(),
      ) ??
      [];
  object.trackerUid = reader.readString(offsets[5]);
  object.trackerVersion = reader.readLong(offsets[6]);
  object.uid = reader.readString(offsets[7]);
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _eventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readObjectList<MetricValue>(
            offset,
            MetricValueSchema.deserialize,
            allOffsets,
            MetricValue(),
          ) ??
          []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _eventGetId(Event object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _eventGetLinks(Event object) {
  return [];
}

void _eventAttach(IsarCollection<dynamic> col, Id id, Event object) {
  object.isarId = id;
}

extension EventByIndex on IsarCollection<Event> {
  Future<Event?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  Event? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<Event?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<Event?> getAllByUidSync(List<String> uidValues) {
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

  Future<Id> putByUid(Event object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(Event object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<Event> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<Event> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension EventQueryWhereSort on QueryBuilder<Event, Event, QWhere> {
  QueryBuilder<Event, Event, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Event, Event, QAfterWhere> anyEffectiveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'effectiveDate'),
      );
    });
  }
}

extension EventQueryWhere on QueryBuilder<Event, Event, QWhereClause> {
  QueryBuilder<Event, Event, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<Event, Event, QAfterWhereClause> isarIdGreaterThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> isarIdLessThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<Event, Event, QAfterWhereClause> uidEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> uidNotEqualTo(String uid) {
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

  QueryBuilder<Event, Event, QAfterWhereClause>
      trackerUidEqualToAnyEffectiveDate(String trackerUid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackerUid_effectiveDate',
        value: [trackerUid],
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause>
      trackerUidNotEqualToAnyEffectiveDate(String trackerUid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackerUid_effectiveDate',
              lower: [],
              upper: [trackerUid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackerUid_effectiveDate',
              lower: [trackerUid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackerUid_effectiveDate',
              lower: [trackerUid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackerUid_effectiveDate',
              lower: [],
              upper: [trackerUid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> trackerUidEffectiveDateEqualTo(
      String trackerUid, DateTime effectiveDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'trackerUid_effectiveDate',
        value: [trackerUid, effectiveDate],
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause>
      trackerUidEqualToEffectiveDateNotEqualTo(
          String trackerUid, DateTime effectiveDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackerUid_effectiveDate',
              lower: [trackerUid],
              upper: [trackerUid, effectiveDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackerUid_effectiveDate',
              lower: [trackerUid, effectiveDate],
              includeLower: false,
              upper: [trackerUid],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackerUid_effectiveDate',
              lower: [trackerUid, effectiveDate],
              includeLower: false,
              upper: [trackerUid],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'trackerUid_effectiveDate',
              lower: [trackerUid],
              upper: [trackerUid, effectiveDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause>
      trackerUidEqualToEffectiveDateGreaterThan(
    String trackerUid,
    DateTime effectiveDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'trackerUid_effectiveDate',
        lower: [trackerUid, effectiveDate],
        includeLower: include,
        upper: [trackerUid],
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause>
      trackerUidEqualToEffectiveDateLessThan(
    String trackerUid,
    DateTime effectiveDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'trackerUid_effectiveDate',
        lower: [trackerUid],
        upper: [trackerUid, effectiveDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause>
      trackerUidEqualToEffectiveDateBetween(
    String trackerUid,
    DateTime lowerEffectiveDate,
    DateTime upperEffectiveDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'trackerUid_effectiveDate',
        lower: [trackerUid, lowerEffectiveDate],
        includeLower: includeLower,
        upper: [trackerUid, upperEffectiveDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> effectiveDateEqualTo(
      DateTime effectiveDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'effectiveDate',
        value: [effectiveDate],
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> effectiveDateNotEqualTo(
      DateTime effectiveDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'effectiveDate',
              lower: [],
              upper: [effectiveDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'effectiveDate',
              lower: [effectiveDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'effectiveDate',
              lower: [effectiveDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'effectiveDate',
              lower: [],
              upper: [effectiveDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> effectiveDateGreaterThan(
    DateTime effectiveDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'effectiveDate',
        lower: [effectiveDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> effectiveDateLessThan(
    DateTime effectiveDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'effectiveDate',
        lower: [],
        upper: [effectiveDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterWhereClause> effectiveDateBetween(
    DateTime lowerEffectiveDate,
    DateTime upperEffectiveDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'effectiveDate',
        lower: [lowerEffectiveDate],
        includeLower: includeLower,
        upper: [upperEffectiveDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EventQueryFilter on QueryBuilder<Event, Event, QFilterCondition> {
  QueryBuilder<Event, Event, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'effectiveTime',
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'effectiveTime',
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> effectiveTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> isBackfillEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBackfill',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> metricsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metrics',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> metricsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metrics',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> metricsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metrics',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> metricsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metrics',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> metricsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metrics',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> metricsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metrics',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackerUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'trackerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'trackerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trackerUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trackerUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackerUid',
        value: '',
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackerUid',
        value: '',
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerVersionEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackerVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackerVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackerVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> trackerVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackerVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> uidEqualTo(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> uidGreaterThan(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> uidLessThan(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> uidBetween(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> uidStartsWith(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> uidEndsWith(
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

  QueryBuilder<Event, Event, QAfterFilterCondition> uidContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> uidMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Event, Event, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EventQueryObject on QueryBuilder<Event, Event, QFilterCondition> {
  QueryBuilder<Event, Event, QAfterFilterCondition> metricsElement(
      FilterQuery<MetricValue> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'metrics');
    });
  }
}

extension EventQueryLinks on QueryBuilder<Event, Event, QFilterCondition> {}

extension EventQuerySortBy on QueryBuilder<Event, Event, QSortBy> {
  QueryBuilder<Event, Event, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByEffectiveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDate', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByEffectiveDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDate', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByEffectiveTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveTime', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByEffectiveTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveTime', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByIsBackfill() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBackfill', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByIsBackfillDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBackfill', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByTrackerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackerUid', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByTrackerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackerUid', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByTrackerVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackerVersion', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByTrackerVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackerVersion', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EventQuerySortThenBy on QueryBuilder<Event, Event, QSortThenBy> {
  QueryBuilder<Event, Event, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByEffectiveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDate', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByEffectiveDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDate', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByEffectiveTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveTime', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByEffectiveTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveTime', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByIsBackfill() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBackfill', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByIsBackfillDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBackfill', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByTrackerUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackerUid', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByTrackerUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackerUid', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByTrackerVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackerVersion', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByTrackerVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackerVersion', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Event, Event, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EventQueryWhereDistinct on QueryBuilder<Event, Event, QDistinct> {
  QueryBuilder<Event, Event, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Event, Event, QDistinct> distinctByEffectiveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveDate');
    });
  }

  QueryBuilder<Event, Event, QDistinct> distinctByEffectiveTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveTime');
    });
  }

  QueryBuilder<Event, Event, QDistinct> distinctByIsBackfill() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBackfill');
    });
  }

  QueryBuilder<Event, Event, QDistinct> distinctByTrackerUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackerUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Event, Event, QDistinct> distinctByTrackerVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackerVersion');
    });
  }

  QueryBuilder<Event, Event, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Event, Event, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension EventQueryProperty on QueryBuilder<Event, Event, QQueryProperty> {
  QueryBuilder<Event, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<Event, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Event, DateTime, QQueryOperations> effectiveDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveDate');
    });
  }

  QueryBuilder<Event, DateTime?, QQueryOperations> effectiveTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveTime');
    });
  }

  QueryBuilder<Event, bool, QQueryOperations> isBackfillProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBackfill');
    });
  }

  QueryBuilder<Event, List<MetricValue>, QQueryOperations> metricsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metrics');
    });
  }

  QueryBuilder<Event, String, QQueryOperations> trackerUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackerUid');
    });
  }

  QueryBuilder<Event, int, QQueryOperations> trackerVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackerVersion');
    });
  }

  QueryBuilder<Event, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<Event, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
