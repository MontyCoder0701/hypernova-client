import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../model/schedule.model.dart';

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

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];
    final days = List.generate(14, (i) => today.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
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
                final startDate = DateTime.parse(s.startDate);
                final dayName = weekdayNames[day.weekday % 7];
                return !day.isBefore(startDate) && s.days.contains(dayName);
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
                      ? matchedSchedules.first.time
                            .split('.')
                            .first
                            .substring(0, 5)
                      : '등록된 일정 없음',
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.black,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
