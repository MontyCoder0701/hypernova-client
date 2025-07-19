import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/schedule.controller.dart';
import '../model/weekday.enum.dart';
import 'components/add_schedule.bottom_sheet.dart';
import 'components/edit_schedule.bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      appBar: AppBar(
        title: const Text('전화'),
        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GetBuilder<ScheduleController>(
          builder: (controller) {
            final schedules = controller.visibleResources;

            if (schedules.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    SizedBox(height: 200),
                    Text(
                      '언제 전화할까요?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '아래 추가 버튼을 누르고 \n 전화 시간을 설정해주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: schedules.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  final time = schedule.time.format(context);
                  final daysText = schedule.days.map((d) => d.label).join(',');

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(daysText),
                    subtitle: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
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
                  );
                },
              ),
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
        child: const Icon(Icons.add, size: 36),
      ),
    );
  }
}
