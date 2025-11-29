import 'package:flutter/material.dart';

import '../data/counter_data.dart';
import '../models/counter_data_item.dart';

class CounterOptionPage extends StatelessWidget {
  const CounterOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Exercise')),
      body: ListView.builder(
        itemCount: counterDataItemList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                counterDataItemList[index].icon,
                fit: BoxFit.fill,
              ),
            ),
            title: Text(counterDataItemList[index].title),
            subtitle: Text(counterDataItemList[index].description),
            onTap: () {
              counterDataItemList[index].onTap(context);
            },
          );
        },
      ),
    );
  }
}
