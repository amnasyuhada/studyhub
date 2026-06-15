import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/widgets/accent_card.dart';
import '../../../shared/theme/widgets/main_shell.dart';
import '../models/study_group.dart';
import '../services/study_group_repository.dart';
import 'group_detail_screen.dart';

/// Lists the groups the current user belongs to, with buttons to
/// create a new group or join one via a code.
class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  final _repo = StudyGroupRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudyHubAppBar(title: 'Study Groups', showLogo: false),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOrJoinSheet,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: StreamBuilder<List<StudyGroup>>(
          stream: _repo.watchMyGroups(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final groups = snapshot.data ?? [];

            if (groups.isEmpty) {
              return _EmptyState(onCreateOrJoin: _showCreateOrJoinSheet);
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AccentCard(
                    accentColor: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GroupDetailScreen(group: group),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            StatusBadge(
                              label: '${group.memberIds.length} members',
                              color: AppColors.info,
                              icon: Icons.people_alt_rounded,
                            ),
                          ],
                        ),
                        if (group.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            group.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.tag_rounded,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('Code: ${group.joinCode}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showCreateOrJoinSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Study Groups',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create a Group'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showCreateDialog();
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: const Text('Join with Code'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showJoinDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.card)),
          title: const Text('Create Study Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Group name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration:
                    const InputDecoration(hintText: 'Description (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) return;
                      setState(() => saving = true);
                      try {
                        await _repo.createGroup(
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                        );
                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setState(() => saving = false);
                      }
                    },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog() {
    final codeController = TextEditingController();
    String? error;
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.card)),
          title: const Text('Join Study Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(hintText: '6-character code'),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final code = codeController.text.trim();
                      if (code.isEmpty) return;
                      setState(() {
                        saving = true;
                        error = null;
                      });
                      final groupId = await _repo.joinGroupByCode(code);
                      if (groupId == null) {
                        setState(() {
                          saving = false;
                          error = 'No group found with that code.';
                        });
                        return;
                      }
                      if (context.mounted) Navigator.pop(ctx);
                    },
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateOrJoin});

  final VoidCallback onCreateOrJoin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_rounded, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'No study groups yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a group to collaborate with classmates, or join one using a code.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onCreateOrJoin,
              child: const Text('Create or Join a Group'),
            ),
          ],
        ),
      ),
    );
  }
}