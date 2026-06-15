import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../../study_sessions/models/study_session.dart';

/// Wraps flutter_local_notifications to schedule / cancel reminders
/// for study sessions.
///
/// Call [NotificationService.init] once in main() before runApp().
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      const channel = AndroidNotificationChannel(
        'study_reminders',
        'Study Reminders',
        description: 'Reminders for upcoming study sessions',
        importance: Importance.high,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  /// Deterministic int ID derived from the Firestore doc id, so the same
  /// session always maps to the same notification (for easy cancel/update).
  int _idFor(String sessionId) => sessionId.hashCode & 0x7FFFFFFF;

  /// Schedules a reminder [minutesBefore] the session start time.
  /// If the resulting time is in the past, no notification is scheduled.
  Future<void> scheduleSessionReminder(
    StudySession session, {
    int minutesBefore = 15,
  }) async {
    await init();

    final sessionDateTime = DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
      session.startTime.hour,
      session.startTime.minute,
    );
    final scheduledTime =
        sessionDateTime.subtract(Duration(minutes: minutesBefore));

    if (scheduledTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      _idFor(session.id),
      'Upcoming study session',
      '${session.title} (${session.subject}) starts in $minutesBefore minutes',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_reminders',
          'Study Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels the reminder for a given session (call on edit/delete).
  Future<void> cancelSessionReminder(String sessionId) async {
    await _plugin.cancel(_idFor(sessionId));
  }

  /// Re-schedules: cancel old, schedule new (call after editing a session).
  Future<void> rescheduleSessionReminder(
    StudySession session, {
    int minutesBefore = 15,
  }) async {
    await cancelSessionReminder(session.id);
    await scheduleSessionReminder(session, minutesBefore: minutesBefore);
  }

  /// Shows an immediate notification, e.g. for group announcements.
  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_reminders',
          'Study Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}