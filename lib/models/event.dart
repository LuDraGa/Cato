import 'package:isar/isar.dart';

import 'metric_value.dart';

part 'event.g.dart';

@Collection()
class Event {
  Event();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  @Index(composite: [CompositeIndex('effectiveDate')])
  late String trackerUid;

  @Index()
  late DateTime effectiveDate;
  DateTime? effectiveTime;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isBackfill;
  late int trackerVersion;
  late List<MetricValue> metrics;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'trackerUid': trackerUid,
      'effectiveDate': effectiveDate.toIso8601String(),
      'effectiveTime': effectiveTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isBackfill': isBackfill,
      'trackerVersion': trackerVersion,
      'metrics': metrics.map((metric) => metric.toJson()).toList(),
    };
  }
}

