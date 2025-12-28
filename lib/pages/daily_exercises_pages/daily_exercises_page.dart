import 'package:flutter/material.dart';

import '../../data/counter_data.dart';
import '../../data/daily_data.dart';
import '../../utils/navigators/app_navigator.dart';

class DailyExercisesPage extends StatefulWidget {
  const DailyExercisesPage({
    super.key,
    required this.level,
    required this.tier,
  });

  final String level;
  final int tier;

  @override
  State<DailyExercisesPage> createState() => _DailyExercisesPageState();
}

class _DailyExercisesPageState extends State<DailyExercisesPage> {
  bool _isSettingUp = true;
  bool _isPassed = false;
  bool _hasDoneDaily = false;
  int _reps = 1;
  int _time = 1;
  double _userWeight = 0.0;
  ExerciseType? _exerciseType;
  Widget _mainWidget = Container();

  void _setRepsAndTime() {
    switch (widget.level) {
      case 'Beginner':
        _reps = beginnerData[widget.tier - 1].reps;
        _time = beginnerData[widget.tier - 1].time;
        break;
      case 'Intermediate':
        _reps = intermediateData[widget.tier - 1].reps;
        _time = intermediateData[widget.tier - 1].time;
        break;
      case 'Advanced':
        _reps = advancedData[widget.tier - 1].reps;
        _time = advancedData[widget.tier - 1].time;
        break;
    }
  }

  void _buildWidget() {
    if (_isSettingUp) {
      _mainWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("What exercise do you want to do?"),
            SizedBox(height: 10),
            DropdownMenu(
              dropdownMenuEntries: [
                for (final exercise in ExerciseType.values)
                  DropdownMenuEntry(value: exercise, label: exercise.name),
              ],
              onSelected: (value) {
                _exerciseType = value;
              },
            ),
            SizedBox(height: 20),
            Text("What is your current weight?"),
            Padding(
              padding: const EdgeInsets.only(left: 100.0, right: 100.0),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _userWeight = double.tryParse(value) ?? 0.0;
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSettingUp = false;
                });
              },
              child: Text('Start'),
            ),
          ],
        ),
      );
    } else if (!_hasDoneDaily) {
      if (_exerciseType == null || _userWeight == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        _isSettingUp = true;
      } else {
        _mainWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Your current level is ${widget.level} and your current tier is ${widget.tier}",
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
                      videoLink =
                          "assets/videos/pullups/pull_up_front_view.mp4";
                      break;
                    default:
                      videoLink = "";
                      break;
                  }
                  _isPassed = await AppNavigator.onOpenDailyTestPage(
                    context,
                    videoLink,
                    _exerciseType!,
                    _userWeight,
                    _reps,
                    _time,
                  );
                  setState(() {
                    _hasDoneDaily = true;
                  });
                },
                child: Text('Start'),
              ),
            ],
          ),
        );
      }
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
                  Navigator.of(context).pop([_hasDoneDaily, _isPassed]);
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
                  Navigator.of(context).pop([_hasDoneDaily, _isPassed]);
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
    _setRepsAndTime();
    _buildWidget();

    return Scaffold(
      appBar: AppBar(title: Text('Daily Exercises')),
      body: _mainWidget,
    );
  }
}
