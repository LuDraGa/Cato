import 'package:isar/isar.dart';

part 'metric_value.g.dart';

@Embedded()
class MetricValue {
  MetricValue();

  factory MetricValue.copyOf(MetricValue other) {
    return MetricValue()
      ..inputKey = other.inputKey
      ..intValue = other.intValue
      ..doubleValue = other.doubleValue
      ..stringValue = other.stringValue
      ..listValue = other.listValue == null
          ? null
          : List<String>.from(other.listValue!)
      ..boolValue = other.boolValue
      ..mediaPath = other.mediaPath;
  }

  late String inputKey;
  int? intValue;
  double? doubleValue;
  String? stringValue;
  List<String>? listValue;
  bool? boolValue;
  String? mediaPath;

  bool get hasValue =>
      intValue != null ||
      doubleValue != null ||
      (stringValue != null && stringValue!.isNotEmpty) ||
      (listValue != null && listValue!.isNotEmpty) ||
      boolValue != null ||
      (mediaPath != null && mediaPath!.isNotEmpty);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'inputKey': inputKey,
      'intValue': intValue,
      'doubleValue': doubleValue,
      'stringValue': stringValue,
      'listValue': listValue,
      'boolValue': boolValue,
      'mediaPath': mediaPath,
    };
  }
}

