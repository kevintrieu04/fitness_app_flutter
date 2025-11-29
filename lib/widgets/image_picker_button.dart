import 'package:flutter/material.dart';

class ImagePickerButton extends StatelessWidget {
  const ImagePickerButton({super.key, required this.icon, required this.text, required this.onTap});

  final IconData icon;
  final String text;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Column(
          children: [
            Icon(icon, size: 50, color: Colors.grey.shade400),
            Text(text, style: TextStyle(color: Colors.grey.shade400)),
          ],
        ),
    );
  }
}