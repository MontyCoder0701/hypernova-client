import 'package:flutter/material.dart';

import '../../controller/schedule.controller.dart';
import '../../model/schedule.model.dart';
import 'edit_time.dialog.dart';

class ScheduleOptionMenuButton extends StatefulWidget {
  final bool isToday;
  final DateTime day;
  final Schedule schedule;
  final ScheduleController controller;

  const ScheduleOptionMenuButton({
    super.key,
    required this.isToday,
    required this.day,
    required this.schedule,
    required this.controller,
  });

  @override
  State<ScheduleOptionMenuButton> createState() =>
      _ScheduleOptionMenuButtonState();
}

class _ScheduleOptionMenuButtonState extends State<ScheduleOptionMenuButton> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: const Offset(-20, 0),
      style: MenuStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(2),
      ),
      menuChildren: [
        _buildMenuItem(
          text: '수정하기',
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (context) => EditTimeDialog(
                day: widget.day,
                schedule: widget.schedule,
                onSave: (schedule, datetime) async {
                  return await widget.controller.modifyOneTime(
                    schedule.id,
                    datetime,
                  );
                },
              ),
            );

            if (result != null && context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar());
            }
          },
        ),
        Divider(height: 1, color: Theme.of(context).colorScheme.outline),
        _buildMenuItem(
          text: '쉬어가기',
          onPressed: () async {
            final exclusionDateTime = DateTime(
              widget.day.year,
              widget.day.month,
              widget.day.day,
              widget.schedule.time.hour,
              widget.schedule.time.minute,
            );
            await widget.controller.excludeOne(
              widget.schedule.id,
              exclusionDateTime,
            );
          },
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          onPressed: () => _menuController.open(),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }

  SnackBar _buildSnackBar() {
    return SnackBar(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.black),
          const SizedBox(width: 8),
          Text('전화 시간이 수정 되었어요.', style: TextStyle(color: Colors.black)),
        ],
      ),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 160,
        left: 16,
        right: 16,
      ),
    );
  }
}
