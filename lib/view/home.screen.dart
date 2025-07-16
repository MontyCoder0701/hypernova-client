import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/schedule.model.dart';
import '../service/auth.service.dart';
import '../service/schedule.service.dart';
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
    final weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];
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
      body: FutureBuilder<List<Schedule>>(
        future: ScheduleService.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          final schedules = snapshot.data ?? [];

          return ListView.separated(
            itemCount: days.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final day = days[index];

              final isToday =
                  day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;

              final matchedSchedules = schedules.where((s) {
                final startDate = DateTime(
                  s.startDate.year,
                  s.startDate.month,
                  s.startDate.day,
                );

                final endDate = s.endDate != null
                    ? DateTime(
                        s.endDate!.year,
                        s.endDate!.month,
                        s.endDate!.day,
                      )
                    : null;

                final dayOnly = DateTime(day.year, day.month, day.day);
                final dayName = weekdayNames[day.weekday % 7];
                final scheduleDateTime = DateTime(
                  day.year,
                  day.month,
                  day.day,
                  s.time.hour,
                  s.time.minute,
                );

                final isInRange =
                    (dayOnly.isAtSameMomentAs(startDate) ||
                        dayOnly.isAfter(startDate)) &&
                    (endDate == null ||
                        dayOnly.isAtSameMomentAs(endDate) ||
                        dayOnly.isBefore(endDate));

                final isScheduledDay = s.days.contains(dayName);
                final isNotExcluded = s.isActiveAt(scheduleDateTime);
                return isInRange && isScheduledDay && isNotExcluded;
              }).toList();

              return ListTile(
                tileColor: isToday ? Colors.black : null,
                leading: SizedBox(
                  width: 40,
                  child: Text(
                    '${isToday ? "오늘" : weekdayNames[day.weekday % 7]}\n${day.day}',
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
                          if (value == 'edit') {
                            final schedule = matchedSchedules.first;
                            showDialog(
                              context: context,
                              builder: (context) => EditTimeDialog(
                                day: day,
                                schedule: schedule,
                                onSave: (schedule, day, datetime) async {
                                  return await ScheduleService.updateOne(
                                    schedule,
                                    day,
                                    datetime,
                                  );
                                },
                              ),
                            );
                          } else if (value == 'rest') {
                            final schedule = matchedSchedules.first;
                            final exclusionDateTime = DateTime(
                              day.year,
                              day.month,
                              day.day,
                              schedule.time.hour,
                              schedule.time.minute,
                            );

                            await ScheduleService.createOneExclusion(
                              schedule.id,
                              exclusionDateTime,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('수정하기'),
                          ),
                          const PopupMenuItem<String>(
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
