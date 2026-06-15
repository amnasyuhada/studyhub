import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/theme/app_theme.dart';
import '../models/study_session.dart';
import '../services/study_session_repository.dart';
import '../../notifications/services/notification_service.dart';

/// Form for creating a new study session or editing an existing one.
/// Pass [existingSession] to edit, or [initialDate] to pre-fill the date
/// when adding from the calendar.
class AddEditSessionScreen extends StatefulWidget {
  const AddEditSessionScreen({
    super.key,
    this.existingSession,
    this.initialDate,
  });

  final StudySession? existingSession;
  final DateTime? initialDate;

  bool get isEditing => existingSession != null;

  @override
  State<AddEditSessionScreen> createState() => _AddEditSessionScreenState();
}

class _AddEditSessionScreenState extends State<AddEditSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = StudySessionRepository();

  late TextEditingController _titleController;
  late TextEditingController _notesController;

  String _subject = 'Computer Science';
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _saving = false;

  static const _subjects = [
    'Computer Science',
    'Information Technology',
    'Mathematics',
    'Risk Management',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSession;

    _titleController = TextEditingController(text: existing?.title ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _subject = existing?.subject ?? _subjects.first;
    _date = existing?.date ?? widget.initialDate ?? DateTime.now();
    _startTime = existing != null
        ? TimeOfDay(
            hour: existing.startTime.hour, minute: existing.startTime.minute)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = existing != null
        ? TimeOfDay(hour: existing.endTime.hour, minute: existing.endTime.minute)
        : const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Session' : 'Add Study Session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Title',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    hintText: 'e.g. Deep Work - Data Structures'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),

              const Text('Subject',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _subject,
                items: _subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _subject = v ?? _subject),
              ),
              const SizedBox(height: 16),

              const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _PickerField(
                icon: Icons.calendar_today_rounded,
                label: _formatDate(_date),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start time',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _PickerField(
                          icon: Icons.access_time_rounded,
                          label: _startTime.format(context),
                          onTap: () => _pickTime(isStart: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End time',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _PickerField(
                          icon: Icons.access_time_filled_rounded,
                          label: _endTime.format(context),
                          onTap: () => _pickTime(isStart: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Notes (optional)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'e.g. Review Binary Trees'),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(widget.isEditing ? 'Save Changes' : 'Add Session'),
              ),

              if (widget.isEditing) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _delete,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger),
                  label: const Text('Delete Session',
                      style: TextStyle(color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.button)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final startMins = _startTime.hour * 60 + _startTime.minute;
    final endMins = _endTime.hour * 60 + _endTime.minute;
    if (endMins <= startMins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    setState(() => _saving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final session = StudySession(
      id: widget.existingSession?.id ?? '',
      title: _titleController.text.trim(),
      subject: _subject,
      date: _date,
      startTime: TimeOfDayValue(_startTime.hour, _startTime.minute),
      endTime: TimeOfDayValue(_endTime.hour, _endTime.minute),
      notes: _notesController.text.trim(),
      isCompleted: widget.existingSession?.isCompleted ?? false,
      ownerId: uid,
    );

    try {
      if (widget.isEditing) {
        await _repo.updateSession(session);
        await NotificationService.instance.rescheduleSessionReminder(session);
      } else {
        final newId = await _repo.addSession(session);
        final saved = StudySession(
          id: newId,
          title: session.title,
          subject: session.subject,
          date: session.date,
          startTime: session.startTime,
          endTime: session.endTime,
          notes: session.notes,
          ownerId: session.ownerId,
        );
        await NotificationService.instance.scheduleSessionReminder(saved);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final session = widget.existingSession;
    if (session == null) return;

    setState(() => _saving = true);
    try {
      await _repo.deleteSession(session.id);
      await NotificationService.instance.cancelSessionReminder(session.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.input),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadii.input),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}