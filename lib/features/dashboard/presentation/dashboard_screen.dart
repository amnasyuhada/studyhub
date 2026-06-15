import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/widgets/accent_card.dart';
import '../../../shared/theme/widgets/main_shell.dart';
import '../../study_sessions/models/study_session.dart';
import '../../study_sessions/services/study_session_repository.dart';
import '../../study_sessions/presentation/add_edit_session_screen.dart';

/// Dashboard / Home tab — greeting, stat cards, weekly progress chart,
/// and a quick view of today's upcoming study sessions.
///
/// "Total Assignments / Deadlines / Quiz Scores" cards are owned by
/// other team members' modules — this screen shows placeholders for
/// those and focuses on the "Study Hours" + "Weekly Progress" +
/// "Active Sessions" sections, which are Member 2's responsibility.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final repo = StudySessionRepository();
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Student';
    final today = DateTime.now();

    return Scaffold(
      appBar: const StudyHubAppBar(title: 'StudyHub'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditSessionScreen(initialDate: today),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Welcome, $userName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              _formatFullDate(today),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildStudyHoursCard(repo, today),
            const SizedBox(height: 16),
            _buildWeeklyProgress(repo, today),
            const SizedBox(height: 20),
            const Text('Today\'s Sessions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildTodaySessions(repo, today, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyHoursCard(StudySessionRepository repo, DateTime today) {
    return StreamBuilder<List<StudySession>>(
      stream: repo.watchByDate(today),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? [];
        final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
        final hours = (totalMinutes / 60).toStringAsFixed(1);

        return AccentCard(
          accentColor: AppColors.warning,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.chipOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timer_outlined, color: AppColors.warning),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Study Hours',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text('${hours}h',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgress(StudySessionRepository repo, DateTime today) {
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return AccentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Weekly Progress',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('This Week',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<StudySession>>(
            stream: repo.watchRange(weekStart, weekEnd),
            builder: (context, snapshot) {
              final sessions = snapshot.data ?? [];
              final minutesPerDay = List<int>.filled(7, 0);
              for (final s in sessions) {
                final idx = s.date.difference(weekStart).inDays;
                if (idx >= 0 && idx < 7) {
                  minutesPerDay[idx] += s.durationMinutes;
                }
              }
              final maxMinutes = (minutesPerDay.reduce((a, b) => a > b ? a : b))
                  .clamp(60, 24 * 60);

              return SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final isToday = i == today.weekday - 1;
                    final heightFraction = minutesPerDay[i] / maxMinutes;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: heightFraction.clamp(0.04, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isToday ? AppColors.primary : AppColors.chipPurple,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(6)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _weekdayLabels[i],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySessions(
      StudySessionRepository repo, DateTime today, BuildContext context) {
    return StreamBuilder<List<StudySession>>(
      stream: repo.watchByDate(today),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return AccentCard(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No sessions today. Tap + to plan one.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        }
        return Column(
          children: sessions
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AccentCard(
                      accentColor: s.isCompleted ? AppColors.success : AppColors.primary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditSessionScreen(existingSession: s),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 56,
                            child: Text(s.startTime.format(),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                SubjectChip(label: s.subject),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: s.isCompleted ? 'Completed' : 'Pending',
                            color: s.isCompleted ? AppColors.success : AppColors.warning,
                            icon: s.isCompleted ? Icons.check_circle : Icons.access_time,
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  String _formatFullDate(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final day = date.day;
    final suffix = (day % 10 == 1 && day != 11)
        ? 'st'
        : (day % 10 == 2 && day != 12)
            ? 'nd'
            : (day % 10 == 3 && day != 13)
                ? 'rd'
                : 'th';
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} $day$suffix, ${date.year}';
  }
}