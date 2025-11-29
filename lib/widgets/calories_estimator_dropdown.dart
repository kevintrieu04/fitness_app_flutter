import 'package:flutter/material.dart';

class CaloriesEstimatorDropdown extends StatelessWidget {
  const CaloriesEstimatorDropdown(
      {super.key, required this.title, required this.entries});

  final String title;
  final List<DropdownMenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        DropdownMenu(
          dropdownMenuEntries: entries
        )
      ],
    );
  }
  }