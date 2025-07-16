import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'view/home.screen.dart';
import 'view/login.screen.dart';
import 'view/settings.screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    return token != null ? '/' : '/login';
  },
);
