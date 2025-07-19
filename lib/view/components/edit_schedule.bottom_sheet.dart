import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/schedule.controller.dart';
import '../../model/schedule.model.dart';
import '../../model/weekday.enum.dart';

class EditScheduleBottomSheet extends StatefulWidget {
  final Schedule schedule;

  const EditScheduleBottomSheet({super.key, required this.schedule});

  @override
  State<EditScheduleBottomSheet> createState() =>
      _EditScheduleBottomSheetState();
}

class _EditScheduleBottomSheetState extends State<EditScheduleBottomSheet> {
  final scheduleController = Get.find<ScheduleController>();

  bool isEditTriggered = false;
  late DateTime selectedTime;
  late Set<int> selectedWeekdaysIndex;
  final List<String> weekdays = WeekdayExtension.labels;

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
    await Get.find<ScheduleController>().replaceOne(
      widget.schedule.id,
      selectedTime,
      selectedWeekdaysIndex.toList(),
    );
    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    selectedTime = DateTime.now().copyWith(
      hour: widget.schedule.time.hour,
      minute: widget.schedule.time.minute,
    );
    selectedWeekdaysIndex = widget.schedule.days.map((e) => e.index).toSet();
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
                    '전화 편집',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Get.find<ScheduleController>().deleteOne(
                        widget.schedule.id,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: const Text('삭제'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: selectedTime,
                    use24hFormat: false,
                    onDateTimeChanged: (newTime) {
                      setState(() {
                        isEditTriggered = true;
                        selectedTime = newTime;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('반복'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: List.generate(weekdays.length, (index) {
                  final selected = selectedWeekdaysIndex.contains(index);
                  return ChoiceChip(
                    label: Text(weekdays[index]),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                    selected: selected,
                    onSelected:
                        scheduleController.isWeekdayValid(
                              WeekdayExtension.fromIndex(index),
                            ) ||
                            widget.schedule.days.contains(
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
