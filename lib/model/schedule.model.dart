import 'package:flutter/material.dart';

import 'weekday.enum.dart';

class Schedule {
  final int id;
  final TimeOfDay time;
  final DateTime startDate;
  final DateTime? endDate;
  final List<Weekday> days;
  final List<DateTime> exclusions;

  Schedule({
    required this.id,
    required this.time,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.exclusions,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    final timeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return Schedule(
      id: json['id'],
      time: timeOfDay,
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      days: (json['days'] as List)
          .map((e) => WeekdayExtension.fromIndex(int.parse(e['day'])))
          .toList(),
      exclusions: (json['exclusions'] as List)
          .map((e) => DateTime.parse(e['datetime']))
          .toList(),
    );
  }

  bool get isVisible => endDate == null;

  bool isActiveAt(DateTime dt) {
    return !exclusions.any(
      (ex) =>
          ex.year == dt.year &&
          ex.month == dt.month &&
          ex.day == dt.day &&
          ex.hour == time.hour &&
          ex.minute == time.minute,
    );
  }
}
