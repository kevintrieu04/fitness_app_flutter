import 'package:fitness_app/core/data/counter_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CounterTestOptionPage extends StatelessWidget {
  const CounterTestOptionPage({super.key, required this.exerciseType});

  final ExerciseType exerciseType;

  String _chooseAsset() {
    switch (exerciseType) {
      case ExerciseType.Pushup:
        return "assets/videos/pushups/static/push_up_static.mp4";
      case ExerciseType.Squat:
        return "assets/videos/squats/static/squat_test_static.mp4";
      case ExerciseType.Lunge:
        return "assets/videos/lunges/static/lunge_test_static_10.mp4";
      case ExerciseType.Bridge:
        return "assets/videos/bridges/static/bridge_test_static_5.mp4";
      case ExerciseType.Pullup:
        return "assets/videos/pullups/static/pull_up_static_10.mp4";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Initializing Test")),
      body: Center(
        child: Container(
          height: 600,
          width: 600,
          child: Column(
            children: [
              const Text(
                "Choose a way to test",
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  final video = await ImagePicker().pickVideo(
                    source: ImageSource.gallery,
                  );
                  if (context.mounted && video != null) {
                    context.pushNamed(
                      "counter_test",
                      queryParameters: {
                        "link": video.path,
                        "isAsset": "false",
                        "exerciseType": exerciseType.name,
                      },
                    );
                  }
                },
                child: const Text("Choose a video file"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.pushNamed(
                    "counter_test",
                    queryParameters: {
                      "link": _chooseAsset(),
                      "isAsset": "true",
                      "exerciseType": exerciseType.name,
                    },
                  );
                },
                child: const Text("Use asset videos"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
