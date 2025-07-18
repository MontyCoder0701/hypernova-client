import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/schedule.controller.dart';
import 'core/go_router.core.dart';
import 'core/http.core.dart';
import 'core/theme.core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient().authorize();

  Get.put(ScheduleController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // TODO: Apply designs
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'Hypernova Client',
      theme: CustomTheme.light,
      routeInformationParser: goRouter.routeInformationParser,
      routerDelegate: goRouter.routerDelegate,
      routeInformationProvider: goRouter.routeInformationProvider,
    );
  }
}
