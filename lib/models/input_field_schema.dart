import 'dart:convert';

import 'package:isar/isar.dart';

part 'input_field_schema.g.dart';

@Embedded()
class InputFieldSchema {
  InputFieldSchema();

  factory InputFieldSchema.fromJson(Map<String, dynamic> json) {
    return InputFieldSchema()
      ..key = json['key'] as String
      ..label = json['label'] as String
      ..type = json['type'] as String
      ..configJson = json['configJson'] as String?
      ..isRequired = json['isRequired'] as bool? ?? false
      ..sortOrder = json['sortOrder'] as int? ?? 0;
  }

  late String key;
  late String label;
  late String type;
  String? configJson;
  late bool isRequired;
  late int sortOrder;

  @ignore
  Map<String, dynamic> get config {
    if (configJson == null || configJson!.trim().isEmpty) {
      return const <String, dynamic>{};
    }
    return Map<String, dynamic>.from(jsonDecode(configJson!) as Map);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'label': label,
      'type': type,
      'configJson': configJson,
      'isRequired': isRequired,
      'sortOrder': sortOrder,
    };
  }
}
