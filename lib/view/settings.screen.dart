import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/schedule.controller.dart';
import '../model/weekday.enum.dart';
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
        child: GetBuilder<ScheduleController>(
          builder: (controller) {
            final schedules = controller.visibleResources;
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
