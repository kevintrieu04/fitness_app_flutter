import 'package:fitness_app/models/carousel_item.dart';
import 'package:fitness_app/widgets/home_page_option.dart';
import 'package:flutter/material.dart';

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
            child:
              HomePageOption(
                title: 'Exercises Counter',
                carouselList: firstCarouselList,
              ),
          ),
        ),
      );
  }
}
