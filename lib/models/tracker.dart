import 'package:isar/isar.dart';

import 'input_field_schema.dart';

part 'tracker.g.dart';

@Collection()
class Tracker {
  Tracker();

  factory Tracker.fromJson(Map<String, dynamic> json) {
    return Tracker()
      ..uid = json['uid'] as String
      ..domainUid = json['domainUid'] as String
      ..name = json['name'] as String
      ..icon = json['icon'] as String
      ..frequency = json['frequency'] as String
      ..promptTimes = List<String>.from(json['promptTimes'] as List? ?? const [])
      ..inputSchema = (json['inputSchema'] as List? ?? const [])
          .map((item) => InputFieldSchema.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList()
      ..allowedVisualizations = List<String>.from(
        json['allowedVisualizations'] as List? ?? const [],
      )
      ..scoreContribution = json['scoreContribution'] as bool? ?? false
      ..scoreKey = json['scoreKey'] as String?
      ..scoreMin = json['scoreMin'] as int? ?? 0
      ..scoreMax = json['scoreMax'] as int? ?? 0
      ..countsForCompletion = json['countsForCompletion'] as bool? ?? false
      ..heatmapMode = json['heatmapMode'] as String? ?? 'excluded'
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..isActive = json['isActive'] as bool? ?? true
      ..version = json['version'] as int? ?? 1
      ..createdAt = DateTime.now();
  }

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;
  @Index()
  late String domainUid;
  late String name;
  late String icon;
  late String frequency;
  late List<String> promptTimes;
  late List<InputFieldSchema> inputSchema;
  late List<String> allowedVisualizations;
  late bool scoreContribution;
  String? scoreKey;
  late int scoreMin;
  late int scoreMax;
  late bool countsForCompletion;
  late String heatmapMode;
  late int sortOrder;
  late bool isActive;
  late int version;
  late DateTime createdAt;

  List<InputFieldSchema> get sortedInputSchema {
    final fields = List<InputFieldSchema>.from(inputSchema);
    fields.sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return fields;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'domainUid': domainUid,
      'name': name,
      'icon': icon,
      'frequency': frequency,
      'promptTimes': promptTimes,
      'inputSchema': inputSchema.map((field) => field.toJson()).toList(),
      'allowedVisualizations': allowedVisualizations,
      'scoreContribution': scoreContribution,
      'scoreKey': scoreKey,
      'scoreMin': scoreMin,
      'scoreMax': scoreMax,
      'countsForCompletion': countsForCompletion,
      'heatmapMode': heatmapMode,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

