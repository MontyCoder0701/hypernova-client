import 'package:flutter/material.dart';

import '../model/schedule.model.dart';
import '../model/weekday.enum.dart';
import '../service/schedule.service.dart';
import 'add_schedule.bottom_sheet.dart';
import 'edit_schedule.bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('전화')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: FutureBuilder<List<Schedule>>(
          future: ScheduleService.getAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('에러 발생: ${snapshot.error}'));
            }

            final schedules = (snapshot.data ?? [])
                .where((s) => s.isVisible)
                .toList();

            return ListView.separated(
              itemCount: schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                final time = schedule.time.format(context);

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(schedule.days.map((d) => d.label).join(',')),
                    subtitle: Text(time),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            EditScheduleBottomSheet(schedule: schedule),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddScheduleBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
