import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fitness_app/utils/counters/lunge_counter.dart';
import 'package:fitness_app/utils/counters/pull_up_counter.dart';
import 'package:fitness_app/utils/counters/squat_counter.dart';
import 'package:fitness_app/utils/painters/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

import '../../../core/data/counter_data.dart';
import '../../../utils/abstract_classes/counter.dart';
import '../../../../utils/counters/push_up_counter.dart';
import '../../../../utils/data_processors/video_processor.dart';
import '../../../utils/counters/bridge_counter.dart';
import '../domain/counter_data_repository.dart';

class CounterTestPage extends ConsumerStatefulWidget {
  const CounterTestPage({
    super.key,
    required this.link,
    required this.exerciseType,
    this.isAsset = false
  });

  final String link;
  final ExerciseType exerciseType;
  final bool isAsset;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CounterTestPageState();
  }
}

class _CounterTestPageState extends ConsumerState<CounterTestPage> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  List<Map<String, dynamic>> _currentLandmarks = [];
  late final Counter _counter;
  Timer? _poseTimer;
  List<Map<String, dynamic>> poseData = [];
  bool _isVideoFinished = false;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    final counterRepo = ref.read(counterDataRepositoryProvider);
    final userWeight = await counterRepo.getUserWeight();

    switch (widget.exerciseType) {
      case ExerciseType.Pushup:
        _counter = PushUpCounter(userWeight: userWeight);
        break;
      case ExerciseType.Squat:
        _counter = SquatCounter(userWeight: userWeight);
        break;
      case ExerciseType.Lunge:
        _counter = LungeCounter(userWeight: userWeight);
        break;
      case ExerciseType.Bridge:
        _counter = BridgeCounter(userWeight: userWeight);
        break;
      case ExerciseType.Pullup:
        _counter = PullUpCounter(userWeight: userWeight);
        break;
    }

    await _initVideo();
    poseData = await _getPoseData(
      videoAssetPath: widget.link,
      type: widget.exerciseType,
    );

    // Add a listener to stop the timer when the video finishes
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position >=
              _videoPlayerController.value.duration &&
          !_isVideoFinished) {
        _poseTimer?.cancel();
        setState(() {
          _isVideoFinished = true;
        });
      }
    });

    // Sync pose data to video time every 200ms (5 fps)
    _poseTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final currentMs = _videoPlayerController.value.position.inMilliseconds;

      // Find closest pose frame based on timestamp
      final frame = poseData.lastWhere(
        (f) => f['timestamp'] <= currentMs,
        orElse: () => poseData.first,
      );

      final landmarks = frame['landmarks'] as List<dynamic>;

      setState(() {
        _currentLandmarks = List<Map<String, dynamic>>.from(landmarks);
      });

      // Count the pushups/squats here
      _counter.updateFromLandmarks(_currentLandmarks);
    });

    // Start the video only after everything is initialized
    _chewieController.play();
  }

  Future<void> _initVideo() async {
    _videoPlayerController = VideoPlayerController.asset(widget.link);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false, // Disable autoPlay
      looping: false, // Disable looping
    );
  }

  Future<List<Map<String, dynamic>>> _getPoseData({
    required String videoAssetPath,
    required ExerciseType type,
  }) async {
    // Preprocess video to get pose data
    final processor = VideoProcessor(
      sourcePath: videoAssetPath,
      isAsset: widget.isAsset,
      frameRate: 5, // Matching the video_player_test_page
    );
    await processor.process();

    // Load the generated JSON
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pose_data', 'reference_pose.json'));
    if (!await file.exists()) {
      throw Exception("reference_pose.json not found for $videoAssetPath");
    }

    final content = await file.readAsString();
    return List<Map<String, dynamic>>.from(
      jsonDecode(content).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(() {});
    _videoPlayerController.dispose();
    if (mounted) {
      _chewieController.dispose();
    }
    _poseTimer?.cancel();
    super.dispose();
  }

  List<Pose> _createPosesFromLandmarks(
    List<Map<String, dynamic>> landmarksData,
  ) {
    if (landmarksData.isEmpty) return [];

    final landmarks = <PoseLandmarkType, PoseLandmark>{};
    for (final lm in landmarksData) {
      try {
        final typeName = lm['type'];
        final type = PoseLandmarkType.values.byName(typeName);
        final landmark = PoseLandmark(
          type: type,
          x: lm['x'].toDouble(),
          y: lm['y'].toDouble(),
          z: 0,
          likelihood: lm['inFrameLikelihood'].toDouble(),
        );
        landmarks[type] = landmark;
      } catch (e) {
        // Ignore landmarks with unknown types
      }
    }
    return [Pose(landmarks: landmarks)];
  }

  bool get _counterCondition {
    if (_counter is PushUpCounter) return _counter.isBackStraight;
    if (_counter is SquatCounter) return _counter.areHipsCorrect;
    if (_counter is LungeCounter) return _counter.verify;
    if (_counter is BridgeCounter) return _counter.isBackStraight;
    if (_counter is PullUpCounter) return _counter.isUp;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('${widget.exerciseType.name} Test')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('${widget.exerciseType.name} Test')),
            body: Center(
              child: Text('Error initializing video: ${snapshot.error}'),
            ),
          );
        }

        final poses = _createPosesFromLandmarks(_currentLandmarks);
        return Scaffold(
          appBar: AppBar(title: Text('${widget.exerciseType.name} Test')),
          body: Stack(
            children: [
              Chewie(controller: _chewieController),
              if (poses.isNotEmpty)
                CustomPaint(
                  painter: PosePainter(
                    poses: poses,
                    imageSize: _videoPlayerController.value.size,
                    isFrontCamera: false,
                    condition: _counterCondition,
                    exerciseType: widget.exerciseType,
                  ),
                  child: Container(),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Count: ${_counter.correctReps}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calories Burnt: ${_counter.caloriesBurnt.toStringAsFixed(2)} kCal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
