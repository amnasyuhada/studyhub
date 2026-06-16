import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceModel {
  final String id;
  final String userId;
  final String title;
  final String subject;
  final String fileType;
  final String type;
  final String localPath;
  final DateTime uploadedAt;

  ResourceModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.fileType,
    required this.type,
    required this.localPath,
    required this.uploadedAt,
  });

  factory ResourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      fileType: data['fileType'] ?? 'pdf',
      type: data['type'] ?? 'pdf',
      localPath: data['localPath'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'subject': subject,
      'fileType': fileType,
      'type': type,
      'localPath': localPath,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}