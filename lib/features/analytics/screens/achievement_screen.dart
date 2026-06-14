import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';
import '../data/analytics_model.dart';

class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF4F46E5)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Achievements',
          style: TextStyle(
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: 48),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlocked / ${achievements.length} Unlocked',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      unlocked == achievements.length
                          ? 'All achievements unlocked! 🎉'
                          : '${achievements.length - unlocked} more to go!',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: 180,
                      child: LinearProgressIndicator(
                        value: achievements.isEmpty
                            ? 0
                            : unlocked / achievements.length,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return _AchievementCard(achievement: achievements[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementBadge achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      color: achievement.isUnlocked ? Colors.white : Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.isUnlocked
                    ? Color(0xFF4F46E5).withOpacity(0.1)
                    : Colors.grey.shade200,
              ),
              child: Center(
                child: achievement.isUnlocked
                    ? Text(achievement.icon,
                        style: TextStyle(fontSize: 28))
                    : Icon(Icons.lock_outline,
                        color: Colors.grey, size: 28),
              ),
            ),
            SizedBox(height: 10),
            Text(
              achievement.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: achievement.isUnlocked
                    ? Color(0xFF1A1A2E)
                    : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: 11,
                color: achievement.isUnlocked
                    ? Colors.grey.shade500
                    : Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (achievement.isUnlocked) ...[
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Unlocked ✓',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
