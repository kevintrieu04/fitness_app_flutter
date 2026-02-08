import 'package:fitness_app/core/data/counter_data.dart';
import 'package:fitness_app/features/leaderboard/data/user_leaderboard_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/design_tokens.dart';
import '../domain/leaderboard_repository.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _LeaderboardPageState();
  }
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  final _searchController = SearchController();
  String? _selectedChallengeId;
  String? _selectedExerciseType;
  int? _selectedReps;
  int? _selectedTime;

  String _getVideoLink(ExerciseType selectedExerciseType) {
    switch (selectedExerciseType) {
      case ExerciseType.Pushup:
        return //"assets/videos/pushups/pushup_test.mp4";
          "assets/videos/private_videos/side_view_further.mp4";
      case ExerciseType.Squat:
        return "assets/videos/squats/squat_360_test.mp4";
      case ExerciseType.Lunge:
        return "assets/videos/lunges/lunge_front_test.mp4";
      case ExerciseType.Bridge:
        return "assets/videos/bridges/bridge_test.mp4";
      case ExerciseType.Pullup:
        return "assets/videos/pullups/pull_up_front_view.mp4";
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(leaderboardRepositoryProvider);
    final challenges = ref.watch(challengesProvider);
    final userWeightAsync = ref.watch(userWeightProvider);
    final leaderboard = _selectedChallengeId == null
        ? const AsyncData<List<UserLeaderboardInfo>>([])
        : ref.watch(leaderboardInfoProvider(_selectedChallengeId!));

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: AppBar(
        backgroundColor: DT.bg,
        elevation: 0,
        title: Text(
          "Leaderboard",
          style: TextStyle(
            color: DT.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchAnchor.bar(
            searchController: _searchController,
            isFullScreen: false,
            barElevation: const WidgetStatePropertyAll(1),
            viewElevation: 1.0,
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              return challenges.when(
                data: (data) {
                  final filtered = data
                      .where(
                        (item) => item.name.toLowerCase().contains(
                              controller.text.toLowerCase(),
                            ),
                      )
                      .toList();
                  return filtered.map(
                    (item) => ListTile(
                      title: Text(item.name),
                      onTap: () {
                        setState(() {
                          _selectedChallengeId = item.id;
                          _selectedExerciseType = item.exerciseType;
                          _selectedReps = item.reps;
                          _selectedTime = item.time;
                        });
                        controller.closeView(item.name);
                      },
                    ),
                  );
                },
                loading: () => [const ListTile(title: Text('loading...'))],
                error: (error, stackTrace) => [
                  const ListTile(title: Text('error')),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          if (_selectedExerciseType != null)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedExerciseType!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedReps != null && _selectedReps! > 0)
                    Text(
                      ' - Reps: $_selectedReps',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_selectedTime != null && _selectedTime! > 0)
                    Text(
                      ' - Time: $_selectedTime s',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final userWeight = userWeightAsync.value;
                      if (userWeight == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User weight not available.'),
                            ),
                          );
                        }
                        return;
                      }

                      final results = await context.pushNamed('challenge',
                        queryParameters: {
                          'link': _getVideoLink(ExerciseType.values.byName(_selectedExerciseType!)),
                          'exerciseType': _selectedExerciseType!,
                          'userWeight': userWeight.toString(),
                          'targetReps': (_selectedReps ?? 0).toString(),
                          'timeLimit': (_selectedTime ?? 0).toString(),
                        },
                      );
                      // Assuming results is a List [bool isPassed, int score]
                      if (mounted && results is List && results.isNotEmpty) {
                        final bool isPassed = results[0] as bool;
                        final int score = results[1] as int;

                        if (isPassed) {
                          await repo.addScore(_selectedChallengeId!, score);
                          // Optionally show a success message
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You have not passed the challenge.'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Join Challenge"),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Ranking"), Text("User"), Text("Counts")],
            ),
          ),
          const Divider(color: DT.borderGrey),
          Expanded(
            child: leaderboard.when(
              data: (data) => ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = data[index];
                  return ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    leading: CircleAvatar(child: Text("${index + 1}")),
                    title: Center(child: Text(user.name)),
                    subtitle: Center(child: Text(user.level)),
                    trailing: Text("${user.counts}"),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => const Center(child: Text('error')),
            ),
          ),
        ],
      ),
    );
  }
}
