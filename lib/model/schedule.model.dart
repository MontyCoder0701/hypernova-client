import 'package:flutter/material.dart';

import 'weekday.enum.dart';

class Schedule {
  final int _id;
  final TimeOfDay _time;
  final DateTime _startDate;
  final DateTime? _endDate;
  final List<Weekday> _days;
  final List<DateTime> _exclusions;

  Schedule({
    required int id,
    required TimeOfDay time,
    required DateTime startDate,
    required DateTime? endDate,
    required List<Weekday> days,
    required List<DateTime> exclusions,
  }) : _id = id,
       _time = time,
       _startDate = startDate,
       _endDate = endDate,
       _days = days,
       _exclusions = exclusions;

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

  int get id => _id;

  TimeOfDay get time => _time;

  DateTime get startDate => _startDate;

  DateTime? get endDate => _endDate;

  List<Weekday> get days => List.unmodifiable(
    _days..sort((a, b) => a.indexValue.compareTo(b.indexValue)),
  );

  List<DateTime> get exclusions => List.unmodifiable(_exclusions);

  bool get isVisible => _endDate == null;

  bool isActiveAt(DateTime dt) {
    return !_exclusions.any(
      (ex) =>
          ex.year == dt.year &&
          ex.month == dt.month &&
          ex.day == dt.day &&
          ex.hour == _time.hour &&
          ex.minute == _time.minute,
    );
  }
}
