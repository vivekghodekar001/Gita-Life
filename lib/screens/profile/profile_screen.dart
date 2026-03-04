import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/japa_provider.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../services/japa_service.dart';

final attendanceStatsProvider = FutureProvider.family<double, String>((ref, uid) {
  return AttendanceService().getAttendancePercentage(uid);
});

final japaStatsProvider = FutureProvider<int>((ref) async {
  final logs = await ref.read(japaServiceProvider).getMonthHistory();
  return logs.fold<int>(0, (sum, log) => sum + log.totalMalas);
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProfileProvider).valueOrNull;
      if (user != null) {
        _nameController.text = user.fullName;
        _phoneController.text = user.phoneNumber;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(String uid) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    
    try {
      final file = File(pickedFile.path);
      final authService = ref.read(authServiceProvider);
      final url = await authService.uploadProfilePhoto(uid, file);
      
      await authService.updateProfile(uid, {
        'profilePhotoUrl': url,
      });
      
      ref.invalidate(userProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile(String uid) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ref.read(authServiceProvider).updateProfile(uid, {
        'fullName': _nameController.text,
        'phoneNumber': _phoneController.text,
      });
      
      ref.invalidate(userProfileProvider);
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: \$e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        actions: [
          userAsync.maybeWhen(
            data: (user) => user != null
                ? IconButton(
                    icon: Icon(_isEditing ? Icons.close : Icons.edit),
                    onPressed: () {
                      if (_isEditing) {
                        _nameController.text = user.fullName;
                        _phoneController.text = user.phoneNumber;
                      }
                      setState(() => _isEditing = !_isEditing);
                    },
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).logout();
            },
            color: Colors.red,
          )
        ],
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User profile not found.'));
          
          final attendanceAsync = ref.watch(attendanceStatsProvider(user.uid));
          final japaAsync = ref.watch(japaStatsProvider);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFE65100).withOpacity(0.1),
                        backgroundImage: user.profilePhotoUrl.isNotEmpty ? NetworkImage(user.profilePhotoUrl) : null,
                        child: user.profilePhotoUrl.isEmpty
                            ? Text(
                                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 48, color: Color(0xFFE65100), fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      if (!_isLoading)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: () => _pickAndUploadImage(user.uid),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE65100),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      if (_isLoading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(color: Color(0xFFE65100)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Read-only Details
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.badge, 'Roll Number', user.rollNumber),
                          const Divider(),
                          _buildInfoRow(Icons.email, 'Email', user.email),
                          const Divider(),
                          _buildInfoRow(Icons.admin_panel_settings, 'Role', user.role.toUpperCase()),
                          const Divider(),
                          _buildInfoRow(Icons.check_circle_outline, 'Status', user.status.toUpperCase(), 
                              color: user.status == 'active' ? Colors.green : (user.status == 'suspended' ? Colors.red : Colors.orange)),
                          const Divider(),
                          _buildInfoRow(Icons.date_range, 'Enrolled', DateFormat('MMM d, yyyy').format(user.enrollmentDate)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Editable Details
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Personal Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: _inputDecoration('Full Name', Icons.person),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    decoration: _inputDecoration('Phone Number', Icons.phone),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _saveProfile(user.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],

                  const SizedBox(height: 32),
                  
                  // Stats Summary
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Your Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: attendanceAsync.when(
                          data: (pct) => _buildStatCard('Attendance', '\${pct.toStringAsFixed(1)}%', Icons.event_available, Colors.blue),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: japaAsync.when(
                          data: (malas) => _buildStatCard('30d Malas', '\$malas', Icons.adjust, const Color(0xFFE65100)),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE65100))),
        error: (error, stack) => Center(child: Text('Error loading profile: \$error')),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFE65100)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
      ),
      filled: !_isEditing,
      fillColor: _isEditing ? Colors.white : Colors.grey[100],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color ?? Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

