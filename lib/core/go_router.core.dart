import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../service/auth.service.dart';
import '../view/home.screen.dart';
import '../view/login.screen.dart';
import '../view/settings.screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    final isTokenSaved = await AuthService.isTokenSaved;
    final isGoingToLogin = state.uri.toString() == '/login';

    if (!isTokenSaved && !isGoingToLogin) {
      return '/login';
    }
    if (isTokenSaved && isGoingToLogin) {
      return '/';
    }
    return null;
  },
);
