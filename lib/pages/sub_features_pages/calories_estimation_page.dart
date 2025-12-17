import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fitness_app/services/api_client.dart';
import 'package:fitness_app/widgets/image_picker_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/calories_estimator_data.dart';

class CaloriesEstimationPage extends StatefulWidget {
  const CaloriesEstimationPage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CaloriesEstimationPageState();
  }
}

class _CaloriesEstimationPageState extends State<CaloriesEstimationPage> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  String detectionResult = "";
  double caloriesPerSlice = 0;
  double caloriesPerServing = 0;
  double caloriesPerGram = 0;
  double totalCalories = 0;
  String dropdownValue = "";
  List<DropdownMenuEntry<String>> dropdownEntries = [];

  void _getImageFromCamera() async {
    final XFile? retrievedImage = await picker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      image = retrievedImage;
      if (image != null) {
        _renderDropDownEntries();
      }
    });
  }

  void _getImageFromGallery() async {
    final XFile? retrievedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      image = retrievedImage;
    });
    if (image != null) {
      _renderDropDownEntries();
    }
  }

  void _renderDropDownEntries() async {
    final client = ApiClient.instance;
    final response = await client.apiService.estimateCalories(
      File(image!.path),
    );
    setState(() {
      detectionResult = response['result'];
      final caloriesInfo = caloriesInfoList[detectionResult];
      if (caloriesInfo != null) {
        caloriesPerSlice = caloriesInfo.caloriesPerSlice;
        caloriesPerServing = caloriesInfo.caloriesPerServing;
        caloriesPerGram = caloriesInfo.caloriesPerGram;
        print(caloriesPerSlice);
        print(caloriesPerServing);
        print(caloriesPerGram);
        dropdownEntries.clear();

        if (caloriesPerSlice != -1) {
          dropdownEntries.add(
            DropdownMenuEntry(value: "Slice", label: "Slice"),
          );
        }
        if (caloriesPerServing != -1) {
          dropdownEntries.add(
            DropdownMenuEntry(value: "Serving", label: "Serving"),
          );
        }
        if (caloriesPerGram != -1) {
          dropdownEntries.add(DropdownMenuEntry(value: "Gram", label: "Gram"));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text('Calories Estimation')),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Container(
              width: 250,
              height: 300,
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: image == null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImagePickerButton(
                          icon: Icons.camera_alt,
                          text: "Take a photo",
                          onTap: _getImageFromCamera,
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),
                        ImagePickerButton(
                          icon: Icons.image,
                          text: "Choose from gallery",
                          onTap: _getImageFromGallery,
                        ),
                      ],
                    )
                  : Image.file(File(image!.path), fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Detected Food: $detectionResult",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text("Amount: ", style: TextStyle(fontSize: 20)),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter amount",
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final amount = double.parse(value);
                      switch (dropdownValue) {
                        case "Slice":
                          setState(() {
                            totalCalories = amount * caloriesPerSlice;
                          });
                          break;
                        case "Serving":
                          setState(() {
                            totalCalories = amount * caloriesPerServing;
                          });
                          break;
                        case "Gram":
                          setState(() {
                            totalCalories = amount * caloriesPerGram;
                          });
                          break;
                      }
                    } else {
                      setState(() {
                        totalCalories = 0;
                      });
                    }
                  },
                ),
              ),
              DropdownMenu(
                dropdownMenuEntries: dropdownEntries.isNotEmpty? dropdownEntries : [DropdownMenuEntry(value: "", label: "")],
                initialSelection: dropdownValue,
                onSelected: (value) {
                  dropdownValue = value!;
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Total calories: $totalCalories",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
