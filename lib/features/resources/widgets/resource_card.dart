import 'package:flutter/material.dart';
import '../models/resource_model.dart';
import '../screens/pdf_viewer_screen.dart';
import '../screens/image_viewer_screen.dart';

class ResourceCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // In the build method, replace the onTap:
      onTap: () {
        if (resource.fileType == 'pdf') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerScreen(
                title: resource.title,
                filePath: resource.localPath,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewerScreen(
                title: resource.title,
                filePath: resource.localPath,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            // Dynamic icon based on file type
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: resource.fileType == 'pdf' 
                    ? const Color(0xFFEEF2FF) 
                    : const Color(0xFFFCE7F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                resource.fileType == 'pdf' 
                    ? Icons.picture_as_pdf 
                    : Icons.image,
                color: resource.fileType == 'pdf' 
                    ? const Color(0xFF4F46E5) 
                    : const Color(0xFFDB2777),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // File type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: resource.fileType == 'pdf'
                              ? const Color(0xFF4F46E5).withOpacity(0.1)
                              : const Color(0xFFDB2777).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          resource.fileType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: resource.fileType == 'pdf'
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFFDB2777),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          resource.subject,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time_outlined,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(resource.uploadedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}