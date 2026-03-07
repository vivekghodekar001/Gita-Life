import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/japa_provider.dart';
import '../../models/japa_log.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';

class JapaHistoryScreen extends ConsumerWidget {
  const JapaHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekAsync = ref.watch(weekHistoryProvider);
    final monthAsync = ref.watch(monthHistoryProvider);

    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF4A2C0A)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      'JAPA HISTORY',
                      style: GoogleFonts.jost(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B6914).withOpacity(0.5),
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: weekAsync.when(
                  loading: () => ShimmerLoading.card(count: 2),
                  error: (err, stack) => ErrorRetry(
                    message: 'Failed to load japa history',
                    onRetry: () => ref.invalidate(weekHistoryProvider),
                  ),
                  data: (weekLogs) {
                    int bestDay = 0;
                    int currentStreak = 0;
                    int totalMalasWeek = 0;

                    bool streakActive = true;
                    for (var log in weekLogs.reversed) {
                      totalMalasWeek += log.totalMalas;
                      if (log.totalMalas > bestDay) bestDay = log.totalMalas;
                      if (streakActive && log.goalReached) {
                        currentStreak++;
                      } else if (log.date != DateFormat('yyyy-MM-dd').format(DateTime.now())) {
                        streakActive = false;
                      }
                    }
                    final double avgMalas = totalMalasWeek / 7.0;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LAST 7 DAYS',
                            style: GoogleFonts.jost(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8B6914).withOpacity(0.5),
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Bar Chart
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFF5EDDA), Color(0xFFEDE0C4)],
                              ),
                              border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.12)),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF4A2C0A).withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: SizedBox(
                              height: 220,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (bestDay + 5).toDouble(),
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBgColor: const Color(0xFF4A2C0A),
                                      tooltipRoundedRadius: 8,
                                      getTooltipItem: (group, gi, rod, ri) {
                                        return BarTooltipItem(
                                          '${rod.toY.toInt()} malas',
                                          GoogleFonts.jost(fontSize: 12, color: const Color(0xFFF5E8D0)),
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
                                          if (value >= 0 && value < weekLogs.length) {
                                            final logStr = weekLogs[value.toInt()].date;
                                            final date = DateTime.parse(logStr);
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(
                                                DateFormat('E').format(date),
                                                style: GoogleFonts.jost(fontSize: 10, color: const Color(0xFF8B6914).withOpacity(0.5)),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            '${value.toInt()}',
                                            style: GoogleFonts.jost(fontSize: 9, color: const Color(0xFF8B6914).withOpacity(0.35)),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: const Color(0xFF8B6914).withOpacity(0.06),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: weekLogs.asMap().entries.map((e) {
                                    return BarChartGroupData(
                                      x: e.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: e.value.totalMalas.toDouble(),
                                          gradient: e.value.goalReached
                                              ? const LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [Color(0xFF8B6914), Color(0xFFC8722A)],
                                                )
                                              : const LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [Color(0xFF8B4513), Color(0xFFA0603A)],
                                                ),
                                          width: 22,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                          Text(
                            'STATISTICS',
                            style: GoogleFonts.jost(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8B6914).withOpacity(0.5),
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Stat cards
                          Row(
                            children: [
                              Expanded(child: _StatCard(title: 'Avg / Day', value: avgMalas.toStringAsFixed(1), icon: Icons.trending_up_rounded)),
                              const SizedBox(width: 10),
                              Expanded(child: _StatCard(title: 'Best Day', value: '$bestDay', icon: Icons.emoji_events_rounded)),
                              const SizedBox(width: 10),
                              Expanded(child: _StatCard(title: 'Streak', value: '$currentStreak', icon: Icons.local_fire_department_rounded)),
                            ],
                          ),

                          const SizedBox(height: 28),
                          Text(
                            'MONTH OVERVIEW',
                            style: GoogleFonts.jost(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8B6914).withOpacity(0.5),
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          monthAsync.when(
                            loading: () => const ShimmerLoading(height: 40),
                            error: (e, s) => ErrorRetry(
                              message: 'Failed to load month data',
                              onRetry: () => ref.invalidate(monthHistoryProvider),
                            ),
                            data: (monthLogs) {
                              return Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: monthLogs.map((log) {
                                  final isGoal = log.goalReached;
                                  final hasData = log.totalMalas > 0;
                                  return Tooltip(
                                    message: '${log.date}: ${log.totalMalas} malas',
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        gradient: isGoal
                                            ? const LinearGradient(colors: [Color(0xFF8B6914), Color(0xFFC8722A)])
                                            : hasData
                                                ? LinearGradient(colors: [
                                                    const Color(0xFF8B4513).withOpacity(0.3),
                                                    const Color(0xFF8B4513).withOpacity(0.15),
                                                  ])
                                                : null,
                                        color: (!isGoal && !hasData) ? const Color(0xFF8B6914).withOpacity(0.06) : null,
                                        border: Border.all(
                                          color: isGoal
                                              ? const Color(0xFF8B6914).withOpacity(0.4)
                                              : const Color(0xFF8B6914).withOpacity(0.1),
                                        ),
                                      ),
                                      child: isGoal
                                          ? const Center(child: Icon(Icons.check, size: 12, color: Color(0xFFF5E8D0)))
                                          : Center(
                                              child: Text(
                                                '${log.totalMalas}',
                                                style: GoogleFonts.jost(
                                                  fontSize: 9,
                                                  color: hasData
                                                      ? const Color(0xFF4A2C0A).withOpacity(0.5)
                                                      : const Color(0xFF8B6914).withOpacity(0.2),
                                                ),
                                              ),
                                            ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5EDDA), Color(0xFFEDE0C4)],
        ),
        border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4A2C0A).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8B4513).withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cormorantSc(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3A2010),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.jost(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8B6914).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
