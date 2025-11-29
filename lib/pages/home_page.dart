import 'package:fitness_app/utils/navigators/app_navigator.dart';
import 'package:fitness_app/widgets/counter_option.dart';
import 'package:fitness_app/widgets/util_menu_option.dart';
import 'package:flutter/material.dart';

import '../data/counter_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Center(child: Text("Fitness App")),
              expandedHeight: 200,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  'assets/images/app_bar.webp',
                  fit: BoxFit.fill,
                ),
              ),
              backgroundColor: Colors.blueAccent,
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CounterOption(
                title: 'Exercises Counter',
                carouselList: counterDataItemList,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  UtilMenuOption(
                    colors: [Colors.purple, Colors.purpleAccent],
                    icon: Icons.scale,
                    onTap: (context) => AppNavigator.calorieEstimatorOnTap(context),
                    title: "Calorie Estimator",
                  ),
                  UtilMenuOption(
                    colors: [Colors.lightBlue, Colors.lightBlueAccent],
                    icon: Icons.calendar_month,
                    onTap: (context) => AppNavigator.exercisePlannerOnTap(context),
                    title: "Exercise Planner",
                  )
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
