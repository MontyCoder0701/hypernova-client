import 'package:get/get.dart';

import '../model/schedule.model.dart';
import '../model/weekday.enum.dart';
import '../service/schedule.service.dart';

class ScheduleController extends GetxController {
  final List<Schedule> _resources = [];
  final service = ScheduleService();

  static ScheduleController get to => Get.find();

  List<Schedule> get resources => _resources;

  List<Schedule> get visibleResources =>
      _resources.where((e) => e.isVisible).toList();

  bool isWeekdayValid(Weekday weekday) {
    return !visibleResources.any((e) => e.days.contains(weekday));
  }

  Future<void> getAll() async {
    final fetchedResources = await service.getAll();
    _resources.clear();
    _resources.addAll(fetchedResources);
    update();
  }

  Future<void> createOne(DateTime time, List<int> days) async {
    final createdResource = await service.createOne(time, days);
    _resources.add(createdResource);
    update();
  }

  Future<void> updateOne(int scheduleId, DateTime time, List<int> days) async {
    await service.updateOne(scheduleId, time, days);
    getAll();
  }

  Future<void> deleteOne(int scheduleId) async {
    await service.deleteOne(scheduleId);
    getAll();
  }

  Future<void> excludeOne(int scheduleId, DateTime exclusionDateTime) async {
    final updatedResource = await service.excludeOne(
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

  Future<void> updateOneTime(
    Schedule schedule,
    DateTime day,
    DateTime newDateTime,
  ) async {
    await service.updateOneTime(schedule, day, newDateTime);
    getAll();
  }
}
