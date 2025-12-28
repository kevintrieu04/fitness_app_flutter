import 'package:fitness_app/data/counter_data.dart';
import 'package:fitness_app/design/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart' as RV;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.bg,
      appBar: AppBar(
        backgroundColor: DT.bg,
        elevation: 0,
        toolbarHeight: 100,
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: DT.bgWhite, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: DT.shadowMedium,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  "src",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: DT.iconLightGrey,
                    child: const Icon(Icons.person, color: DT.iconGrey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: DT.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hello, Guest!",
                    style: const TextStyle(
                      color: DT.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DT.s1),
                  Text(
                    "Today is ${DateFormat('d MM').format(DateTime.now())}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: DT.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DT.bgWhite,
                borderRadius: BorderRadius.circular(DT.rCardSmall),
                boxShadow: [
                  BoxShadow(
                    color: DT.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.search, color: DT.iconGrey, size: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _DailyChallengeCard(),
            const SizedBox(height: DT.s6),
            _WeeklyListComponent(),
            const SizedBox(height: DT.s6),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: _ExercisesCard(
                      color: DT.cardYellow,
                      exerciseType: ExerciseType.Pushup,
                      difficulty: "Medium",
                      reps: 10,
                      time: 30,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: DT.s4),
                  Expanded(
                    child: _ExercisesCard(
                      color: DT.cardBlue,
                      exerciseType: ExerciseType.Squat,
                      difficulty: "Easy",
                      reps: 5,
                      time: 15,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DT.s4),
            const SizedBox(height: 100),
            _SocialMediaCard(),
          ],
        ),
      ),
    );
  }
}

class _DailyChallengeCard extends StatefulWidget {
  @override
  State<_DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<_DailyChallengeCard> {
  late RV.File file;

  late RV.RiveWidgetController controller;

  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  void _initRive() async {
    file = (await RV.File.asset(
      "assets/images/daily_animation.riv",
      riveFactory: RV.Factory.rive,
    ))!;
    controller = RV.RiveWidgetController(file);
    setState(() => isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DT.s5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DT.challengeGradientStart, DT.challengeGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DT.rCard),
        boxShadow: [
          BoxShadow(
            color: DT.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daily Challenge",
                  style: TextStyle(
                    color: DT.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: DT.s2),
                Text(
                  "You haven't completed your daily challenge yet!",
                  style: TextStyle(color: DT.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: DT.s4),
                Row(
                  children: [
                    _UserChip(imageUrl: "src"),
                    Transform.translate(
                      offset: const Offset(-8, 0),
                      child: _UserChip(imageUrl: "src"),
                    ),
                    Transform.translate(
                      offset: const Offset(-16, 0),
                      child: _UserChip(imageUrl: "src"),
                    ),
                    Transform.translate(
                      offset: const Offset(-24, 0),
                      child: _UserChip(imageUrl: "src"),
                    ),
                    Transform.translate(
                      offset: const Offset(-32, 0),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: DT.bgWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: DT.bgWhite, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            "+4",
                            style: TextStyle(
                              color: DT.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isInitialized
              ? SizedBox(
                  width: 120,
                  height: 120,
                  child: RV.RiveWidget(
                    controller: controller,
                    fit: RV.Fit.contain,
                  ),
                )
              : CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  final String imageUrl;

  const _UserChip({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: DT.bgWhite, width: 2),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: DT.iconLightGrey,
            child: const Icon(Icons.person, color: DT.iconGrey),
          ),
        ),
      ),
    );
  }
}

class _WeeklyListComponent extends StatelessWidget {
  const _WeeklyListComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = startOfWeek.add(Duration(days: index));
          return Container(
            width: 50,
            margin: const EdgeInsets.only(right: DT.s3),
            decoration: BoxDecoration(
              color: date.day == now.day ? DT.bgBlack : DT.bgWhite,
              borderRadius: BorderRadius.circular(DT.rCardSmall),
              boxShadow: [
                BoxShadow(
                  color: DT.shadowMedium,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: date.day == now.day ? DT.textWhite : DT.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('d').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    color: date.day == now.day ? DT.textWhite : DT.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExercisesCard extends StatelessWidget {
  final Color color;
  final ExerciseType exerciseType;
  final String difficulty;
  final int reps;
  final int time;
  final VoidCallback onTap;

  const _ExercisesCard({
    super.key,
    required this.color,
    required this.exerciseType,
    required this.difficulty,
    required this.reps,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DT.s4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(DT.rChip),
          boxShadow: [
            BoxShadow(
              color: DT.shadowMedium,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DT.s2,
                vertical: DT.s1,
              ),
              decoration: BoxDecoration(
                color: DT.bgWhite.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(DT.s2),
              ),
              child: Text(
                exerciseType.name,
                style: const TextStyle(
                  color: DT.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: DT.s3),
            Text(
              difficulty,
              style: const TextStyle(color: DT.textSecondary, fontSize: 12),
            ),
            Text(
              "Numbers of reps: ${reps.toString()}",
              style: const TextStyle(color: DT.textSecondary, fontSize: 12),
            ),
            Text(
              "Duration: ${time.toString()} seconds",
              style: const TextStyle(color: DT.textSecondary, fontSize: 12),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _SocialMediaCard extends StatelessWidget {
  const _SocialMediaCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SocialIcon(icon: Icons.camera_alt, color: DT.socialPink),
          _SocialIcon(icon: Icons.play_circle_outline, color: DT.socialRed),
          _SocialIcon(icon: Icons.chat_bubble_outline, color: DT.socialBlue),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SocialIcon({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: DT.bgWhite,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: DT.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
