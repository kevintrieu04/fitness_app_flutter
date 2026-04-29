//import 'package:camera/camera.dart';
import 'package:fitness_app/utils/data_processors/process_camera.dart';
import 'package:fitness_app/utils/navigators/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design/theme.dart';
import 'firebase_options.dart';

//late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //cameras = await availableCameras();
  await RiveNative.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: const FitnessApp()));
}

class FitnessApp extends ConsumerStatefulWidget {
  const FitnessApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FitnessAppState();
  }
}

class _FitnessAppState extends ConsumerState<FitnessApp> {

  @override
  void dispose() {
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(buildRouterProvider);
    return MaterialApp.router(
      title: 'Fitness App',
      theme: buildTheme(),
      routerConfig: router,
    );
  }
}
