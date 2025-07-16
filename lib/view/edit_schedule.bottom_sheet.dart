import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/schedule.model.dart';
import '../service/schedule.service.dart';

class EditScheduleBottomSheet extends StatefulWidget {
  final Schedule schedule;

  const EditScheduleBottomSheet({super.key, required this.schedule});

  @override
  State<EditScheduleBottomSheet> createState() =>
      _EditScheduleBottomSheetState();
}

class _EditScheduleBottomSheetState extends State<EditScheduleBottomSheet> {
  late DateTime selectedTime;
  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  late Set<int> selectedWeekdays;

  @override
  void initState() {
    super.initState();

    selectedTime = DateTime(
      2025,
      1,
      1,
      widget.schedule.time.hour,
      widget.schedule.time.minute,
    );

    selectedWeekdays = widget.schedule.days
        .map((day) => weekdays.indexOf(day))
        .where((index) => index != -1)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.8,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
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
                  const Text('전화 편집'),
                  TextButton(
                    onPressed: () async {
                      await ScheduleService.deleteSchedule(widget.schedule.id);
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: Text('삭제'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
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
              const Text('반복'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: List.generate(weekdays.length, (index) {
                  final selected = selectedWeekdays.contains(index);
                  return ChoiceChip(
                    label: Text(weekdays[index]),
                    selected: selected,
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (bool value) {
                      setState(() {
                        if (value) {
                          selectedWeekdays.add(index);
                        } else {
                          selectedWeekdays.remove(index);
                        }
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () async {
                    await ScheduleService.editSchedule(
                      widget.schedule.id,
                      selectedTime,
                      selectedWeekdays,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
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
