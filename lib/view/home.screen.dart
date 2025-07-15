import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime(2025, 6, 5);
    final weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];
    final days = List.generate(14, (index) => today.add(Duration(days: index)));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            // TODO: 로그아웃 및 세션 초기화
            context.go('/login');
          },
        ),
        title: const Text('2025년 6월'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: days.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
        itemBuilder: (context, index) {
          final day = days[index];
          final isToday =
              day.year == today.year &&
              day.month == today.month &&
              day.day == today.day;

          if (isToday) {
            return ListTile(
              tileColor: Colors.black,
              leading: const SizedBox(
                width: 40,
                child: Text(
                  '오늘\n5',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: const Text(
                '예정된 전화 없음',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListTile(
            leading: SizedBox(
              width: 40,
              child: Text(
                '${weekdayNames[day.weekday % 7]}\n${day.day}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
