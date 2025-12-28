import 'package:fitness_app/pages/counter_pages/new_counter_option_page.dart';
import 'package:fitness_app/pages/new_user_profile_page.dart';
import 'package:go_router/go_router.dart';

import '../../pages/new_home_page.dart';
import '../../widgets/bottom_nav.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => BottomNavScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/counter',
              name: 'counter',
              builder: (context, state) => const CounterOptionPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const UserProfilePage(),
            ),
          ])
        ]
      )
    ]
  );
}