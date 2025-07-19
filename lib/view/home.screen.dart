import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../controller/schedule.controller.dart';
import '../model/weekday.enum.dart';
import '../service/auth.service.dart';
import 'components/frosted.app_bar.dart';
import 'components/schedule.list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _itemExtent = 60;
  late final List<DateTime> days;
  late final DateTime today;
  late final int todayIndex;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    today = DateUtils.dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 7));
    days = List.generate(21, (i) => start.add(Duration(days: i)));
    todayIndex = days.indexWhere((d) => DateUtils.isSameDay(d, today));

    _scrollController = ScrollController(
      initialScrollOffset: todayIndex * _itemExtent,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar(
        leading: IconButton(
          icon: Image.asset('assets/icons/logout.png', width: 24, height: 24),
          onPressed: () => _handleLogout(context),
        ),
        title: Text('${today.year}년 ${today.month}월'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Theme.of(context).colorScheme.outlineVariant,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Theme.of(context).colorScheme.surfaceDim),
          ),
          GetBuilder<ScheduleController>(
            initState: (_) => ScheduleController.to.getAll(),
            builder: (controller) {
              final schedules = controller.resources;

              return ListView.separated(
                controller: _scrollController,
                itemCount: days.length + 2,
                separatorBuilder: (_, __) => Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == 0 || index == days.length + 1) {
                    return Divider(height: 1);
                  }

                  final day = days[index - 1];
                  final weekdays = WeekdayExtension.labels;
                  return buildScheduleTile(
                    context: context,
                    today: today,
                    day: day,
                    weekdays: weekdays,
                    schedules: schedules,
                  );
                },
              );
            },
          ),
          Positioned(
            left: 54,
            top: 0,
            bottom: 0,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.outline,
              child: const SizedBox(width: 1),
            ),
          ),
        ],
      ),
    );
  }
}
