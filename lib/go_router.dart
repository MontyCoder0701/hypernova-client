import 'package:go_router/go_router.dart';

import 'view/home.screen.dart';
import 'view/login.screen.dart';
import 'view/settings.screen.dart';

final goRouter = GoRouter(
  // TODO: check session before allowing routing
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
  ],
);
