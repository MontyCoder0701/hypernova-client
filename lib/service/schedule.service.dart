import '../core/http.core.dart';
import '../core/utils.dart';
import '../model/schedule.model.dart';

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
        'start_datetime': time.toString(),
        'days': days,
      },
    );
    final data = response.data;
    return Schedule.fromJson(data);
  }

  Future<void> deleteOne(int scheduleId) async {
    await _http.delete('$path/$scheduleId');
  }

  Future<void> replaceOne(int scheduleId, DateTime time, List<int> days) async {
    await _http.post(
      '$path/$scheduleId/replace',
      data: {'time': time.formattedTime, 'days': days},
    );
  }

  Future<Schedule> modifyOneTime(int scheduleId, DateTime newDateTime) async {
    final response = await _http.post(
      '$path/$scheduleId/modify-time',
      data: {'datetime': newDateTime.toString()},
    );
    final data = response.data;
    return Schedule.fromJson(data);
  }

  Future<Schedule> excludeOne(
    int scheduleId,
    DateTime exclusionDateTime,
  ) async {
    final response = await _http.post(
      '$path/$scheduleId/exclude',
      data: {'datetime': exclusionDateTime.toString()},
    );
    final data = response.data;
    return Schedule.fromJson(data);
  }
}
