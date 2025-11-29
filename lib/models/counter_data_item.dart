import 'package:flutter/material.dart';

class CounterDataItem {
  const CounterDataItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final String icon;
  final Function(BuildContext context) onTap;
}

