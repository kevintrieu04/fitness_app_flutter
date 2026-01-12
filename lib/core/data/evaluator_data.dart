import 'package:flutter/material.dart';

//Volleyball: Passing, Setting, Serving
enum Moves {
  passing, setting, serving
}

enum EvaluateExerciseType {
  volleyball
}

List<DropdownMenuEntry<Moves>> volleyballMoves = [
  DropdownMenuEntry(value: Moves.passing, label: "Passing"),
  DropdownMenuEntry(value: Moves.setting, label: "Setting"),
  DropdownMenuEntry(value: Moves.serving, label: "Serving"),
];