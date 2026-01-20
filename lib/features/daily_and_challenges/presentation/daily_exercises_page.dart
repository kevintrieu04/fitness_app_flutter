import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/counter_data.dart';
import '../../../core/data/daily_data.dart';
import '../../home/domain/user_repository.dart';
import '../domain/daily_repository.dart';

class DailyExercisesPage extends ConsumerStatefulWidget {
  const DailyExercisesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _DailyExercisesPageState();
  }
}

class _DailyExercisesPageState extends ConsumerState<DailyExercisesPage> {
  bool _isPassed = false;
  bool _hasDoneDaily = false;
  int _reps = 1;
  int _time = 1;
  ExerciseType? _exerciseType;
  Widget _mainWidget = Container();
  String _level = "";
  int _tier = 0;
  String _bestLevel = "";
  int _bestTier = 0;
  double _userWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _exerciseType = _getRandomExerciseType();
  }

  ExerciseType _getRandomExerciseType() {
    final randomIndex = Random().nextInt(ExerciseType.values.length);
    return ExerciseType.values[randomIndex];
  }

  void _setRepsAndTime() {
    switch (_level) {
      case 'Beginner':
        _reps = beginnerData[_tier - 1].reps;
        _time = beginnerData[_tier - 1].time;
        break;
      case 'Intermediate':
        _reps = intermediateData[_tier - 1].reps;
        _time = intermediateData[_tier - 1].time;
        break;
      case 'Advanced':
        _reps = advancedData[_tier - 1].reps;
        _time = advancedData[_tier - 1].time;
        break;
    }
  }

  void _buildWidget() {
    if (!_hasDoneDaily) {
      _mainWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Your current level is $_level and your current tier is $_tier",
            ),
            Text("We have set up the following exercise for you:"),
            SizedBox(height: 10),
            SizedBox(height: 10),
            Text("Exercise Type: ${_exerciseType!.name}"),
            Text("Reps: $_reps"),
            Text("Time: $_time seconds"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String videoLink;
                switch (_exerciseType) {
                  case ExerciseType.Pushup:
                    videoLink = "assets/videos/pushups/pushup_test.mp4";
                    break;
                  case ExerciseType.Squat:
                    videoLink = "assets/videos/squats/squat_360_test.mp4";
                    break;
                  case ExerciseType.Lunge:
                    videoLink = "assets/videos/lunges/lunge_front_test.mp4";
                    break;
                  case ExerciseType.Bridge:
                    videoLink = "assets/videos/bridges/bridge_test.mp4";
                    break;
                  case ExerciseType.Pullup:
                    videoLink = "assets/videos/pullups/pull_up_front_view.mp4";
                    break;
                  default:
                    videoLink = "";
                    break;
                }
                final value = await context.pushNamed(
                  'challenge',
                  queryParameters: {
                    'link': videoLink,
                    'exerciseType': _exerciseType!.name,
                    'userWeight': _userWeight.toString(),
                    'targetReps': _reps.toString(),
                    'timeLimit': _time.toString(),
                  },
                );
                if (value is List) {
                  _isPassed = value[0];
                }
                setState(() {
                  _hasDoneDaily = true;
                });
              },
              child: Text('Start'),
            ),
          ],
        ),
      );
    } else {
      if (_isPassed) {
        _mainWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You have passed the challenge!"),
              Text("Congratulations!"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final dailyRepo = ref.read(dailyRepositoryProvider);
                  dailyRepo.updateLevelAndTier(
                    _level,
                    _tier,
                    _bestLevel,
                    _bestTier,
                  );
                  dailyRepo.updateLastDoneDaily();
                  context.pop();
                },
                child: Text('Return'),
              ),
            ],
          ),
        );
      } else {
        _mainWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You have not passed the challenge exercise!"),
              Text("Please try again"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final dailyRepo = ref.read(dailyRepositoryProvider);
                  dailyRepo.updateLastDoneDaily();
                  context.pop();
                },
                child: Text('Return'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileDataProvider);

    return profileAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Daily Exercises')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Daily Exercises')),
        body: Center(child: Text('An error occurred: \$err')),
      ),
      data: (profileInfo) {
        final data = profileInfo as Map<String, dynamic>? ?? {};
        _level = data["level"] ?? "Beginner";
        _tier = data["tier"] ?? 1;
        _bestLevel = data["bestLevel"] ?? "Beginner";
        _bestTier = data["bestTier"] ?? 1;
        _userWeight = (data["startWeight"] ?? 0.0).toDouble();

        _setRepsAndTime();
        _buildWidget();

        return Scaffold(
          appBar: AppBar(title: const Text('Daily Exercises')),
          body: _mainWidget,
        );
      },
    );
  }
}
