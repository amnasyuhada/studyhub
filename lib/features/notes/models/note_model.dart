import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String subject;
  final String subjectColor;
  final List<String> tags;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.subject,
    this.subjectColor = '#4F46E5',
    this.tags = const [],
    this.isBookmarked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      subject: data['subject'] ?? '',
      subjectColor: data['subjectColor'] ?? '#4F46E5',
      tags: List<String>.from(data['tags'] ?? []),
      isBookmarked: data['isBookmarked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'subject': subject,
      'subjectColor': subjectColor,
      'tags': tags,
      'isBookmarked': isBookmarked,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  NoteModel copyWith({
    String? title,
    String? content,
    String? subject,
    String? subjectColor,
    List<String>? tags,
    bool? isBookmarked,
  }) {
    return NoteModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      subjectColor: subjectColor ?? this.subjectColor,
      tags: tags ?? this.tags,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
