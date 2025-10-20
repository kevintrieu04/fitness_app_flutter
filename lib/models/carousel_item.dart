import 'package:flutter/material.dart';

import '../utils/navigators/app_navigator.dart';

class CarouselItem {
  const CarouselItem({required this.link, required this.onTap});

  final String link;
  final Function(BuildContext context) onTap;
}

final List<CarouselItem> firstCarouselList = [
  CarouselItem(link: "assets/images/push_up.jpg", onTap: AppNavigator.pushUpOnTap),
  CarouselItem(link: "assets/images/squat.jpg", onTap: AppNavigator.squatOnTap),
  CarouselItem(link: "assets/images/bridge.webp", onTap: (context) {}),
  CarouselItem(link: "assets/images/lunge.webp", onTap: (context) {}),
];


