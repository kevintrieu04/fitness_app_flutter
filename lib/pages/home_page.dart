import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/data/evaluator_data.dart';
import 'package:fitness_app/utils/navigators/app_navigator.dart';
import 'package:fitness_app/widgets/carousel_option.dart';
import 'package:fitness_app/widgets/util_menu_option.dart';
import 'package:flutter/material.dart';

import '../data/counter_data.dart';
import '../firebase_options.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Widget _appBarIcon = IconButton(
    onPressed: () {
      AppNavigator.logInPageOnTap(context);
    },
    icon: const Icon(Icons.login_outlined),
  );

  void _checkUserState() {
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _appBarIcon = IconButton(
            onPressed: () {
              AppNavigator.userProfileOnTap(context, user);
            },
            icon: const Icon(Icons.person_pin),
          );
        });
      } else {
        setState(() {
          _appBarIcon = IconButton(
            onPressed: () {
              AppNavigator.logInPageOnTap(context);
            },
            icon: const Icon(Icons.login_outlined),
          );
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkUserState();
  }

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
              actions: [_appBarIcon],
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CarouselOption(
                title: 'Exercises Counter',
                carouselList: counterCarouselItemList,
                itemCount: 4,
              ),
              const SizedBox(height: 20),
              CarouselOption(
                title: 'Exercises Evaluator',
                carouselList: evaluatorDataItemList,
                itemCount: 1,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  UtilMenuOption(
                    colors: [Colors.purple, Colors.purpleAccent],
                    icon: Icons.scale,
                    onTap: (context) =>
                        AppNavigator.calorieEstimatorOnTap(context),
                    title: "Calorie Estimator",
                  ),
                  UtilMenuOption(
                    colors: [Colors.lightBlue, Colors.lightBlueAccent],
                    icon: Icons.calendar_month,
                    onTap: (context) =>
                        AppNavigator.exercisePlannerOnTap(context),
                    title: "Exercise Planner",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
