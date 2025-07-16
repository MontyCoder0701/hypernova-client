import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../model/schedule.model.dart';

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

  Future<void> _updateSchedule() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    await http.patch(
      Uri.parse('http://localhost:8000/schedules/${widget.schedule.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'end_date': DateTime.now().toIso8601String().substring(0, 10),
      }),
    );

    await http.post(
      Uri.parse('http://localhost:8000/schedules'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'time': selectedTime.toIso8601String().substring(11, 19),
        'start_date': DateTime.now().toIso8601String().substring(0, 10),
        'days': selectedWeekdays.map((i) => weekdays[i]).toList(),
      }),
    );
  }

  Future<void> _deleteSchedule() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    await http.delete(
      Uri.parse('http://localhost:8000/schedules/${widget.schedule.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

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
                      await _deleteSchedule();
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
                    // TODO: save edit
                    await _updateSchedule();
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
