import 'dart:math';

import 'package:fitness_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/counter_data.dart';
import '../../../core/data/daily_data.dart';
import '../domain/daily_repository.dart';
import 'daily_test_page.dart';

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
  double _userWeight = 0.0;

  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    final dailyRepo = ref.read(dailyRepositoryProvider);
    _userWeight = await dailyRepo.getUserWeight();
    _level = await dailyRepo.getUserLevel();
    _tier = await dailyRepo.getUserTier();
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
              "Your current level is ${_level} and your current tier is ${_tier}",
            ),
            Text("We have set up the following exercise for you:"),
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
                  'daily_test',
                  queryParameters: {
                    'link': videoLink,
                    'exerciseType': _exerciseType!.name,
                    'userWeight': _userWeight.toString(),
                    'targetReps': _reps.toString(),
                    'timeLimit': _time.toString(),
                  },
                );
                if (value is bool) {
                  _isPassed = value;
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
              Text("You have passed the daily exercise!"),
              Text("Congratulations!"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final dailyRepo = ref.read(dailyRepositoryProvider);
                  dailyRepo.updateLevelAndTier(_level, _tier);
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
              Text("You have not passed the daily exercise!"),
              Text("Please try again tomorrow"),
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
    return FutureBuilder<void>(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Daily Exercises Test')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Daily Exercises Test')),
            body: Center(child: Text('An error occurred: ${snapshot.error}')),
          );
        }
        _setRepsAndTime();
        _buildWidget();
        return Scaffold(
          appBar: AppBar(title: Text('Daily Exercises')),
          body: _mainWidget,
        );
      },
      future: _initFuture,
    );
  }
}
