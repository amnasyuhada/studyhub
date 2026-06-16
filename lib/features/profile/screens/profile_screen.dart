import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

const kPrimaryColor = Color(0xFF3D3AC1);
const kBackgroundColor = Color(0xFFF0F0F7);
const kCardColor = Colors.white;
const kTextDark = Color(0xFF1A1A2E);
const kTextGrey = Color(0xFF8A8A9A);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) => CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: kBackgroundColor,
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 20, color: kTextDark),
                        ),
                        const Expanded(
                          child: Text('Profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kTextDark)),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: kPrimaryColor.withOpacity(0.15),
                          backgroundImage: profile?['profileImageUrl'] != null
                              ? NetworkImage(profile!['profileImageUrl'])
                              : null,
                          child: profile?['profileImageUrl'] == null
                              ? const Icon(Icons.person_rounded,
                                  size: 52, color: kPrimaryColor)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => context.push('/profile/edit'),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: kPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile?['name'] ?? 'Your Name',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kTextDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style:
                          const TextStyle(fontSize: 13, color: kTextGrey),
                    ),
                    const SizedBox(height: 4),
                    if (profile?['bio'] != null && profile!['bio'] != '')
                      Text(
                        profile['bio'],
                        style:
                            const TextStyle(fontSize: 13, color: kTextGrey),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 140,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => context.push('/profile/edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: const Text('Edit Profile',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  //Quick Access Section
                  const _SectionTitle('Quick Access'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                      children: [
                        _QuickAccessTile(
                          icon: Icons.flag,
                          label: 'Goals',
                          onTap: () => context.push('/study-goals'),
                        ),
                        _QuickAccessTile(
                          icon: Icons.quiz,
                          label: 'Quizzes',
                          onTap: () => context.push('/quiz'),
                        ),
                        _QuickAccessTile(
                          icon: Icons.history,
                          label: 'History',
                          onTap: () => context.push('/quiz-history'),
                        ),
                        _QuickAccessTile(
                          icon: Icons.analytics,
                          label: 'Analytics',
                          onTap: () => context.push('/analytics'),
                        ),
                        _QuickAccessTile(
                          icon: Icons.emoji_events,
                          label: 'Achievements',
                          onTap: () => context.push('/achievements'),
                        ),
                        _QuickAccessTile(
                          icon: Icons.note_alt_outlined,
                          label: 'Notes',
                          onTap: () => context.push('/notes'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Study Statistics
                  _SectionTitle('Study Statistics'),
                  const SizedBox(height: 12),
                  GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: const [
                      _StatCard(
                          icon: Icons.description_outlined,
                          label: 'Notes',
                          value: '18',
                          color: Color(0xFF3D3AC1)),
                      _StatCard(
                          icon: Icons.access_time_outlined,
                          label: 'This Week',
                          value: '6h',
                          color: Color(0xFFE05C2A)),
                      _StatCard(
                          icon: Icons.quiz_outlined,
                          label: 'Quizzes',
                          value: '12',
                          color: Color(0xFF2EAA6E)),
                      _StatCard(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Day Streak',
                          value: '5🔥',
                          color: Color(0xFFF5A623)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Weekly Study Goal
                  _SectionTitle('Weekly Study Goal'),
                  const SizedBox(height: 12),
                  _GoalCard(),
                  const SizedBox(height: 24),

                  // Account Information
                  _SectionTitle('Account Information'),
                  const SizedBox(height: 12),
                  _InfoCard(children: [
                    _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: profile?['name'] ?? 'Not set'),
                    const Divider(height: 1, color: kBackgroundColor),
                    _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? ''),
                    const Divider(height: 1, color: kBackgroundColor),
                    _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Student ID',
                        value: profile?['studentId'] ?? 'Not set'),
                    const Divider(height: 1, color: kBackgroundColor),
                    _InfoRow(
                        icon: Icons.info_outline,
                        label: 'Bio',
                        value: profile?['bio'] ?? 'Not set'),
                  ]),
                  const SizedBox(height: 24),

                  // Account Settings
                  _SectionTitle('Preferences'),
                  const SizedBox(height: 12),
                  _InfoCard(children: [
                    _NavRow(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {}),
                    const Divider(height: 1, color: kBackgroundColor),
                    _NavRow(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        onTap: () {}),
                    const Divider(height: 1, color: kBackgroundColor),
                    _NavRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Reminder Preferences',
                        onTap: () {}),
                  ]),
                  const SizedBox(height: 24),

                  // Security
                  _SectionTitle('Security'),
                  const SizedBox(height: 12),
                  _InfoCard(children: [
                    _NavRow(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      onTap: () => _showChangePasswordDialog(context, ref),
                    ),
                    const Divider(height: 1, color: kBackgroundColor),
                    _NavRow(
                      icon: Icons.mark_email_read_outlined,
                      label: 'Verify Email',
                      trailing: user?.emailVerified == true
                          ? const Icon(Icons.verified,
                              color: Colors.green, size: 18)
                          : const Text('Unverified',
                              style: TextStyle(
                                  color: Colors.orange, fontSize: 12)),
                      onTap: () async {
                        if (user?.emailVerified == false) {
                          await ref
                              .read(authRepositoryProvider)
                              .sendEmailVerification();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Verification email sent!')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1, color: kBackgroundColor),
                    _NavRow(
                      icon: Icons.logout,
                      label: 'Logout',
                      iconColor: Colors.red,
                      labelColor: Colors.red,
                      onTap: () => _showLogoutDialog(context, ref),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // About
                  _SectionTitle('About'),
                  const SizedBox(height: 12),
                  _InfoCard(children: [
                    _NavRow(
                        icon: Icons.info_outline,
                        label: 'About StudyHub',
                        onTap: () {}),
                    const Divider(height: 1, color: kBackgroundColor),
                    _NavRow(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {}),
                    const Divider(height: 1, color: kBackgroundColor),
                    _NavRow(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () {}),
                  ]),
                  const SizedBox(height: 24),

                  // Delete Account
                  Center(
                    child: TextButton(
                      onPressed: () => _showDeleteDialog(context, ref),
                      child: const Text('Delete Account',
                          style:
                              TextStyle(color: Colors.red, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            child:
                const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account'),
        content: const Text(
            'This action is permanent and cannot be undone. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New Password',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () async {
              if (controller.text.length >= 6) {
                await ref
                    .read(authRepositoryProvider)
                    .changePassword(controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password updated successfully')),
                  );
                }
              }
            },
            child: const Text('Update',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: kTextDark));
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: kTextGrey))),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextDark)),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;

  const _NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: kPrimaryColor.withOpacity(0.1),
      highlightColor: kPrimaryColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? kPrimaryColor),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        color: labelColor ?? kTextDark))),
            trailing ??
                const Icon(Icons.chevron_right,
                    color: kTextGrey, size: 18),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: kTextGrey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Weekly Goal',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextDark)),
              Text('6h / 10h',
                  style: TextStyle(fontSize: 13, color: kTextGrey)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: kBackgroundColor,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          ),
          const SizedBox(height: 6),
          const Text('60% completed',
              style: TextStyle(fontSize: 12, color: kTextGrey)),
        ],
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: kPrimaryColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}