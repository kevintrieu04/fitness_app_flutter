import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fitness_app/data/counter_data.dart';
import 'package:fitness_app/utils/counters/lunge_counter.dart';
import 'package:fitness_app/utils/counters/pull_up_counter.dart';
import 'package:fitness_app/utils/counters/squat_counter.dart';
import 'package:fitness_app/utils/data_processors/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

import '../../utils/abstract_classes/counter.dart';
import '../../../utils/counters/push_up_counter.dart';
import '../../../utils/data_processors/video_processor.dart';
import '../../utils/counters/bridge_counter.dart';

class DailyTestPage extends StatefulWidget {
  const DailyTestPage({
    super.key,
    required this.link,
    required this.exerciseType,
    required this.userWeight,
    required this.targetReps,
    required this.timeLimit,
  });

  final String link;
  final ExerciseType exerciseType;
  final double userWeight;
  final int targetReps;
  final int timeLimit;

  @override
  _DailyTestPageState createState() => _DailyTestPageState();
}

class _DailyTestPageState extends State<DailyTestPage> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  List<Map<String, dynamic>> _currentLandmarks = [];
  late final Counter _counter;
  Timer? _poseTimer;
  Timer? _countdownTimer;
  int _countdownValue = 3;
  List<Map<String, dynamic>> poseData = [];
  bool _isVideoFinished = false;
  bool _isLoading = true;
  bool _isPassed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    switch (widget.exerciseType) {
      case ExerciseType.Pushup:
        _counter = PushUpCounter(userWeight: widget.userWeight);
        break;
      case ExerciseType.Squat:
        _counter = SquatCounter(userWeight: widget.userWeight);
        break;
      case ExerciseType.Lunge:
        _counter = LungeCounter(userWeight: widget.userWeight);
        break;
      case ExerciseType.Bridge:
        _counter = BridgeCounter(userWeight: widget.userWeight);
        break;
      case ExerciseType.Pullup:
        _counter = PullUpCounter(userWeight: widget.userWeight);
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

    // Start a 3-second countdown before playing the video
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownValue--;
      });
      if (_countdownValue == 0) {
        timer.cancel();
        _isLoading = false;
        _chewieController.play();
      }
    });

    // Add a timer to stop the video if timer duration is shorter than video length
    final videoDuration = _videoPlayerController.value.duration;
    if (Duration(seconds: widget.timeLimit) < videoDuration) {
      Timer(const Duration(seconds: 30), () {
        if (_videoPlayerController.value.isPlaying) {
          _videoPlayerController.pause();
          _poseTimer?.cancel();
          _isVideoFinished = true;
        }
      });
    }
  }

  Future<void> _initVideo() async {
    _videoPlayerController = VideoPlayerController.asset(widget.link);
    await _videoPlayerController.initialize();
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false, // Disable autoPlay
        looping: false, // Disable looping
      );
    });
  }

  Future<List<Map<String, dynamic>>> _getPoseData({
    required String videoAssetPath,
    required ExerciseType type,
  }) async {
    // Preprocess video to get pose data
    final processor = VideoProcessor(
      sourcePath: videoAssetPath,
      isAsset: true,
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
    _countdownTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final poses = _createPosesFromLandmarks(_currentLandmarks);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.exerciseType.name} Test')),
      body: _videoPlayerController.value.isInitialized
          ? Stack(
              children: [
                Chewie(controller: _chewieController),
                if (poses.isNotEmpty)
                  CustomPaint(
                    painter: PosePainter(
                      poses: poses,
                      imageSize: _videoPlayerController.value.size,
                      isFrontCamera: false,
                      isBackStraight: _counter is PushUpCounter
                          ? _counter.isBackStraight
                          : true,
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
                        if (_isLoading)
                          Text("Waiting for the video to load...")
                        else if (!_isVideoFinished) ...[
                          Text(
                            'Count: ${_counter.count}',
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
                        ] else ...[
                          Text("Exercise Finished!"),
                          ElevatedButton(
                            onPressed: () {
                              if (_counter.count >= widget.targetReps) {
                                _isPassed = true;
                              }
                              Navigator.of(context).pop(_isPassed);
                            },
                            child: Text("Return"),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_countdownValue > 0)
                  Center(
                    child: Text(
                      '$_countdownValue',
                      style: TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
