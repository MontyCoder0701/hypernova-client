import 'package:go_router/go_router.dart';

import 'login.screen.dart';

final goRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginScreen()),
    ),
  ],
);
