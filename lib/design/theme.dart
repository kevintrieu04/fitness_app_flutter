import 'package:fitness_app/design/design_tokens.dart';
import 'package:flutter/material.dart';

ThemeData buildTheme () {
  final base = ThemeData(
    colorSchemeSeed: DT.cardBlue,
    brightness: Brightness.light
  );

  return base.copyWith(
    scaffoldBackgroundColor: DT.bg,
    textTheme: base.textTheme.apply(
      bodyColor: DT.text,
      displayColor: DT.text
    ),
    cardTheme: CardThemeData(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(DT.rCard))
      )
    )
  );
}