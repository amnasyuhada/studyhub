import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/widgets/accent_card.dart';
import '../../../shared/theme/widgets/main_shell.dart';
import '../../study_sessions/models/study_session.dart';
import '../../study_sessions/services/study_session_repository.dart';
import '../../study_sessions/presentation/add_edit_session_screen.dart';

/// Calendar tab — month calendar at top, selected day's sessions below.
/// Matches the "October 2026" mock-up with the "+ Add Schedule" button
/// and "Daily Schedule" list.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _repo = StudySessionRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  static const _weekdayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudyHubAppBar(title: 'Calendar', showLogo: false),
      floatingActionButton: null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildMonthCalendar(),
            const SizedBox(height: 16),
            _buildSelectedDaySummary(),
            const SizedBox(height: 16),
            _buildAddScheduleButton(),
            const SizedBox(height: 20),
            _buildDailyScheduleHeader(),
            const SizedBox(height: 12),
            _buildDailyScheduleList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCalendar() {
    return AccentCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) => _focusedDay = focused,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon:
              Icon(Icons.chevron_left, color: AppColors.textSecondary),
          rightChevronIcon:
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
              color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          weekendStyle: TextStyle(
              color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          outsideTextStyle: const TextStyle(color: AppColors.border),
          todayDecoration: BoxDecoration(
            color: AppColors.chipPurple,
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.bold),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        eventLoader: (day) => _eventMarkerLoader(day),
      ),
    );
  }

  // Placeholder loader so dates with sessions show a dot marker.
  // Backed by a snapshot cache populated via stream below.
  Map<DateTime, List<StudySession>> _markerCache = {};

  List<StudySession> _eventMarkerLoader(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _markerCache[key] ?? [];
  }

  Widget _buildSelectedDaySummary() {
    return StreamBuilder<List<StudySession>>(
      stream: _repo.watchByDate(_selectedDay),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? [];
        final totalMinutes =
            sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
        final hours = (totalMinutes / 60).toStringAsFixed(1);
        final deadlineCount = sessions.where((s) => !s.isCompleted).length;

        return AccentCard(
          accentColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatHeaderDate(_selectedDay),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                sessions.isEmpty
                    ? 'No study sessions scheduled for this day.'
                    : 'You have ${sessions.length} study session${sessions.length == 1 ? '' : 's'} scheduled today.',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusBadge(
                    label: '${hours}h Total Focus',
                    color: AppColors.success,
                    icon: Icons.bolt_rounded,
                  ),
                  if (deadlineCount > 0)
                    StatusBadge(
                      label: '$deadlineCount Pending',
                      color: AppColors.warning,
                      icon: Icons.flag_rounded,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddScheduleButton() {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddEditSessionScreen(initialDate: _selectedDay),
        ),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Add Schedule'),
    );
  }

  Widget _buildDailyScheduleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text('Daily Schedule',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Row(
          children: [
            Icon(Icons.filter_list_rounded,
                size: 18, color: AppColors.primary),
            SizedBox(width: 4),
            Text('Filter',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyScheduleList() {
    return StreamBuilder<List<StudySession>>(
      stream: _repo.watchByDate(_selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final sessions = snapshot.data ?? [];

        // Update marker cache for the visible month (best-effort,
        // doesn't need to be exact for UI purposes).
        _markerCache[DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        )] = sessions;

        if (sessions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No sessions for this day yet.\nTap "Add Schedule" to plan one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return Column(
          children: sessions
              .map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SessionTile(
                      session: s,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditSessionScreen(existingSession: s),
                        ),
                      ),
                      onToggleComplete: () => _repo.toggleCompleted(
                          s.id, !s.isCompleted),
                      onDelete: () => _confirmDelete(s),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Future<void> _confirmDelete(StudySession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card)),
        title: const Text('Delete session?'),
        content: Text('Remove "${session.title}" from your schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repo.deleteSession(session.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session deleted')),
        );
      }
    }
  }

  String _formatHeaderDate(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekday = days[date.weekday - 1];
    return '$weekday, ${months[date.month - 1]} ${date.day}';
  }
}

/// A single row in the daily schedule list, e.g.
/// "09:00 | Deep Work - Data Structures & Algorithms I".
class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });

  final StudySession session;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AccentCard(
      accentColor: session.isCompleted ? AppColors.success : AppColors.primary,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              session.startTime.format(),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: onToggleComplete,
                      child: Icon(
                        session.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: session.isCompleted
                            ? AppColors.success
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                if (session.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      session.notes,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${session.startTime.format()} - ${session.endTime.format()}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const Spacer(),
                    SubjectChip(label: session.subject),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.danger),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}