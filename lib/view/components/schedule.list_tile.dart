import 'package:flutter/material.dart';

import '../../controller/schedule.controller.dart';
import '../../core/theme.core.dart';
import '../../model/schedule.model.dart';
import '../../view/components/schedule_option.menu_button.dart';

Widget buildScheduleTile({
  required BuildContext context,
  required DateTime today,
  required DateTime day,
  required List<String> weekdays,
  required List<Schedule> schedules,
}) {
  final isToday = DateUtils.isSameDay(day, today);
  final isBeforeToday = day.isBefore(today);
  final isAfterToday = day.isAfter(today);
  final matchedSchedules = schedules.where((s) => s.matches(day)).toList();
  final hasSchedule = matchedSchedules.isNotEmpty;

  if (isBeforeToday && hasSchedule) {
    return _buildPastWithScheduleTile(
      context,
      day,
      matchedSchedules.first,
      weekdays,
    );
  } else if (isBeforeToday && !hasSchedule) {
    return _buildPastWithoutScheduleTile(context, day, weekdays);
  } else if (isToday && hasSchedule) {
    return _buildTodayWithScheduleTile(
      context,
      day,
      matchedSchedules.first,
      weekdays,
    );
  } else if (isToday && !hasSchedule) {
    return _buildTodayWithoutScheduleTile(context, day, weekdays);
  } else if (isAfterToday && hasSchedule) {
    return _buildFutureWithScheduleTile(
      context,
      day,
      matchedSchedules.first,
      weekdays,
    );
  } else {
    return _buildFutureWithoutScheduleTile(context, day, weekdays);
  }
}

Widget _buildPastWithScheduleTile(
  BuildContext context,
  DateTime day,
  Schedule schedule,
  List<String> weekdays,
) {
  return SizedBox(
    height: 60,
    child: Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.white)),
        Positioned.fill(
          child: CustomPaint(
            painter: DiagonalLinesPainter(
              color: CustomColor.stone.shade300,
              spacing: 10,
              strokeWidth: 1,
            ),
          ),
        ),
        ListTile(
          leading: _buildDayLabel(
            context,
            day,
            weekdays,
            CustomColor.stone.shade400,
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTitleText(
              context,
              day,
              schedule,
              CustomColor.stone.shade400,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildPastWithoutScheduleTile(
  BuildContext context,
  DateTime day,
  List<String> weekdays,
) {
  return SizedBox(
    height: 60,
    child: Material(
      color: Colors.white,
      child: ListTile(
        leading: _buildDayLabel(
          context,
          day,
          weekdays,
          CustomColor.stone.shade400,
        ),
      ),
    ),
  );
}

Widget _buildTodayWithScheduleTile(
  BuildContext context,
  DateTime day,
  Schedule schedule,
  List<String> weekdays,
) {
  return SizedBox(
    height: 60,
    child: Material(
      color: CustomColor.stone.shade800,
      child: ListTile(
        leading: _buildDayLabel(context, day, weekdays, Colors.white),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTitleText(context, day, schedule, Colors.white),
              const SizedBox(width: 4),
              const Text('•', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        trailing: ScheduleOptionMenuButton(
          isToday: true,
          day: day,
          schedule: schedule,
          controller: ScheduleController.to,
        ),
      ),
    ),
  );
}

Widget _buildTodayWithoutScheduleTile(
  BuildContext context,
  DateTime day,
  List<String> weekdays,
) {
  return SizedBox(
    height: 60,
    child: Material(
      color: CustomColor.stone.shade800,
      child: ListTile(
        leading: _buildDayLabel(context, day, weekdays, Colors.white),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('예정된 전화 없음', style: TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );
}

Widget _buildFutureWithScheduleTile(
  BuildContext context,
  DateTime day,
  Schedule schedule,
  List<String> weekdays,
) {
  return SizedBox(
    height: 60,
    child: Material(
      color: CustomColor.stone.shade100,
      child: ListTile(
        leading: _buildDayLabel(
          context,
          day,
          weekdays,
          CustomColor.stone.shade800,
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTitleText(
            context,
            day,
            schedule,
            CustomColor.stone.shade800,
          ),
        ),
        trailing: ScheduleOptionMenuButton(
          isToday: false,
          day: day,
          schedule: schedule,
          controller: ScheduleController.to,
        ),
      ),
    ),
  );
}

Widget _buildFutureWithoutScheduleTile(
  BuildContext context,
  DateTime day,
  List<String> weekdays,
) {
  return SizedBox(
    height: 60,
    child: Material(
      color: Colors.white,
      child: ListTile(
        leading: _buildDayLabel(
          context,
          day,
          weekdays,
          CustomColor.stone.shade600,
        ),
        title: const SizedBox.shrink(),
      ),
    ),
  );
}

Widget _buildDayLabel(
  BuildContext context,
  DateTime day,
  List<String> weekdays,
  Color color,
) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        DateUtils.isSameDay(day, DateTime.now())
            ? '오늘'
            : weekdays[day.weekday - 1],
        style: TextStyle(fontSize: 10, color: color),
      ),
      Text('${day.day}', style: TextStyle(fontSize: 16, color: color)),
    ],
  );
}

Widget _buildTitleText(
  BuildContext context,
  DateTime day,
  Schedule schedule,
  Color color,
) {
  final time = schedule.getDisplayTime(day).format(context);
  return Text(
    time,
    style: TextStyle(color: color, fontWeight: FontWeight.w500),
  );
}

class DiagonalLinesPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double strokeWidth;

  DiagonalLinesPainter({
    required this.color,
    this.spacing = 12,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
