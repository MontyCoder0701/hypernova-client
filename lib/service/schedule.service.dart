import '../core/http.core.dart';
import '../model/schedule.model.dart';

class ScheduleService {
  static final HttpClient _http = HttpClient();
  static final path = '/schedules';

  static Future<List<Schedule>> fetchSchedules() async {
    final response = await _http.get(path);
    final data = response.data;
    return List<Schedule>.from(data.map((e) => Schedule.fromJson(e)));
  }

  static Future<void> createSchedule(
    DateTime selectedTime,
    Set<int> selectedWeekdays,
  ) async {
    List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    await _http.post(
      path,
      data: {
        'time': selectedTime.toIso8601String().substring(11, 19),
        'start_date': DateTime.now().toIso8601String().substring(0, 10),
        'days': selectedWeekdays.map((i) => weekdays[i]).toList(),
      },
    );
  }

  static Future<void> updateSchedule(
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

    final dayName = ['일', '월', '화', '수', '목', '금', '토'][day.weekday % 7];
    final formattedTime =
        '${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}:00';

    await _http.post(
      path,
      data: {
        'time': formattedTime,
        'start_date': newDateTime.toIso8601String().substring(0, 10),
        'end_date': newDateTime.toIso8601String().substring(0, 10),
        'days': [dayName],
      },
    );
  }

  static Future<void> editSchedule(
    int scheduleId,
    DateTime selectedTime,
    Set<int> selectedWeekdays,
  ) async {
    List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    await _http.patch(
      '$path/$scheduleId',
      data: {'end_date': DateTime.now().toIso8601String().substring(0, 10)},
    );

    await _http.post(
      path,
      data: {
        'time': selectedTime.toIso8601String().substring(11, 19),
        'start_date': DateTime.now().toIso8601String().substring(0, 10),
        'days': selectedWeekdays.map((i) => weekdays[i]).toList(),
      },
    );
  }

  static Future<void> deleteSchedule(int scheduleId) async {
    await _http.delete('$path/$scheduleId');
  }

  static Future<void> createExclusion(
    int scheduleId,
    DateTime exclusionDateTime,
  ) async {
    await _http.post(
      '$path/$scheduleId/exclude',
      data: {'datetime': exclusionDateTime.toIso8601String()},
    );
  }
}
