import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/resources_provider.dart';
import '../models/resource_model.dart';
import '../widgets/resource_card.dart';
import 'pdf_viewer_screen.dart';
import 'image_viewer_screen.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final Map<String, String> _subjects = {
    'Computer Science': '#4F46E5',
    'Mathematics': '#2563EB',
    'Physics': '#059669',
    'Engineering': '#D97706',
    'Business': '#0891B2',
    'Other': '#6B7280',
  };
  
  String? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(resourcesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Resource Library',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF6B7280)),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSubjectFilter(),
          Expanded(
            child: resourcesAsync.when(
              data: (resources) {
                final filtered = _selectedSubject == null
                    ? resources
                    : resources.where((r) => r.subject == _selectedSubject).toList();
                
                if (filtered.isEmpty) {
                  return _buildEmptyState(_selectedSubject != null);
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final resource = filtered[index];
                    return ResourceCard(
                      resource: resource,
                      onTap: () => _openResource(resource),
                      onDelete: () => _confirmDelete(resource),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadOptions,
        backgroundColor: const Color(0xFF4F46E5),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSubjectFilter() {
    // Sort subjects with "Other" at the end
    final sortedSubjects = _subjects.keys.toList()
      ..sort((a, b) {
        if (a == 'Other') return 1;
        if (b == 'Other') return -1;
        return a.compareTo(b);
      });

    return Container(
      height: 56,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isSelected: _selectedSubject == null,
              onTap: () => setState(() => _selectedSubject = null),
            ),
            const SizedBox(width: 8),
            ...sortedSubjects.map((subject) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: subject,
                isSelected: _selectedSubject == subject,
                onTap: () => setState(() => _selectedSubject = subject),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF4F46E5).withOpacity(0.1), const Color(0xFF7C3AED).withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                hasFilter ? Icons.search_off : Icons.folder_open,
                size: 44,
                color: hasFilter ? Colors.grey.shade400 : const Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilter ? 'No resources in this subject' : 'No resources yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter 
                ? 'Try selecting a different subject filter' 
                : 'Tap the + button to upload PDF or Image study materials',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile(String fileType) async {
    FilePickerResult? result;

    if (fileType == 'pdf') {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
    }

    if (result == null) return;

    final file = result.files.single;
    _showSubjectDialog(file, fileType);
  }

  void _showSubjectDialog(PlatformFile file, String fileType) {
    String? selectedSubject = _subjects.keys.first;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add ${fileType.toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('File: ${file.name}'),
            const SizedBox(height: 8),
            Text('Type: ${fileType.toUpperCase()}'),
            const SizedBox(height: 16),
            const Text('Choose a subject:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: _subjects.keys.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) => selectedSubject = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Save to Firestore
              await ref.read(resourcesNotifierProvider.notifier).addResource(
                title: file.name.replaceAll(RegExp(r'\.[^.]+$'), ''), // Remove extension
                subject: selectedSubject!,
                fileType: fileType,
                localPath: file.path!,
              );
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${fileType.toUpperCase()} uploaded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

    void _openResource(ResourceModel resource) {
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
  }

  void _confirmDelete(ResourceModel resource) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Resource'),
        content: Text('Delete "${resource.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(resourcesNotifierProvider.notifier).deleteResource(resource.id);
              Navigator.pop(ctx);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resource deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Resource Library'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Upload PDF study materials'),
            SizedBox(height: 8),
            Text('• Organize by subject'),
            SizedBox(height: 8),
            Text('• Access your resources anytime'),
            SizedBox(height: 8),
            Text('• PDFs are stored locally on your device'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload Resource',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the type of resource to upload',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadOption(
                      icon: Icons.picture_as_pdf,
                      label: 'PDF',
                      color: const Color(0xFF4F46E5),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickAndUploadFile('pdf');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUploadOption(
                      icon: Icons.image,
                      label: 'Image',
                      color: const Color(0xFFDB2777),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickAndUploadFile('image');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}