import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('전화', style: TextStyle(color: Colors.black)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('언제 전화할까요?'),
            SizedBox(height: 8),
            Text('아래 추가 버튼을 누르고\n전화 시간을 설정해주세요'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddCallBottomSheet(),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddCallBottomSheet extends StatefulWidget {
  const AddCallBottomSheet({super.key});

  @override
  State<AddCallBottomSheet> createState() => _AddCallBottomSheetState();
}

class _AddCallBottomSheetState extends State<AddCallBottomSheet> {
  DateTime selectedTime = DateTime(2025, 1, 1, 11, 30);
  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final Set<int> selectedWeekdays = {0};

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
                  const Text('전화추가'),
                  const SizedBox(width: 48),
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
                  onPressed: () {
                    // TODO: Save
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
