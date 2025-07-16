import '../core/http.core.dart';
import '../model/schedule.model.dart';
import '../model/weekday.enum.dart';

class ScheduleService {
  static final HttpClient _http = HttpClient();
  static final path = '/schedules';

  static Future<List<Schedule>> getAll() async {
    final response = await _http.get(path);
    final data = response.data;
    return List<Schedule>.from(data.map((e) => Schedule.fromJson(e)));
  }

  static Future<void> createOne(DateTime time, List<int> days) async {
    await _http.post(
      path,
      data: {
        'time': time.toIso8601String().substring(11, 19),
        'start_date': DateTime.now().toIso8601String().substring(0, 10),
        'days': days,
      },
    );
  }

  static Future<void> updateOne(
    Schedule schedule,
    DateTime day,
    DateTime newDateTime,
  ) async {
    final excludedDateTime = DateTime(
      day.year,
      day.month,
      day.day,
      schedule.time.hour,
      schedule.time.minute,
    );

    await _http.post(
      '$path/${schedule.id}/exclude',
      data: {'datetime': excludedDateTime.toIso8601String()},
    );

    final weekdayIndex = WeekdayExtension.fromDateTime(day).indexValue;
    await _http.post(
      path,
      data: {
        'time': newDateTime.toIso8601String().substring(11, 19),
        'start_date': newDateTime.toIso8601String().substring(0, 10),
        'end_date': newDateTime.toIso8601String().substring(0, 10),
        'days': [weekdayIndex],
      },
    );
  }

  static Future<void> editOne(
    int scheduleId,
    DateTime time,
    List<int> days,
  ) async {
    await _http.patch(
      '$path/$scheduleId',
      data: {'end_date': DateTime.now().toIso8601String().substring(0, 10)},
    );

    await _http.post(
      path,
      data: {
        'time': time.toIso8601String().substring(11, 19),
        'start_date': DateTime.now().toIso8601String().substring(0, 10),
        'days': days,
      },
    );
  }

  static Future<void> deleteOne(int scheduleId) async {
    await _http.delete('$path/$scheduleId');
  }

  static Future<void> createOneExclusion(
    int scheduleId,
    DateTime exclusionDateTime,
  ) async {
    await _http.post(
      '$path/$scheduleId/exclude',
      data: {'datetime': exclusionDateTime.toIso8601String()},
    );
  }
}
