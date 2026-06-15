import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/widgets/accent_card.dart';
import '../../../shared/theme/widgets/main_shell.dart';
import '../../study_sessions/models/study_session.dart';
import '../../study_sessions/services/study_session_repository.dart';
import '../../study_sessions/presentation/add_edit_session_screen.dart';

/// Weekly Planner — shows the current (or selected) week with one
/// column/section per day, listing that day's study sessions.
class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  final _repo = StudySessionRepository();
  late DateTime _weekStart;

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(DateTime.now());
  }

  DateTime _startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1)); // Monday start
  }

  @override
  Widget build(BuildContext context) {
    final weekEnd = _weekStart.add(const Duration(days: 7));

    return Scaffold(
      appBar: const StudyHubAppBar(title: 'Weekly Planner', showLogo: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditSessionScreen(initialDate: DateTime.now()),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildWeekHeader(weekEnd),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<StudySession>>(
                stream: _repo.watchRange(_weekStart, weekEnd),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final sessions = snapshot.data ?? [];
                  final byDay = <int, List<StudySession>>{};
                  for (final s in sessions) {
                    final dayIndex = s.date.difference(_weekStart).inDays;
                    if (dayIndex < 0 || dayIndex > 6) continue;
                    byDay.putIfAbsent(dayIndex, () => []).add(s);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final date = _weekStart.add(Duration(days: index));
                      final daySessions = byDay[index] ?? [];
                      return _DaySection(
                        dayName: _dayNames[index],
                        date: date,
                        monthNames: _monthNames,
                        sessions: daySessions,
                        isToday: _isSameDay(date, DateTime.now()),
                        onAdd: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditSessionScreen(initialDate: date),
                          ),
                        ),
                        onTapSession: (s) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditSessionScreen(existingSession: s),
                          ),
                        ),
                        onToggle: (s) =>
                            _repo.toggleCompleted(s.id, !s.isCompleted),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekHeader(DateTime weekEnd) {
    final weekEndDisplay = weekEnd.subtract(const Duration(days: 1));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            onPressed: () => setState(
                () => _weekStart = _weekStart.subtract(const Duration(days: 7))),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${_monthNames[_weekStart.month - 1]} ${_weekStart.day} - '
                '${_monthNames[weekEndDisplay.month - 1]} ${weekEndDisplay.day}, ${weekEndDisplay.year}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onPressed: () => setState(
                () => _weekStart = _weekStart.add(const Duration(days: 7))),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.dayName,
    required this.date,
    required this.monthNames,
    required this.sessions,
    required this.isToday,
    required this.onAdd,
    required this.onTapSession,
    required this.onToggle,
  });

  final String dayName;
  final DateTime date;
  final List<String> monthNames;
  final List<StudySession> sessions;
  final bool isToday;
  final VoidCallback onAdd;
  final ValueChanged<StudySession> onTapSession;
  final ValueChanged<StudySession> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : AppColors.chipPurple,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$dayName, ${monthNames[date.month - 1]} ${date.day}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary),
                onPressed: onAdd,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Text(
                'No sessions planned',
                style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    fontSize: 13),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Column(
                children: sessions
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AccentCard(
                            accentColor: s.isCompleted
                                ? AppColors.success
                                : AppColors.primary,
                            padding: const EdgeInsets.all(12),
                            onTap: () => onTapSession(s),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    s.startTime.format(),
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      SubjectChip(label: s.subject),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => onToggle(s),
                                  child: Icon(
                                    s.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: s.isCompleted
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}