import 'package:fitness_app/utils/navigators/app_navigator.dart';
import 'package:flutter/material.dart';

import '../data/counter_data.dart';

class FitnessCounterAlertBox extends StatefulWidget {
  const FitnessCounterAlertBox({
    super.key,
    required this.link,
    required this.type,
  });

  final String link;
  final ExerciseType type;

  @override
  State<StatefulWidget> createState() {
    return _FitnessCounterAlertBoxState();
  }
}

class _FitnessCounterAlertBoxState extends State<FitnessCounterAlertBox> {
  double? _userWeight;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AlertDialog(
          title: const Text('Fitness Counter'),
          content: Column(
            children: [
              const Text("Please enter your weight (in kg)"),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Weight (in kg)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _userWeight = double.tryParse(value);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_userWeight == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter your weight")),
                  );
                } else {
                  Navigator.of(context).pop();
                  AppNavigator.onOpenCounterTestPage(
                    context,
                    widget.link,
                    widget.type,
                    _userWeight!,
                  );
                }
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}
