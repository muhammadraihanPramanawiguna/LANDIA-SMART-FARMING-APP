import 'package:go_router/go_router.dart';

import '../app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const AppShell(),
    ),
  ],
);
