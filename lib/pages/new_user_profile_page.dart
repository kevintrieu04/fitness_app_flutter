import 'package:fitness_app/design/design_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
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
              src: "src",
              name: "Guest",
              email: "william.strong@my-own-personal-domain.com",
            ),
            const SizedBox(height: DT.s6),
            _MetricSection(),
            const SizedBox(height: DT.s6),
            _ChallengeSection(),
            const SizedBox(height: DT.s6),
          ],
        ),
      ),
    );
  }
}

class _UserProfileSection extends StatelessWidget {
  final String src;
  final String name;
  final String email;

  const _UserProfileSection({
    super.key,
    required this.src,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(
                  color: DT.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: DT.s1),
              Text(
                email,
                style: TextStyle(
                  color: DT.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: DT.s3),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
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
  const _MetricSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            color: DT.metricGreen,
            title: "Start weight",
            value: "53.3 kg",
          ),
        ),
        const SizedBox(width: DT.s3),
        Expanded(
          child: _MetricCard(
            color: DT.metricBlue,
            title: "Goal",
            value: "50.0 kg",
          ),
        ),
        const SizedBox(width: DT.s3),
        Expanded(
          child: _MetricCard(
            color: DT.metricOrange,
            title: "Daily calories",
            value: "740 kcal",
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
    // TODO: implement build
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
  const _ChallengeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChallengeItem(
          icon: Icons.local_fire_department_rounded,
          title: 'Current Streak',
          subtitle: '12',
          onTap: () {},
        ),
        _ChallengeItem(
          icon: Icons.fitness_center_rounded,
          title: 'Favorite Exercise',
          subtitle: 'Pushup',
          onTap: () {},
        ),
        _ChallengeItem(
          icon: Icons.emoji_events_rounded,
          title: 'Best Level',
          subtitle: 'Advanced Tier 2',
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
                color: DT.iconLightGrey.withValues(alpha: 0.1),
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
