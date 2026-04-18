import 'package:isar/isar.dart';

part 'domain.g.dart';

@Collection()
class Domain {
  Domain();

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain()
      ..uid = json['uid'] as String
      ..name = json['name'] as String
      ..icon = json['icon'] as String
      ..color = json['color'] as String
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..isActive = json['isActive'] as bool? ?? true;
  }

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;
  late String name;
  late String icon;
  late String color;
  late int sortOrder;
  late bool isActive;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'icon': icon,
      'color': color,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }
}

