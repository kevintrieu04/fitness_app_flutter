import 'package:flutter/material.dart';

import '../../data/counter_data.dart';
import '../../models/carousel_item.dart';

class CounterOptionPage extends StatelessWidget {
  const CounterOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Exercise')),
      body: ListView.builder(
        itemCount: counterCarouselItemList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                counterCarouselItemList[index].icon,
                fit: BoxFit.fill,
              ),
            ),
            title: Text(counterCarouselItemList[index].title),
            subtitle: Text(counterCarouselItemList[index].description),
            onTap: () {
              counterCarouselItemList[index].onTap(context);
            },
          );
        },
      ),
    );
  }
}
