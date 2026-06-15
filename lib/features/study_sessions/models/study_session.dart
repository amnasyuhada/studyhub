import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single study session created by the user.
class StudySession {
  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final TimeOfDayValue startTime;
  final TimeOfDayValue endTime;
  final String notes;
  final bool isCompleted;
  final String ownerId;

  const StudySession({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.notes = '',
    this.isCompleted = false,
    required this.ownerId,
  });

  /// Duration of the session in minutes (for "Total Focus" stats).
  int get durationMinutes {
    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = endTime.hour * 60 + endTime.minute;
    return (endMins - startMins).clamp(0, 24 * 60);
  }

  factory StudySession.fromMap(String id, Map<String, dynamic> map) {
    return StudySession(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: TimeOfDayValue(map['startHour'] ?? 9, map['startMinute'] ?? 0),
      endTime: TimeOfDayValue(map['endHour'] ?? 10, map['endMinute'] ?? 0),
      notes: map['notes'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      ownerId: map['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'date': Timestamp.fromDate(date),
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'notes': notes,
      'isCompleted': isCompleted,
      'ownerId': ownerId,
    };
  }

  StudySession copyWith({
    String? title,
    String? subject,
    DateTime? date,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    String? notes,
    bool? isCompleted,
  }) {
    return StudySession(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      ownerId: ownerId,
    );
  }
}

/// Lightweight, Firestore-friendly stand-in for [TimeOfDay] so this model
/// file has no Flutter UI dependency.
class TimeOfDayValue {
  final int hour;
  final int minute;
  const TimeOfDayValue(this.hour, this.minute);

  String format() {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}