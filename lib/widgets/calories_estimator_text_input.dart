import 'package:flutter/material.dart';

class CaloriesEstimatorTextInput extends StatelessWidget {
  const CaloriesEstimatorTextInput({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: description,
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
