import 'package:fitness_app/design/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/counter_data.dart';

class CounterOptionPage extends StatelessWidget {
  const CounterOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.bg,
      appBar: AppBar(
        backgroundColor: DT.bg,
        elevation: 0,
        title: const Text(
          "Exercise Counter",
          style: TextStyle(
            color: DT.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DT.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Exercises",
              style: TextStyle(
                color: DT.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DT.s2),
            const Text(
              "Chosse your workout session",
              style: TextStyle(
                color: DT.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DT.s6),
            _ExercisesCard(
              exerciseType: ExerciseType.Pushup,
              shortDescription:
                  "Pushups are one of the crucial exercises in working out. The following texts are just to test overflow",
              imageLink: "assets/images/push_up.jpg",
              color: DT.cardYellow,
              importance: "Medium",
            ),
            const SizedBox(height: DT.s4),
            _ExercisesCard(
              exerciseType: ExerciseType.Squat,
              shortDescription:
                  "Squat are one of the crucial exercises in working out. The following texts are just to test overflow",
              imageLink: "assets/images/squat.jpg",
              color: DT.cardBlue,
              importance: "Easy",
            ),
            const SizedBox(height: DT.s4),
            _ExercisesCard(
              exerciseType: ExerciseType.Lunge,
              shortDescription:
                  "Lunge are one of the crucial exercises in working out. The following texts are just to test overflow",
              imageLink: "assets/images/lunge.webp",
              color: DT.cardRed,
              importance: "Hard",
            ),
            const SizedBox(height: DT.s4),
            _ExercisesCard(
              exerciseType: ExerciseType.Bridge,
              shortDescription:
                  "Glute Bridge are one of the crucial exercises in working out. The following texts are just to test overflow",
              imageLink: "assets/images/bridge.webp",
              color: DT.cardOrange,
              importance: "Medium",
            ),
            const SizedBox(height: DT.s4),
            _ExercisesCard(
              exerciseType: ExerciseType.Pullup,
              shortDescription:
                  "Pullup are one of the crucial exercises in working out. The following texts are just to test overflow",
              imageLink: "assets/images/pullup.webp",
              color: DT.cardTeal,
              importance: "Easy",
            ),
            const SizedBox(height: DT.s4),
          ],
        ),
      ),
    );
  }
}

class _ExercisesCard extends StatelessWidget {
  final ExerciseType exerciseType;
  final String importance;
  final String shortDescription;
  final String imageLink;
  final Color color;

  const _ExercisesCard({
    super.key,
    required this.exerciseType,
    required this.shortDescription,
    required this.imageLink,
    required this.color,
    required this.importance,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          "counter_test_options",
          queryParameters: {"exerciseType": exerciseType.name},
        );
      },
      child: Container(
        padding: EdgeInsets.all(DT.s5),
        decoration: BoxDecoration(
          color: DT.bgWhite,
          borderRadius: BorderRadius.circular(DT.s5),
          border: Border.all(color: DT.bgWhite, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: DT.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(imageLink, fit: BoxFit.cover),
                        ),
                      ),
                      Text(
                        exerciseType.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: DT.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DT.s2,
                          vertical: DT.s1,
                        ),
                        decoration: BoxDecoration(
                          color: _getImportanceColor(
                            importance,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(DT.s2),
                        ),
                        child: Text(
                          importance,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DT.s2),
                  Text(
                    shortDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: DT.textSecondary,
                      height: 1.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DT.s3),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.access_time,
                        text: "30 to 60 seconds",
                      ),
                      const Spacer(),
                      _InfoChip(
                        icon: Icons.fitness_center_outlined,
                        text: "15 to 30 reps",
                      ),
                    ],
                  ),
                  const SizedBox(height: DT.s4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DT.rChip),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: DT.iconGrey),
        const SizedBox(width: DT.s1),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: DT.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

Color _getImportanceColor(String importance) {
  switch (importance) {
    case "Easy":
      return DT.difficultyLight;
    case "Medium":
      return DT.difficultyMedium;
    case "Hard":
      return DT.difficultyHard;
    default:
      return DT.iconGrey;
  }
}
