import 'package:camera/camera.dart';
import 'package:fitness_app/utils/data_processors/process_camera.dart';
import 'package:fitness_app/utils/navigators/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:rive/rive.dart';
import 'design/theme.dart';
import 'firebase_options.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Hive.initFlutter();
  await Hive.openBox('app_box');
  await RiveNative.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FitnessApp());
}

class FitnessApp extends StatefulWidget {
  const FitnessApp({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FitnessAppState();
  }
}

class _FitnessAppState extends State<FitnessApp> {

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = buildRouter();
    return MaterialApp.router(
      title: 'Fitness App',
      theme: buildTheme(),
      routerConfig: router,
    );
  }
}
