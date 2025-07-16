import 'package:flutter/material.dart';

import 'core/go_router.core.dart';
import 'core/theme.core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hypernova Client',
      theme: CustomTheme.light,
      routerConfig: goRouter,
    );
  }
}
