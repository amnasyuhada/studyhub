import 'package:flutter/material.dart';
import '../../../features/dashboard/presentation/dashboard_screen.dart';
import '../../../features/calendar/presentation/calendar_screen.dart';
import '../../../features/weekly_planner/presentation/weekly_planner_screen.dart';
import '../../../features/study_groups/presentation/study_groups_screen.dart';
import '../app_theme.dart';

/// Root shell holding the bottom navigation bar.
/// Index mapping:
/// 0 = Home (Dashboard)
/// 1 = Calendar
/// 2 = Planner (Weekly Planner)
/// 3 = Groups (Study Groups)
///
/// Note: "Assignments" and "Notes" tabs belong to Member 1 / Member 3's
/// modules. If they already built their own MainShell, ask them to add
/// CalendarScreen / WeeklyPlannerScreen / StudyGroupsScreen as extra tabs
/// instead of using this file directly.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    CalendarScreen(),
    WeeklyPlannerScreen(),
    StudyGroupsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week_rounded),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Groups',
          ),
        ],
      ),
    );
  }
}

/// Shared top app bar used across feature screens, matching the
/// "StudyHub" header with avatar + bell icon seen in the mock-ups.
class StudyHubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StudyHubAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.showLogo = true,
  });

  final String title;
  final VoidCallback? onNotificationTap;
  final bool showLogo;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          if (showLogo) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.chipPurple,
              child: Icon(Icons.person, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Text(title),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          color: AppColors.textPrimary,
          onPressed: onNotificationTap,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}