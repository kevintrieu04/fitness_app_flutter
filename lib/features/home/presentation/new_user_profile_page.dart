import 'package:fitness_app/design/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_viewmodel.dart';
import '../domain/user_repository.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileDataProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (profileInfo) {
        final data = profileInfo as Map<String, dynamic>? ?? {};
        return Scaffold(
          backgroundColor: DT.bg,
          appBar: AppBar(
            backgroundColor: DT.bg,
            elevation: 0,
            title: const Text(
              "User Profile",
              style: TextStyle(
                color: DT.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Implement settings or keep as secondary logout
                },
                icon: const Icon(Icons.settings, color: DT.textPrimary),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(DT.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserProfileSection(
                  src: data["img_src"] ?? "none",
                  name: data["name"] ?? "Guest",
                  email: data["email"] ?? "Guest Mode",
                ),
                const SizedBox(height: DT.s6),
                _MetricSection(
                  startWeight: (data["startWeight"] ?? 0.0).toDouble(),
                  goalWeight: (data["goalWeight"] ?? 0.0).toDouble(),
                  dailyCalories: (data["dailyCalories"] ?? 0.0).toDouble(),
                ),
                const SizedBox(height: DT.s6),
                _ChallengeSection(
                  streak: data["streak"] ?? 0,
                  tier: data["tier"] ?? 0,
                  level: data["level"] ?? "N/A",
                  bestLevel: data["bestLevel"] ?? "N/A",
                ),
                const SizedBox(height: DT.s6),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserProfileSection extends ConsumerWidget {
  final String src;
  final String name;
  final String email;

  const _UserProfileSection({
    required this.src,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: DT.borderGrey, width: 2),
            boxShadow: [
              BoxShadow(
                color: DT.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              src,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: DT.iconLightGrey,
                child: const Icon(Icons.person, color: DT.iconGrey, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(width: DT.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: DT.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: DT.s1),
              Text(
                email,
                style: const TextStyle(
                  color: DT.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: DT.s3),
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(authViewModelProvider.notifier).signOut();
                  },
                  child: const Text(
                    "Log out",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: DT.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DT.iconLightGrey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DT.s2),
              ),
              child: const Icon(Icons.share, color: DT.iconGrey, size: 10),
            ),
            const SizedBox(height: DT.s2),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DT.iconLightGrey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DT.s2),
              ),
              child: const Icon(Icons.edit, color: DT.iconGrey, size: 10),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricSection extends StatelessWidget {
  const _MetricSection({
    super.key,
    required this.startWeight,
    required this.goalWeight,
    required this.dailyCalories,
  });

  final double startWeight;
  final double goalWeight;
  final double dailyCalories;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            color: DT.metricGreen,
            title: "Start weight",
            value: "$startWeight kg",
          ),
        ),
        const SizedBox(width: DT.s3),
        Expanded(
          child: _MetricCard(
            color: DT.metricBlue,
            title: "Goal",
            value: "$goalWeight kg",
          ),
        ),
        const SizedBox(width: DT.s3),
        Expanded(
          child: _MetricCard(
            color: DT.metricOrange,
            title: "Daily calories",
            value: "$dailyCalories kcal",
          ),
        ),
        const SizedBox(width: DT.s3),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const _MetricCard({
    super.key,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DT.s2),
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DT.rCardSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: DT.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: DT.s1),
          Text(
            value,
            style: const TextStyle(
              color: DT.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeSection extends StatelessWidget {
  const _ChallengeSection({
    super.key,
    required this.streak,
    required this.tier,
    required this.level,
    required this.bestLevel,
  });

  final int streak;
  final int tier;
  final String level;
  final String bestLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChallengeItem(
          icon: Icons.local_fire_department_rounded,
          title: 'Current Streak',
          subtitle: "$streak",
          onTap: () {},
        ),
        _ChallengeItem(
          icon: Icons.fitness_center_rounded,
          title: 'Favorite Exercise',
          subtitle: 'Pushup',
          onTap: () {},
        ),
        _ChallengeItem(
          icon: Icons.star_rounded,
          title: 'Current Level',
          subtitle: "$level Tier $tier",
          onTap: () {},
        ),
        _ChallengeItem(
          icon: Icons.emoji_events_rounded,
          title: 'Best Level',
          subtitle: bestLevel,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ChallengeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChallengeItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DT.s4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: DT.borderLight, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DT.iconLightGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: DT.iconGrey, size: 20),
            ),
            const SizedBox(width: DT.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: DT.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: DT.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: DT.textGrey, size: 16),
          ],
        ),
      ),
    );
  }
}
