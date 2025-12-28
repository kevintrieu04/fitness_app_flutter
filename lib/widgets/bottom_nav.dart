import 'package:fitness_app/design/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

class BottomNavScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;

  const BottomNavScaffold({super.key, required this.shell});

  void _onTap(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color:  DT.bg
        ),
        child: Container(
          decoration: BoxDecoration(
            color: DT.bgBlack,
            borderRadius: BorderRadius.circular(30),
          ),
          margin: EdgeInsets.only(bottom: 32, top: 8, left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                isSelected: shell.currentIndex == 0,
                onTap: () => _onTap(0),
              ),
              _NavItem(
                  icon: Icons.fitness_center_outlined,
                  isSelected: shell.currentIndex == 1,
                  onTap: () => _onTap(1)
              ),
              _NavItem(
                icon: Icons.person_outline,
                isSelected: shell.currentIndex == 2,
                onTap: () => _onTap(2)
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? DT.bg : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? DT.bottomNavBg : DT.bg,
          size: DT.s6,
        ),
      ),
    );
  }
}
