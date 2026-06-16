import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Default subjects 
const _defaultSubjects = {
  'Mathematics': '#2563EB',
  'Language': '#DC2626',
  'Business': '#0891B2',
  'Other': '#6B7280',
};

// Color palette for custom subjects 
const _colorPalette = [
  '#4F46E5', '#7C3AED', '#2563EB', '#059669',
  '#D97706', '#DB2777', '#DC2626', '#0891B2',
  '#0D9488', '#65A30D', '#EA580C', '#6B7280',
];

final userSubjectsProvider =
    StateProvider<Map<String, String>>((ref) => Map.from(_defaultSubjects));

class AddEditNoteScreen extends ConsumerStatefulWidget {
  final NoteModel? note;
  const AddEditNoteScreen({super.key, this.note});

  @override
  ConsumerState<AddEditNoteScreen> createState() =>
      _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final TextEditingController _tagCtrl = TextEditingController();
  late String _subject;
  late String _subjectColor;
  late List<String> _tags;
  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _tags = List.from(widget.note?.tags ?? []);

    final subjects = ref.read(userSubjectsProvider);
    if (widget.note != null) {
      _subject = widget.note!.subject;
      _subjectColor = widget.note!.subjectColor;
    } else {
      _subject = subjects.keys.first;
      _subjectColor = subjects.values.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updated = widget.note!.copyWith(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          subject: _subject,
          subjectColor: _subjectColor,
          tags: _tags,
        );
        await ref.read(notesNotifierProvider.notifier).updateNote(updated);
      } else {
        await ref.read(notesNotifierProvider.notifier).createNote(
              title: _titleCtrl.text.trim(),
              content: _contentCtrl.text.trim(),
              subject: _subject,
              subjectColor: _subjectColor,
              tags: _tags,
            );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving note: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
    _tagCtrl.clear();
  }

  // ─── FORMATTING METHODS ──────────────────────────────────────────────────────
  
