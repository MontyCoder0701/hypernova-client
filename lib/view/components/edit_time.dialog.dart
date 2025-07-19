import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/schedule.model.dart';

class EditTimeDialog extends StatefulWidget {
  final DateTime day;
  final Schedule schedule;
  final Future<void> Function(Schedule schedule, DateTime newDateTime) onSave;

  const EditTimeDialog({
    super.key,
    required this.schedule,
    required this.day,
    required this.onSave,
  });

  @override
  State<EditTimeDialog> createState() => _EditTimeDialogState();
}

class _EditTimeDialogState extends State<EditTimeDialog> {
  bool isEditTriggered = false;
  late DateTime selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = DateTime(
      widget.day.year,
      widget.day.month,
      widget.day.day,
      widget.schedule.time.hour,
      widget.schedule.time.minute,
    );
  }

  Future<void> _handleOnSave() async {
    Navigator.pop(context, selectedTime);
    await widget.onSave(widget.schedule, selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selectedTime,
                use24hFormat: false,
                onDateTimeChanged: (DateTime newTime) {
                  setState(() {
                    isEditTriggered = true;
                    selectedTime = DateTime(
                      widget.day.year,
                      widget.day.month,
                      widget.day.day,
                      newTime.hour,
                      newTime.minute,
                    );
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: isEditTriggered ? () => _handleOnSave() : null,
                  child: const Text('저장'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
