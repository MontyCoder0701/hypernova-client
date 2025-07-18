import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../controller/schedule.controller.dart';
import '../model/weekday.enum.dart';
import '../service/auth.service.dart';
import 'edit_time.dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final List<String> weekdays = WeekdayExtension.labels;
    final startDay = today.subtract(const Duration(days: 7));
    final days = List.generate(21, (i) => startDay.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _handleLogout(context),
        ),
        title: Text('${today.year}년 ${today.month}월'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: GetBuilder<ScheduleController>(
        initState: (_) => ScheduleController.to.getAll(),
        dispose: (_) => ScheduleController.to.dispose(),
        builder: (controller) {
          final schedules = controller.resources;
          return ListView.separated(
            itemCount: days.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final day = days[index];
              final isToday = DateUtils.isSameDay(day, today);

              final dayOnly = DateTime(day.year, day.month, day.day);
              final dayEnum = WeekdayExtension.fromDateTime(day);
              final matchedSchedules = schedules.where((s) {
                final start = DateUtils.dateOnly(s.startDate);
                final end = s.endDate != null
                    ? DateUtils.dateOnly(s.endDate!)
                    : null;
                final inRange =
                    dayOnly.isAfter(start.subtract(const Duration(days: 1))) &&
                    (end == null ||
                        dayOnly.isBefore(end.add(const Duration(days: 1))));
                final onDay = s.days.contains(dayEnum);
                final active = s.isActiveAt(
                  DateTime(
                    day.year,
                    day.month,
                    day.day,
                    s.time.hour,
                    s.time.minute,
                  ),
                );
                return inRange && onDay && active;
              }).toList();

              return ListTile(
                tileColor: isToday ? Colors.black : null,
                leading: SizedBox(
                  width: 40,
                  child: Text(
                    '${isToday ? "오늘" : weekdays[day.weekday - 1]}\n${day.day}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                title: Text(
                  matchedSchedules.isNotEmpty
                      ? matchedSchedules.first.time.format(context)
                      : '등록된 일정 없음',
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.black,
                  ),
                ),
                trailing: matchedSchedules.isNotEmpty
                    ? PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: isToday ? Colors.white : Colors.black,
                        ),
                        onSelected: (value) async {
                          final schedule = matchedSchedules.first;
                          if (value == 'edit') {
                            showDialog(
                              context: context,
                              builder: (context) => EditTimeDialog(
                                day: day,
                                schedule: schedule,
                                onSave: (schedule, day, datetime) async {
                                  return await Get.find<ScheduleController>()
                                      .updateOneTime(schedule, day, datetime);
                                },
                              ),
                            );
                          } else if (value == 'rest') {
                            final exclusionDateTime = DateTime(
                              day.year,
                              day.month,
                              day.day,
                              schedule.time.hour,
                              schedule.time.minute,
                            );

                            await controller.excludeOne(
                              schedule.id,
                              exclusionDateTime,
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('수정하기'),
                          ),
                          PopupMenuItem<String>(
                            value: 'rest',
                            child: Text('쉬어가기'),
                          ),
                        ],
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
