import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(studyStatsProvider);
    final attemptsAsync = ref.watch(analyticsAttemptsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4F46E5)),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text(
          'Progress Analytics',
          style: TextStyle(
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined,
                color: Color(0xFF4F46E5)),
            onPressed: () => context.push('/achievements'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards row
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                  title: 'Quizzes',
                  value: '${stats.totalQuizzes}',
                  icon: Icons.quiz,
                  color: const Color(0xFF4F46E5),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                  title: 'Avg Score',
                  value: '${stats.averageScore.toStringAsFixed(0)}%',
                  icon: Icons.percent,
                  color: Colors.green,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                  title: 'Goals',
                  value: '${stats.completedGoals}/${stats.totalGoals}',
                  icon: Icons.flag,
                  color: Colors.orange,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                  title: 'Study Hours',
                  value: '${stats.totalStudyHours.toStringAsFixed(1)}h',
                  icon: Icons.access_time,
                  color: Colors.purple,
                )),
              ],
            ),
            const SizedBox(height: 24),

            // Bar chart - Quiz scores
            const Text(
              'Quiz Performance',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            attemptsAsync.when(
              loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFF4F46E5))),
              error: (e, _) => Text('Error: $e'),
              data: (attempts) {
                if (attempts.isEmpty) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text('No quiz data yet',
                          style: TextStyle(color: Colors.grey.shade400)),
                    ),
                  );
                }

                final sorted = [...attempts]
                  ..sort(
                      (a, b) => a.dateAttempted.compareTo(b.dateAttempted));
                final recent = sorted.take(7).toList();

                return Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toStringAsFixed(0)}%',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= recent.length) {
                                return const Text('');
                              }
                              return Text(
                                'Q${index + 1}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: recent.asMap().entries.map((e) {
                        final score = e.value.percentage;
                        final color = score >= 80
                            ? Colors.green
                            : score >= 50
                                ? const Color(0xFF4F46E5)
                                : Colors.red;
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: score,
                              color: color,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Line chart - Score trend
            const Text(
              'Score Trend',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            attemptsAsync.when(
              loading: () => const SizedBox(),
              error: (e, _) => const SizedBox(),
              data: (attempts) {
                if (attempts.length < 2) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                          'Complete at least 2 quizzes to see trend',
                          style: TextStyle(color: Colors.grey.shade400),
                          textAlign: TextAlign.center),
                    ),
                  );
                }

                final sorted = [...attempts]
                  ..sort(
                      (a, b) => a.dateAttempted.compareTo(b.dateAttempted));
                final recent = sorted.take(7).toList();

                return Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: LineChart(
                    LineChartData(
                      maxY: 100,
                      minY: 0,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots
                              .map((s) => LineTooltipItem(
                                    '${s.y.toStringAsFixed(0)}%',
                                    const TextStyle(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= recent.length) {
                                return const Text('');
                              }
                              return Text(
                                'Q${index + 1}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: recent.asMap().entries.map((e) {
                            return FlSpot(
                                e.key.toDouble(), e.value.percentage);
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFF4F46E5),
                          barWidth: 3,
                          dotData: FlDotData(
                            getDotPainter: (spot, percent, bar, index) =>
                                FlDotCirclePainter(
                              radius: 5,
                              color: const Color(0xFF4F46E5),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF4F46E5)
                                .withOpacity( 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Goal completion
            const Text(
              'Goal Completion',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Completed Goals',
                            style: TextStyle(color: Colors.grey.shade600)),
                        Text(
                          '${stats.completedGoals} / ${stats.totalGoals}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: stats.totalGoals > 0
                          ? stats.completedGoals / stats.totalGoals
                          : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stats.totalGoals > 0
                          ? '${((stats.completedGoals / stats.totalGoals) * 100).toStringAsFixed(0)}% of your goals completed'
                          : 'No goals yet',
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // View achievements button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/achievements'),
                icon: const Icon(Icons.emoji_events, color: Colors.white),
                label: const Text('View Achievements',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            const SizedBox(height: 4),
            Text(title,
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}