import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/controller/schedule.controller.dart';
import '/model/weekday.enum.dart';

class AddScheduleBottomSheet extends StatefulWidget {
  const AddScheduleBottomSheet({super.key});

  @override
  State<AddScheduleBottomSheet> createState() => _AddScheduleBottomSheetState();
}

class _AddScheduleBottomSheetState extends State<AddScheduleBottomSheet> {
  final scheduleController = Get.find<ScheduleController>();

  bool isEditTriggered = false;
  DateTime selectedTime = DateTime.now().add(const Duration(minutes: 1));
  final List<String> weekdays = WeekdayExtension.labels;
  final Set<int> selectedWeekdaysIndex = {};

  void _handleOnChipSelected(bool value, int index) {
    setState(() {
      isEditTriggered = true;
      if (value) {
        selectedWeekdaysIndex.add(index);
      } else {
        selectedWeekdaysIndex.remove(index);
      }
    });
  }

  Future<void> _handleOnSave() async {
    await scheduleController.createOne(
      selectedTime,
      selectedWeekdaysIndex.toList(),
    );
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.85,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceDim,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    '전화 추가',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedTime,
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      selectedTime = newTime;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '반복',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: List.generate(weekdays.length, (index) {
                  final selected = selectedWeekdaysIndex.contains(index);
                  return ChoiceChip(
                    label: Text(weekdays[index]),
                    selected: selected,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                    onSelected:
                        scheduleController.isWeekdayValid(
                          WeekdayExtension.fromIndex(index),
                        )
                        ? (value) => _handleOnChipSelected(value, index)
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: isEditTriggered ? () => _handleOnSave() : null,
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
