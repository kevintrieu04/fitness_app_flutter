import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../models/carousel_item.dart';

class HomePageOption extends StatelessWidget {
  const HomePageOption({
    super.key,
    required this.title,
    required this.carouselList,
  });

  final String title;
  final List<CarouselItem> carouselList;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(title, style: TextStyle(fontSize: 24)),
                Spacer(),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        CarouselSlider.builder(
          itemCount: carouselList.length,
          itemBuilder: (context, itemIndex, pageViewIndex) => SizedBox(
            width: 200,
            child: InkWell(
              onTap: () {
                carouselList[itemIndex].onTap(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    carouselList[itemIndex].link,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          options: _carouselOptions,
        ),
      ],
    );
  }
}

final _carouselOptions = CarouselOptions(
  height: 200,
  aspectRatio: 16 / 9,
  viewportFraction: 0.5,
  initialPage: 1,
  enableInfiniteScroll: false,
  reverse: false,
  autoPlay: false,
  autoPlayInterval: Duration(seconds: 3),
  autoPlayAnimationDuration: Duration(milliseconds: 800),
  autoPlayCurve: Curves.fastOutSlowIn,
  enlargeCenterPage: true,
  enlargeFactor: 0.3,
  onPageChanged: null,
  scrollDirection: Axis.horizontal,
);
