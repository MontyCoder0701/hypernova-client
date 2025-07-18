import 'package:get/get.dart';

import '../model/schedule.model.dart';
import '../model/weekday.enum.dart';
import '../service/schedule.service.dart';

class ScheduleController extends GetxController {
  final List<Schedule> _resources = [];
  final _service = ScheduleService();

  static ScheduleController get to => Get.find();

  List<Schedule> get resources => _resources;

  List<Schedule> get visibleResources =>
      _resources.where((e) => e.isVisible).toList();

  bool isWeekdayValid(Weekday weekday) {
    return !visibleResources.any((e) => e.days.contains(weekday));
  }

  Future<void> getAll() async {
    final fetchedResources = await _service.getAll();
    _resources.clear();
    _resources.addAll(fetchedResources);
    update();
  }

  Future<void> createOne(DateTime time, List<int> days) async {
    final createdResource = await _service.createOne(time, days);
    _resources.add(createdResource);
    update();
  }

  Future<void> deleteOne(int scheduleId) async {
    await _service.deleteOne(scheduleId);
    getAll();
  }

  Future<void> replaceOne(int scheduleId, DateTime time, List<int> days) async {
    await _service.replaceOne(scheduleId, time, days);
    getAll();
  }

  Future<void> excludeOne(int scheduleId, DateTime exclusionDateTime) async {
    final updatedResource = await _service.excludeOne(
      scheduleId,
      exclusionDateTime,
    );
    final index = _resources.indexWhere((e) => e.id == scheduleId);
    if (index < 0) {
      return;
    }
    _resources[index] = updatedResource;
    update();
  }

  Future<void> modifyOneTime(int scheduleId, DateTime newDateTime) async {
    final updatedResource = await _service.modifyOneTime(
      scheduleId,
      newDateTime,
    );
    final index = _resources.indexWhere((e) => e.id == scheduleId);
    if (index < 0) {
      return;
    }
    _resources[index] = updatedResource;
    update();
  }
}
