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
    final List<String> weekdays = WeekdayExtension.labels;
    final today = DateUtils.dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 7));
    final days = List.generate(21, (i) => start.add(Duration(days: i)));

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
        builder: (controller) {
          final schedules = controller.resources;

          return ListView.separated(
            itemCount: days.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final day = days[index];
              final isToday = DateUtils.isSameDay(day, today);
              final matchedSchedules = schedules
                  .where((s) => s.matches(day))
                  .toList();

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
                      ? matchedSchedules.first
                            .getDisplayTime(day)
                            .format(context)
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
                                onSave: (schedule, datetime) async {
                                  return await Get.find<ScheduleController>()
                                      .modifyOneTime(schedule.id, datetime);
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