  /// Insert formatting like **bold** or *italic* around selected text
  void _insertFormatting(String prefix, String suffix) {
    final text = _contentCtrl.text;
    final selection = _contentCtrl.selection;
    final start = selection.start.clamp(0, text.length);
    final end = selection.end.clamp(0, text.length);

    if (selection.isValid && start != end) {
      final selectedText = text.substring(start, end);
      final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');
      _contentCtrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: start + prefix.length,
          extentOffset: end + prefix.length,
        ),
      );
    } else {
      final cursor = start < 0 ? 0 : start;
      final newText = text.replaceRange(cursor, cursor, '$prefix$suffix');
      _contentCtrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor + prefix.length),
      );
    }
    setState(() {});
    // ❌ The FocusScope line that was here is now gone
  }

  /// Insert a bullet point at the start of the current line
  void _insertBullet() {
    final text = _contentCtrl.text;
    final selection = _contentCtrl.selection;
    final start = selection.start;
    
    // Find the start of the current line
    int lineStart = start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }
    
    final newText = text.replaceRange(lineStart, lineStart, '- ');
    _contentCtrl.text = newText;
    _contentCtrl.selection = TextSelection(
      baseOffset: start + 2,
      extentOffset: start + 2,
    );
    setState(() {});
  }

  /// Insert a numbered list item with auto-incrementing numbers
  void _insertNumbered() {
    final text = _contentCtrl.text;
    final selection = _contentCtrl.selection;
    final start = selection.start;
    
    // Find the start of the current line
    int lineStart = start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }
    
    // Count previous numbered items
    final lines = text.substring(0, lineStart).split('\n');
    int number = 1;
    for (int i = lines.length - 1; i >= 0; i--) {
      final match = RegExp(r'^(\d+)\. ').firstMatch(lines[i]);
      if (match != null) {
        number = int.parse(match.group(1)!) + 1;
        break;
      }
    }
    
    final newText = text.replaceRange(lineStart, lineStart, '$number. ');
    _contentCtrl.text = newText;
    _contentCtrl.selection = TextSelection(
      baseOffset: start + ('$number. '.length),
      extentOffset: start + ('$number. '.length),
    );
    setState(() {});
  }

  // ─── SHOW ADD SUBJECT SHEET ──────────────────────────────────────────────
  void _showAddSubjectSheet() {
    final nameCtrl = TextEditingController();
    String pickedColor = _colorPalette[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F6FA),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Add Custom Subject',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 6),
                  const Text('Create a subject for any course or field',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Fine Arts, Japanese, Psychology...',
                      hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF4F46E5), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Pick a colour',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _colorPalette.map((hex) {
                      final color = Color(
                          int.parse(hex.replaceFirst('#', '0xFF')));
                      final isSelected = pickedColor == hex;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => pickedColor = hex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white, width: 2.5)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2))
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                                  pickedColor.replaceFirst('#', '0xFF')))
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(int.parse(pickedColor
                                    .replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              nameCtrl.text.isEmpty
                                  ? 'Preview'
                                  : nameCtrl.text,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(int.parse(pickedColor
                                      .replaceFirst('#', '0xFF')))),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please enter a subject name')),
                            );
                            return;
                          }
                          final current =
                              ref.read(userSubjectsProvider);
                          ref
                              .read(userSubjectsProvider.notifier)
                              .state = {...current, name: pickedColor};
                          setState(() {
                            _subject = name;
                            _subjectColor = pickedColor;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('Add',
                            style:
                                TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── MANAGE SUBJECTS ──────────────────────────────────────────────────────
  void _showManageSubjectsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final subjects = ref.watch(userSubjectsProvider);
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Manage Subjects',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  const Text('Swipe left or tap delete to remove a subject',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.4,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: subjects.entries.map((entry) {
                        final color = Color(int.parse(
                            entry.value.replaceFirst('#', '0xFF')));
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.circle,
                                color: color, size: 14),
                          ),
                          title: Text(entry.key,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151))),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () {
                              final current =
                                  ref.read(userSubjectsProvider);
                              if (current.length <= 1) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'You need at least one subject'),
                                ));
                                return;
                              }
                              final updated =
                                  Map<String, String>.from(current)
                                    ..remove(entry.key);
                              ref
                                  .read(userSubjectsProvider.notifier)
                                  .state = updated;
                              if (_subject == entry.key) {
                                setState(() {
                                  _subject = updated.keys.first;
                                  _subjectColor = updated.values.first;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── BUILD METHODS ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(userSubjectsProvider);

    if (!subjects.containsKey(_subject)) {
      _subject = subjects.keys.first;
      _subjectColor = subjects.values.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF4F46E5), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Note' : 'New Note',
          style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSubjectSelector(subjects),
            const SizedBox(height: 16),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildContentField(),
            const SizedBox(height: 16),
            _buildTagsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelector(Map<String, String> subjects) {
    final sortedEntries = subjects.entries.toList()
      ..sort((a, b) {
        if (a.key == 'Other') return 1;
        if (b.key == 'Other') return -1;
        return a.key.compareTo(b.key);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Subject',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151))),
            const Spacer(),
            GestureDetector(
              onTap: _showManageSubjectsSheet,
              child: const Text('Manage',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...sortedEntries.map((entry) {
              final color = Color(
                  int.parse(entry.value.replaceFirst('#', '0xFF')));
              final isSelected = _subject == entry.key;
              return GestureDetector(
                onTap: () => setState(() {
                  _subject = entry.key;
                  _subjectColor = entry.value;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: _showAddSubjectSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Color(0xFF6B7280)),
                    SizedBox(width: 4),
                    Text('Add new',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Title',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleCtrl,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827)),
          decoration:
              _inputDecoration('e.g. Data Structures & Algorithms I'),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Please enter a title'
              : null,
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──────────────────────────────────────────────────────
        Row(
          children: [
            const Text('Content',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151))),
            const Spacer(),
            Text(
              'Markdown supported',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── Formatting toolbar ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _FormatButton(
                icon: Icons.format_bold,
                onTap: () => _insertFormatting('**', '**'),
                tooltip: 'Bold (**text**)',
              ),
              _FormatButton(
                icon: Icons.format_italic,
                onTap: () => _insertFormatting('*', '*'),
                tooltip: 'Italic (*text*)',
              ),
              const SizedBox(width: 4),
              Container(width: 1, height: 20, color: Colors.grey.shade300),
              const SizedBox(width: 4),
              _FormatButton(
                icon: Icons.format_list_bulleted,
                onTap: () => _insertBullet(),
                tooltip: 'Bullet list (- )',
              ),
              _FormatButton(
                icon: Icons.format_list_numbered,
                onTap: () => _insertNumbered(),
                tooltip: 'Numbered list (1. )',
              ),
              const SizedBox(width: 4),
              Container(width: 1, height: 20, color: Colors.grey.shade300),
              const SizedBox(width: 4),
              _FormatButton(
                icon: Icons.code,
                onTap: () => _insertFormatting('`', '`'),
                tooltip: 'Code (`code`)',
              ),
              _FormatButton(
                icon: Icons.format_quote,
                onTap: () => _insertFormatting('> ', ''),
                tooltip: 'Quote (> )',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Text editor ──────────────────────────────────────────────────────
        TextFormField(
          controller: _contentCtrl,
          maxLines: 8,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
            height: 1.7,
          ),
          decoration: _inputDecoration('Write your notes here...').copyWith(
            alignLabelWithHint: true,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Please enter some content'
              : null,
          onChanged: (_) => setState(() {}), // triggers live preview rebuild
        ),
        const SizedBox(height: 12),

        // ── Live preview (appears automatically as you type) ─────────────────
        if (_contentCtrl.text.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: MarkdownBody(
                  data: _contentCtrl.text,
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    p: const TextStyle(
                        fontSize: 14, color: Color(0xFF374151), height: 1.7),
                    code: const TextStyle(
                      fontSize: 13,
                      backgroundColor: Color(0xFFF3F4F6),
                      color: Color(0xFF4F46E5),
                    ),
                    blockquote: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151))),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagCtrl,
                onSubmitted: _addTag,
                decoration:
                    _inputDecoration('Add a tag and press Enter'),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _addTag(_tagCtrl.text),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _tags
                .map((t) => Chip(
                      label: Text(t,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.w500)),
                      backgroundColor: const Color(0xFFEEF2FF),
                      deleteIcon: const Icon(Icons.close,
                          size: 14, color: Color(0xFF4F46E5)),
                      onDeleted: () =>
                          setState(() => _tags.remove(t)),
                      side: BorderSide.none,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.red, width: 1.5)),
    );
  }
}

// ─── HELPER WIDGET ────────────────────────────────────────────────────────────

class _FormatButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _FormatButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.grey.shade700),
        onPressed: onTap,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        splashRadius: 16,
      ),
    );
  }
}
