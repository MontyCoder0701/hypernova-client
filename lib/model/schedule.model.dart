import 'package:flutter/material.dart';

import 'weekday.enum.dart';

class Schedule {
  final int _id;
  final TimeOfDay _time;
  final DateTime _startDatetime;
  final DateTime? _endDatetime;
  final List<Weekday> _days;
  final List<DateTime> _exclusions;
  final List<DateTime> _timeModifications;

  Schedule({
    required int id,
    required TimeOfDay time,
    required DateTime startDatetime,
    required DateTime? endDatetime,
    required List<Weekday> days,
    required List<DateTime> exclusions,
    required List<DateTime> timeModifications,
  }) : _id = id,
       _time = time,
       _startDatetime = startDatetime,
       _endDatetime = endDatetime,
       _days = days,
       _exclusions = exclusions,
       _timeModifications = timeModifications;

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    final timeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return Schedule(
      id: json['id'],
      time: timeOfDay,
      startDatetime: DateTime.parse(json['start_datetime']),
      endDatetime: json['end_datetime'] != null
          ? DateTime.parse(json['end_datetime'])
          : null,
      days: (json['days'] as List)
          .map((e) => WeekdayExtension.fromIndex(e['day']))
          .toList(),
      exclusions: (json['exclusions'] as List)
          .map((e) => DateTime.parse(e['datetime']))
          .toList(),
      timeModifications: (json['time_modifications'] as List)
          .map((e) => DateTime.parse(e['datetime']))
          .toList(),
    );
  }

  int get id => _id;

  TimeOfDay get time => _time;

  DateTime get startDatetime => _startDatetime;

  DateTime? get endDatetime => _endDatetime;

  List<Weekday> get days => List.unmodifiable(
    _days..sort((a, b) => a.indexValue.compareTo(b.indexValue)),
  );

  List<DateTime> get exclusions => List.unmodifiable(_exclusions);

  List<DateTime> get timeModifications => List.unmodifiable(_timeModifications);

  bool get isVisible => _endDatetime == null;

  bool isNotExcluded(DateTime dt) {
    return !_exclusions.any(
      (ex) =>
          ex.year == dt.year &&
          ex.month == dt.month &&
          ex.day == dt.day &&
          ex.hour == _time.hour &&
          ex.minute == _time.minute,
    );
  }

  bool matches(DateTime day) {
    final startDay = DateUtils.dateOnly(_startDatetime);
    final endDay = _endDatetime != null
        ? DateUtils.dateOnly(_endDatetime)
        : null;
    final weekday = WeekdayExtension.fromDateTime(day);

    final scheduledTime = DateTime(
      day.year,
      day.month,
      day.day,
      getDisplayTime(day).hour,
      getDisplayTime(day).minute,
    );

    final isInRange =
        !day.isBefore(startDay) && (endDay == null || !day.isAfter(endDay));
    final isScheduledDay = days.contains(weekday);
    final isActive = isNotExcluded(scheduledTime);
    return isInRange && isScheduledDay && isActive;
  }

  TimeOfDay getDisplayTime(DateTime day) {
    final modified = _timeModifications.firstWhere(
      (mod) =>
          mod.year == day.year && mod.month == day.month && mod.day == day.day,
      orElse: () => DateTime(0),
    );

    return modified.year == 0
        ? _time
        : TimeOfDay(hour: modified.hour, minute: modified.minute);
  }
}
