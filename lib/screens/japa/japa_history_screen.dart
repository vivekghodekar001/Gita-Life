import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/japa_provider.dart';
import '../../models/japa_log.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';

class JapaHistoryScreen extends ConsumerWidget {
  const JapaHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekAsync = ref.watch(weekHistoryProvider);
    final monthAsync = ref.watch(monthHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F9),
      appBar: AppBar(title: const Text('Japa History')),
      body: weekAsync.when(
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
          for (var log in weekLogs.reversed) { // recent first
             totalMalasWeek += log.totalMalas;
             if (log.totalMalas > bestDay) bestDay = log.totalMalas;
             
             if (streakActive && log.goalReached) {
               currentStreak++;
             } else if (log.date != DateFormat('yyyy-MM-dd').format(DateTime.now())) {
               // Breaking condition only if it's not today (you might just not have started today)
               streakActive = false; 
             }
          }
          final double avgMalas = totalMalasWeek / 7.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Last 7 Days', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 20),
                
                // FL Chart
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (bestDay + 5).toDouble(),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if(value >= 0 && value < weekLogs.length) {
                                final logStr = weekLogs[value.toInt()].date;
                                final date = DateTime.parse(logStr);
                                return Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 12));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: weekLogs.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.totalMalas.toDouble(),
                              color: e.value.goalReached ? Colors.green : const Color(0xFF1565C0),
                              width: 20,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                            )
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text('Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(child: _StatCard(title: 'Avg / Day', value: avgMalas.toStringAsFixed(1))),
                    const SizedBox(width: 15),
                    Expanded(child: _StatCard(title: 'Best Day', value: '$bestDay')),
                    const SizedBox(width: 15),
                    Expanded(child: _StatCard(title: 'Streak', value: '$currentStreak 🔥')),
                  ],
                ),

                const SizedBox(height: 40),
                const Text('Month Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 20),
                monthAsync.when(
                  loading: () => const ShimmerLoading(height: 40),
                  error: (e,s) => ErrorRetry(
                    message: 'Failed to load month data',
                    onRetry: () => ref.invalidate(monthHistoryProvider),
                  ),
                  data: (monthLogs) {
                     return Wrap(
                       spacing: 8,
                       runSpacing: 8,
                       children: monthLogs.map((log) {
                         return Container(
                           width: 30, height: 30,
                           decoration: BoxDecoration(
                             color: log.goalReached ? Colors.green : (log.totalMalas > 0 ? const Color(0xFF64B5F6) : Colors.grey.shade300),
                             borderRadius: BorderRadius.circular(4)
                           ),
                           child: Tooltip(message: '${log.date}: ${log.totalMalas} malas', child: const SizedBox()),
                         );
                       }).toList()
                     );
                  }
                )
              ],
            ),
          );
        },
      )
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }
}
