import 'package:flutter/material.dart';

DateTime normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime mergeDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String hhMm(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

TimeOfDay parseHhMm(String value) {
  final parts = value.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

DateTime firstDayOfMonth(DateTime value) {
  return DateTime(value.year, value.month);
}

DateTime addMonths(DateTime value, int delta) {
  return DateTime(value.year, value.month + delta, 1);
}

Iterable<DateTime> enumerateDays(DateTime start, DateTime endInclusive) sync* {
  var current = normalizeDate(start);
  final end = normalizeDate(endInclusive);
  while (!current.isAfter(end)) {
    yield current;
    current = current.add(const Duration(days: 1));
  }
}

bool isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}
