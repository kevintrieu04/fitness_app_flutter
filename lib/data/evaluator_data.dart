import 'package:flutter/material.dart';

import '../models/carousel_item.dart';
import '../utils/navigators/app_navigator.dart';

//Volleyball: Passing, Setting, Serving
enum Moves {
  passing, setting, serving
}

enum EvaluateExerciseType {
  volleyball
}

List<CarouselItem> evaluatorDataItemList = [
  CarouselItem(
    title: "Volleyball",
    description: "Rate your volleyball moves",
    icon: "assets/images/volleyball.webp",
    onTap: AppNavigator.volleyballOnTap,
  ),
];

List<DropdownMenuEntry<Moves>> volleyballMoves = [
  DropdownMenuEntry(value: Moves.passing, label: "Passing"),
  DropdownMenuEntry(value: Moves.setting, label: "Setting"),
  DropdownMenuEntry(value: Moves.serving, label: "Serving"),
];