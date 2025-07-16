import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../model/schedule.model.dart';
import 'edit_time.dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // TODO: move to separate layer
  Future<List<Schedule>> _fetchSchedules() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('http://localhost:8000/schedules'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Schedule>.from(data.map((e) => Schedule.fromJson(e)));
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  Future<void> _addExclusion(int scheduleId, DateTime exclusionDateTime) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    await http.post(
      Uri.parse('http://localhost:8000/schedules/$scheduleId/exclude'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'datetime': exclusionDateTime.toIso8601String()}),
    );
  }

  Future<void> _handleEditTime(
    Schedule schedule,
    DateTime day,
    DateTime newDateTime,
  ) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    final excludedDateTime = DateTime(
      day.year,
      day.month,
      day.day,
      schedule.time.hour,
      schedule.time.minute,
    );

    await http.post(
      Uri.parse('http://localhost:8000/schedules/${schedule.id}/exclude'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'datetime': excludedDateTime.toIso8601String()}),
    );

    final dayName = ['일', '월', '화', '수', '목', '금', '토'][day.weekday % 7];
    final formattedTime =
        '${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}:00';

    await http.post(
      Uri.parse('http://localhost:8000/schedules'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'time': formattedTime,
        'start_date': newDateTime.toIso8601String().substring(0, 10),
        'end_date': newDateTime.toIso8601String().substring(0, 10),
        'days': [dayName],
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];
    final startDay = today.subtract(const Duration(days: 7));
    final days = List.generate(21, (i) => startDay.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final storage = FlutterSecureStorage();
            await storage.delete(key: 'access_token');
            if (!context.mounted) {
              return;
            }
            context.go('/login');
          },
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
        future: _fetchSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          final schedules = snapshot.data ?? [];

          return ListView.separated(
            itemCount: days.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
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
                                onSave: _handleEditTime,
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

                            await _addExclusion(schedule.id, exclusionDateTime);
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
