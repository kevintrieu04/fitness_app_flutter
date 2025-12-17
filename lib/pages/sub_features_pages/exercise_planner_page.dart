import 'package:fitness_app/widgets/calories_estimator_dropdown.dart';
import 'package:fitness_app/widgets/calories_estimator_text_input.dart';
import 'package:flutter/material.dart';

class ExercisePlannerPage extends StatefulWidget {
  const ExercisePlannerPage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ExercisePlannerPageState();
  }
}

class _ExercisePlannerPageState extends State<ExercisePlannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Planner')),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  children: [
                    CaloriesEstimatorTextInput(
                      title: "Weight (kg)",
                      description: "Type your weight here",
                    ),
                    CaloriesEstimatorTextInput(
                      title: "Height (cm)",
                      description: "Type your height here",
                    ),
                    CaloriesEstimatorDropdown(
                      title: "Experiences",
                      entries: [
                        DropdownMenuEntry(value: "beginner", label: "Beginner"),
                        DropdownMenuEntry(
                          value: "intermediate",
                          label: "Intermediate",
                        ),
                        DropdownMenuEntry(value: "advanced", label: "Advanced"),
                      ],
                    ),
                    CaloriesEstimatorDropdown(
                      title: "Frequency",
                      entries: [
                        DropdownMenuEntry(value: "1", label: "1"),
                        DropdownMenuEntry(value: "2", label: "2"),
                        DropdownMenuEntry(value: "3", label: "3"),
                        DropdownMenuEntry(value: "4", label: "4"),
                        DropdownMenuEntry(value: "5", label: "5"),
                        DropdownMenuEntry(value: "6", label: "6"),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(onPressed: () {}, child: Text("Submit")),
              SizedBox(height: 400),
            ],
          ),
        ),
      ),
    );
  }
}
