import 'package:cloud_firestore/cloud_firestore.dart';

/// A study group that multiple users can join.
class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final String joinCode;
  final DateTime createdAt;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.joinCode,
    required this.createdAt,
  });

  factory StudyGroup.fromMap(String id, Map<String, dynamic> map) {
    return StudyGroup(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ownerId: map['ownerId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? const []),
      joinCode: map['joinCode'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'joinCode': joinCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// An announcement posted by a group owner/member.
class GroupAnnouncement {
  final String id;
  final String authorId;
  final String authorName;
  final String message;
  final DateTime createdAt;

  const GroupAnnouncement({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.message,
    required this.createdAt,
  });

  factory GroupAnnouncement.fromMap(String id, Map<String, dynamic> map) {
    return GroupAnnouncement(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Member',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// A post on the group's discussion board.
class DiscussionPost {
  final String id;
  final String authorId;
  final String authorName;
  final String message;
  final DateTime createdAt;

  const DiscussionPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.message,
    required this.createdAt,
  });

  factory DiscussionPost.fromMap(String id, Map<String, dynamic> map) {
    return DiscussionPost(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Member',
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}