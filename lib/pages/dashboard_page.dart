import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/theme.dart';
import '../core/widgets.dart';
import '../core/utils.dart';
import '../providers/providers.dart';
import '../services/analytics.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final chatData = ref.watch(chatDataProvider);
    
    if (analytics == null || chatData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, chatData.chatName ?? chatData.fileName),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildOverviewCards(analytics)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                _buildParticipantsSection(analytics)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _buildTimelineChart(analytics)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _buildHeatmapSection(analytics)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _buildEmojiSection(analytics)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _buildInsightsSection(analytics)
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref, String title) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background.withOpacity(0.95),
      title: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => resetImport(ref),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverviewCards(ChatAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Messages',
                value: NumberFormatter.compact(analytics.totalMessages),
                icon: Icons.message,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Words',
                value: NumberFormatter.compact(analytics.totalWords),
                icon: Icons.text_fields,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Emojis',
                value: NumberFormatter.compact(analytics.totalEmojis),
                icon: Icons.emoji_emotions,
                color: AppColors.neonYellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Media',
                value: NumberFormatter.compact(analytics.totalMedia),
                icon: Icons.perm_media,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MiniStatTile(
                value: '${analytics.totalDays}',
                label: 'Days',
                color: AppColors.primary,
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              MiniStatTile(
                value: analytics.avgMessagesPerDay.toStringAsFixed(1),
                label: 'Avg/Day',
                color: AppColors.secondary,
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              MiniStatTile(
                value: analytics.avgWordsPerMessage.toStringAsFixed(1),
                label: 'Avg Words',
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsSection(ChatAnalytics analytics) {
    final stats = analytics.participantStats;
    if (stats.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...stats.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          final color = AppColors.chartColors[index % AppColors.chartColors.length];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              borderColor: color.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            stat.participant.name[0].toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat.participant.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${stat.participant.messageCount} messages • ${NumberFormatter.percentage(stat.messagePercentage)}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (stat.topEmojis.isNotEmpty)
                        Text(
                          stat.topEmojis.take(3).map((e) => e.key).join(' '),
                          style: const TextStyle(fontSize: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stat.messagePercentage / 100,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimelineChart(ChatAnalytics analytics) {
    final data = analytics.monthlyMessageCounts;
    if (data.isEmpty) return const SizedBox.shrink();
    
    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message Timeline',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.surfaceLight,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${data[groupIndex].key}\n${rod.toY.toInt()} messages',
                        GoogleFonts.spaceGrotesk(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= data.length) return const Text('');
                        // Show only some labels to avoid crowding
                        if (data.length > 6 && index % 2 != 0) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[index].key.split(' ')[0],
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          NumberFormatter.compact(value.toInt()),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        gradient: AppColors.primaryGradient,
                        width: data.length > 12 ? 8 : 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapSection(ChatAnalytics analytics) {
    final heatmap = analytics.heatmapData;
    final maxValue = heatmap.expand((row) => row).reduce((a, b) => a > b ? a : b);
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Activity Heatmap',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Peak: ${analytics.mostActiveHour}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            children: [
              // Hour labels
              Row(
                children: [
                  const SizedBox(width: 32),
                  ...List.generate(12, (i) => i * 2).map((h) => Expanded(
                    child: Text(
                      h.toString().padLeft(2, '0'),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 4),
              // Heatmap grid
              ...List.generate(7, (dayIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          days[dayIndex],
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      ...List.generate(24, (hourIndex) {
                        final value = heatmap[dayIndex][hourIndex];
                        final intensity = maxValue > 0 ? value / maxValue : 0.0;
                        
                        return Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: intensity == 0
                                    ? AppColors.surfaceLight
                                    : Color.lerp(
                                        AppColors.primary.withOpacity(0.2),
                                        AppColors.primary,
                                        intensity,
                                      ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Less',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ...List.generate(5, (i) => Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? AppColors.surfaceLight
                          : Color.lerp(
                              AppColors.primary.withOpacity(0.2),
                              AppColors.primary,
                              i / 4,
                            ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                  const SizedBox(width: 4),
                  Text(
                    'More',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiSection(ChatAnalytics analytics) {
    final emojis = analytics.topEmojis;
    if (emojis.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Emojis',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emojis.take(20).map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      NumberFormatter.compact(entry.value),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(ChatAnalytics analytics) {
    final insights = analytics.insights;
    if (insights.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fun Insights',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            borderColor: AppColors.accent.withOpacity(0.3),
            child: Row(
              children: [
                Text(
                  insight.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            insight.value,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            insight.description,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
