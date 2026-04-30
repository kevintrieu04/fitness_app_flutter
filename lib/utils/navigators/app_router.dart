import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/add_challenge/presentation/add_challenge_page.dart';
import 'package:fitness_app/core/data/counter_data.dart';
import 'package:fitness_app/features/counter/presentation/counter_test_option_page.dart';
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
import '../../features/daily_and_challenges/presentation/challenge_result_page.dart';
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
                state.matchedLocation == '/loading') {
              return '/home';
            }
            return null;
          },
          unauthenticated: () {
            // If not logged in and not on login page, force login
            if (!state.matchedLocation.startsWith('/login')) {
              return '/login';
            }
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
        path: '/counter/test',
        name: 'counter_test',
        builder: (context, state) {
          final data = state.uri.queryParameters;
          final link = data['link']!;
          final exerciseType = ExerciseType.values.byName(
            data['exerciseType']!,
          );
          bool isAsset = false;
          if (data["isAsset"] == "true") {
            isAsset = true;
          }
          return CounterTestPage(
            link: link,
            exerciseType: exerciseType,
            isAsset: isAsset,
          );
        },
      ),
      GoRoute(
        path: '/counter/options',
        name: 'counter_test_options',
        builder: (context, state) {
          final data = state.uri.queryParameters;
          final exerciseType = ExerciseType.values.byName(
            data['exerciseType']!,
          );
          return CounterTestOptionPage(
            exerciseType: exerciseType,
          );
        },
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
          final isDaily = data['isDaily'] != null
              ? bool.parse(data['isDaily']!)
              : true;
          return ChallengeTestPage(
            link: link,
            exerciseType: exerciseType,
            userWeight: userWeight,
            targetReps: targetReps,
            timeLimit: timeLimit,
            isDaily: isDaily,
          );
        },
      ),
      GoRoute(
        path: '/challenge/result',
        name: 'challenge_result',
        builder: (context, state) {
          final data = state.uri.queryParameters;
          final errorsJson = data['errors']!;
          final decodedErrors = jsonDecode(errorsJson) as Map<String, dynamic>;
          final errors = decodedErrors.map(
            (key, value) => MapEntry(int.parse(key), value.toString()),
          );
          final totalCount = int.parse(data['totalCount']!);
          final correctReps = int.parse(data['correctReps']!);
          final caloriesBurnt = double.parse(data['caloriesBurnt']!);
          final targetReps = int.parse(data['targetReps']!);
          return ChallengeResultPage(
            errors: errors,
            totalCount: totalCount,
            correctReps: correctReps,
            caloriesBurnt: caloriesBurnt,
            targetReps: targetReps,
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
