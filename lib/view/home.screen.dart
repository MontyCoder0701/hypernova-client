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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.logout)),
                  const Text('2025년 6월'),
                  IconButton(
                    onPressed: () {
                      context.push('/settings');
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isToday =
                      day.year == today.year &&
                      day.month == today.month &&
                      day.day == today.day;

                  if (isToday) {
                    return Container(
                      color: Colors.black,
                      child: ListTile(
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
                      ),
                    );
                  }
                  return Column(
                    children: [
                      ListTile(
                        leading: SizedBox(
                          width: 40,
                          child: Text(
                            '${weekdayNames[day.weekday % 7]}\n${day.day}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
