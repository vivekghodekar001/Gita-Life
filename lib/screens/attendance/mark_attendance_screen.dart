import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_session.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const MarkAttendanceScreen({super.key, required this.sessionId});

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  String _searchQuery = '';
  
  // Local list fetching all users - mock logic assumed from db
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    // In actual app, fetch all registered users who are assumed students
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      // Load current attendance status if any
      final recordsSnap = await FirebaseFirestore.instance
          .collection('attendance_records')
          .where('sessionId', isEqualTo: widget.sessionId)
          .get();

      Map<String, String> statusMap = {};
      for (var doc in recordsSnap.docs) {
        statusMap[doc['studentUid']] = doc['status'];
      }

      setState(() {
        _students = snapshot.docs.map((d) {
          final data = d.data();
          final uid = d.id;
          return {
            'uid': uid,
            'name': data['displayName'] ?? 'Unknown',
            'rollNumber': data['rollNumber'] ?? 'N/A',
            'status': statusMap[uid] ?? 'absent',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
       setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String uid, String status, String name, String rollNumber) async {
    try {
      await ref.read(attendanceServiceProvider).markAttendance(
        widget.sessionId, 
        uid, 
        status, 
        studentName: name, 
        rollNumber: rollNumber
      );
      // Update local state smoothly
      setState(() {
         final index = _students.indexWhere((s) => s['uid'] == uid);
         if (index != -1) _students[index]['status'] = status;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  Future<void> _submitSession() async {
    try {
      await ref.read(attendanceServiceProvider).submitSession(widget.sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Locked')));
        Navigator.of(context).pop();
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to lock: $e')));
    }
  }

  Future<void> _exportCsv() async {
    try {
      final csv = await ref.read(attendanceServiceProvider).exportSessionCsv(widget.sessionId);
      // Depending on platform this could open a share sheet or save file
      if (mounted) {
         showDialog(context: context, builder: (c) => AlertDialog(
            title: const Text('CSV Exported'),
            content: SingleChildScrollView(child: Text(csv)),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))]
         ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Optionally fetch session details here
    
    var filteredStudents = _students.where((s) {
       final q = _searchQuery.toLowerCase();
       return s['name'].toString().toLowerCase().contains(q) || s['rollNumber'].toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
           IconButton(icon: const Icon(Icons.share), onPressed: _exportCsv),
           IconButton(icon: const Icon(Icons.lock), onPressed: _submitSession),
        ],
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by Name or Roll Number',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(student['name']),
                        subtitle: Text('Roll: ${student['rollNumber']}'),
                        trailing: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'present', label: Text('P'), icon: Icon(Icons.check, size: 16, color: Colors.green)),
                            ButtonSegment(value: 'late', label: Text('L'), icon: Icon(Icons.access_time, size: 16, color: Colors.orange)),
                            ButtonSegment(value: 'absent', label: Text('A'), icon: Icon(Icons.close, size: 16, color: Colors.red)),
                          ],
                          selected: {student['status']},
                          onSelectionChanged: (Set<String> newSelection) {
                            _updateStatus(student['uid'], newSelection.first, student['name'], student['rollNumber']);
                          },
                        ),
                      )
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    onPressed: _submitSession,
                    child: const Text('Submit & Lock Session', style: TextStyle(fontSize: 16)),
                  ),
                ),
              )
            ],
          ),
    );
  }
}
