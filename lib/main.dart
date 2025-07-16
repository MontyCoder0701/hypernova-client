import 'package:flutter/material.dart';

import 'core/go_router.core.dart';
import 'core/http.core.dart';
import 'core/theme.core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient().authorize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // TODO: Apply designs
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hypernova Client',
      theme: CustomTheme.light,
      routerConfig: goRouter,
    );
  }
}
