import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/add_challenge/presentation/add_challenge_page.dart';
import 'package:fitness_app/core/data/counter_data.dart';
import 'package:fitness_app/features/counter/presentation/counter_test_page.dart';
import 'package:fitness_app/features/home/presentation/new_counter_option_page.dart';
import 'package:fitness_app/features/home/presentation/new_user_profile_page.dart';
import 'package:fitness_app/features/estimator/presentation/calories_estimation_page.dart';
import 'package:fitness_app/features/planner/presentation/exercise_planner_page.dart';
import 'package:fitness_app/features/evaluator/presentation/image_evaluator_test_page.dart';
import 'package:fitness_app/features/leaderboard/presentation/leaderboard_page.dart';
import 'package:fitness_app/utils/navigators/router_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/data/evaluator_data.dart';
import '../../features/auth/presentation/auth_viewmodel.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/daily_and_challenges/presentation/challenge_test_page.dart';
import '../../features/daily_and_challenges/presentation/daily_exercises_page.dart';
import '../../features/home/presentation/new_home_page.dart';
import '../../widgets/bottom_nav.dart';

part 'app_router.g.dart';

@riverpod
GoRouter buildRouter(Ref ref) {
  final notifier = ref.watch(routerProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      // 1. Get the current AuthState
      final authStateAsync = ref.read(authViewModelProvider);

      String getErrorMessage(Object e) {
        if (e is FirebaseAuthException) {
          return e.message ?? 'An unknown authentication error occurred.';
        }
        return 'An unexpected error occurred.';
      }

      // 2. Handle the different states of your Freezed class
      return authStateAsync.when(
        data: (auth) => auth.when(
          loading: () => '/loading',
          error: (e) =>
              '/login?error=${Uri.encodeComponent(getErrorMessage(e))}',
          authenticated: (_) {
            // If logged in but on login or loading page, go to home
            if (state.matchedLocation.startsWith('/login') ||
                state.matchedLocation == '/loading') return '/home';
            return null;
          },
          unauthenticated: () {
            // If not logged in and not on login page, force login
            if (!state.matchedLocation.startsWith('/login')) return '/login';
            return null;
          },
        ),
        // While Riverpod itself is loading the stream
        loading: () => null,
        error: (e, _) =>
            '/login?error=${Uri.encodeComponent(getErrorMessage(e))}',
      );
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final errorMessage = state.uri.queryParameters['error'];
          return LoginPage(
            isError: errorMessage != null,
            errorMessage: errorMessage,
          );
        },
      ),
      GoRoute(
        path: '/loading',
        name: 'loading',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/home/estimator',
        name: 'estimator',
        builder: (context, state) => const CaloriesEstimationPage(),
      ),
      GoRoute(
        path: '/home/planner',
        name: 'planner',
        builder: (context, state) => const ExercisePlannerPage(),
      ),
      GoRoute(
        path: '/home/evaluator',
        name: 'evaluator',
        builder: (context, state) => const ImageEvaluatorTestPage(
          evaluatorType: EvaluateExerciseType.volleyball,
          moveType: Moves.passing,
        ),
      ),
      GoRoute(
        path: '/counter/pushup',
        name: 'counter_test_pushup',
        builder: (context, state) => const CounterTestPage(
          link: "assets/videos/pushups/pushup_test.mp4",
          exerciseType: ExerciseType.Pushup,
        ),
      ),
      GoRoute(
        path: '/counter/squat',
        name: 'counter_test_squat',
        builder: (context, state) => const CounterTestPage(
          link: "assets/videos/squats/squat_test.mp4",
          exerciseType: ExerciseType.Squat,
        ),
      ),
      GoRoute(
        path: '/counter/lunge',
        name: 'counter_test_lunge',
        builder: (context, state) => const CounterTestPage(
          link: "assets/videos/lunges/lunge_test.mp4",
          exerciseType: ExerciseType.Lunge,
        ),
      ),
      GoRoute(
        path: '/counter/bridge',
        name: 'counter_test_bridge',
        builder: (context, state) => const CounterTestPage(
          link: "assets/videos/bridges/bridge_test.mp4",
          exerciseType: ExerciseType.Bridge,
        ),
      ),
      GoRoute(
        path: '/counter/pullup',
        name: 'counter_test_pullup',
        builder: (context, state) => const CounterTestPage(
          link: "assets/videos/pullups/pull_up_front_view.mp4",
          exerciseType: ExerciseType.Pullup,
        ),
      ),
      GoRoute(
        path: '/home/daily',
        name: 'daily',
        builder: (context, state) => const DailyExercisesPage(),
      ),
      GoRoute(
        path: '/challenge',
        name: 'challenge',
        builder: (context, state) {
          final data = state.uri.queryParameters;
          final link = data['link']!;
          final exerciseType = ExerciseType.values.byName(
            data['exerciseType']!,
          );
          final userWeight = double.parse(data['userWeight']!);
          final targetReps = int.parse(data['targetReps']!);
          final timeLimit = int.parse(data['timeLimit']!);
          return ChallengeTestPage(
            link: link,
            exerciseType: exerciseType,
            userWeight: userWeight,
            targetReps: targetReps,
            timeLimit: timeLimit,
          );
        },
      ),
      GoRoute(
        path: '/home/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardPage(),
      ),
      GoRoute(
        path: '/home/add_challenge',
        name: 'add_challenge',
        builder: (context, state) => const AddChallengePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => BottomNavScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/counter',
                name: 'counter',
                builder: (context, state) => const CounterOptionPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const UserProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
