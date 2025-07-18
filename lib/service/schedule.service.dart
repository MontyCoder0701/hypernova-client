import '../core/http.core.dart';
import '../core/utils.dart';
import '../model/schedule.model.dart';
import '../model/weekday.enum.dart';

class ScheduleService {
  static final HttpClient _http = HttpClient();
  static final path = '/schedules';

  Future<List<Schedule>> getAll() async {
    final response = await _http.get(path);
    final data = response.data;
    return List<Schedule>.from(data.map((e) => Schedule.fromJson(e)));
  }

  Future<Schedule> createOne(DateTime time, List<int> days) async {
    final response = await _http.post(
      path,
      data: {
        'time': time.formattedTime,
        'start_date': DateTime.now().formattedDate,
        'days': days,
      },
    );
    final data = response.data;
    return Schedule.fromJson(data);
  }

  Future<void> updateOneTime(
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
        'time': newDateTime.formattedTime,
        'start_date': newDateTime.formattedDate,
        'end_date': newDateTime.formattedDate,
        'days': [weekdayIndex],
      },
    );
  }

  Future<void> updateOne(int scheduleId, DateTime time, List<int> days) async {
    await _http.patch(
      '$path/$scheduleId',
      data: {'end_date': DateTime.now().formattedTime},
    );

    await _http.post(
      path,
      data: {
        'time': time.formattedTime,
        'start_date': DateTime.now().formattedDate,
        'days': days,
      },
    );
  }

  Future<void> deleteOne(int scheduleId) async {
    await _http.delete('$path/$scheduleId');
  }

  Future<Schedule> excludeOne(
    int scheduleId,
    DateTime exclusionDateTime,
  ) async {
    final response = await _http.post(
      '$path/$scheduleId/exclude',
      data: {'datetime': exclusionDateTime.toIso8601String()},
    );
    final data = response.data;
    return Schedule.fromJson(data);
  }
}
