import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/error_retry.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends ConsumerState<AttendanceHistoryScreen> {
  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Authentication required')),
      );
    }

    final historyAsync = ref.watch(studentAttendanceProvider(user.uid!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedMonth ?? DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (date != null) {
                setState(() => _selectedMonth = date);
              } else {
                setState(() => _selectedMonth = null); // Reset on null
              }
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFFE8F5F9),
      body: historyAsync.when(
        loading: () => ShimmerLoading.listItem(),
        error: (error, _) => ErrorRetry(
          message: 'Failed to load attendance history',
          onRetry: () => ref.invalidate(studentAttendanceProvider(user.uid!)),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const Center(child: Text('No attendance history available.'));
          }

          // Calculate percentage from original list
          int attendedCount = records.where((r) => r.status == 'present' || r.status == 'late').length;
          double percentage = (attendedCount / records.length) * 100;
          
          Color percentColor = Colors.red;
          if (percentage > 75) percentColor = Colors.green;
          else if (percentage >= 50) percentColor = const Color(0xFF1565C0);

          // Apply month filter
          var filteredRecords = records;
          if (_selectedMonth != null) {
            filteredRecords = records.where((r) => 
              r.markedAt.year == _selectedMonth!.year && 
              r.markedAt.month == _selectedMonth!.month
            ).toList();
          }

          return Column(
            children: [
              // Percentage Indicator
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Total Attendance', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: percentColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (_selectedMonth != null) 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text('Filtered by: ${DateFormat('MMMM yyyy').format(_selectedMonth!)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() => _selectedMonth = null), 
                        child: const Text('Clear')
                      )
                    ],
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(record.status).withOpacity(0.2),
                          child: Icon(Icons.class_, color: _getStatusColor(record.status)),
                        ),
                        title: Text('Session (${record.sessionId.substring(0, 5)}...)'), // Optional: Fetch actual topic
                        subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(record.markedAt)),
                        trailing: Chip(
                          label: Text(record.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: _getStatusColor(record.status),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present': return Colors.green;
      case 'late': return const Color(0xFF1565C0);
      case 'absent': return Colors.red;
      default: return Colors.grey;
    }
  }
}
