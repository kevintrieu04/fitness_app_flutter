import 'package:flutter/material.dart';

class UtilMenuOption extends StatelessWidget {
  const UtilMenuOption({super.key, required this.colors, required this.icon, required this.onTap, required this.title});

  final List<Color> colors;
  final IconData icon;
  final Function(BuildContext context) onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          )
        ),
        width: 180,
        height: 180,
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
            Icon(icon, size: 50),
          ],
        ),
      ),
    );
  }


}