import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/sacred_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/assignment_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/sacred_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _branchController;
  late TextEditingController _yearController;
  late TextEditingController _interestsController;
  late TextEditingController _skillsController;
  DateTime? _selectedDob;
  bool _isEditing = false;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    if (!_isEditing) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _branchController = TextEditingController();
    _yearController = TextEditingController();
    _interestsController = TextEditingController();
    _skillsController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProfileProvider).valueOrNull;
      if (user != null) {
        _nameController.text = user.fullName;
        _phoneController.text = user.phoneNumber;
        _addressController.text = user.address ?? '';
        _branchController.text = user.collegeBranch ?? '';
        _yearController.text = user.year ?? '';
        _interestsController.text = user.interests?.join(', ') ?? '';
        _skillsController.text = user.skills?.join(', ') ?? '';
        _selectedDob = user.dateOfBirth;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _branchController.dispose();
    _yearController.dispose();
    _interestsController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(String uid) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    
    try {
      final bytes = await pickedFile.readAsBytes();
      final authService = ref.read(authServiceProvider);
      final url = await authService.uploadProfilePhoto(uid, bytes);
      
      await authService.updateProfile(uid, {
        'profilePhotoUrl': url,
      });
      
      ref.invalidate(userProfileProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        'address': _addressController.text,
        if (_selectedDob != null) 'dateOfBirth': Timestamp.fromDate(_selectedDob!),
        'collegeBranch': _branchController.text,
        'year': _yearController.text,
        'interests': _interestsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'skills': _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      });
      
      ref.invalidate(userProfileProvider);
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFF080604),
      body: SacredBackground(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return Center(
                child: Text('User profile not found.', style: SacredTextStyles.infoValue()),
              );
            }

            // Populate controllers on first load
            if (_nameController.text.isEmpty && user.fullName.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _nameController.text = user.fullName;
                _phoneController.text = user.phoneNumber;
                _addressController.text = user.address ?? '';
                _branchController.text = user.collegeBranch ?? '';
                _yearController.text = user.year ?? '';
                _interestsController.text = user.interests?.join(', ') ?? '';
                _skillsController.text = user.skills?.join(', ') ?? '';
                _selectedDob = user.dateOfBirth;
              });
            }

            final initials = user.fullName.isNotEmpty
                ? user.fullName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
                : '?';

            return SafeArea(
              child: Form(
                key: _formKey,
                child: CustomScrollView(
                  slivers: [
                    // ── HERO BANNER ──
                    SliverToBoxAdapter(
                      child: _buildHeroBanner(user, initials),
                    ),
                    // ── GOLD RULE ──
                    const SliverToBoxAdapter(child: SacredDivider()),

                    // ── MY PROGRESS ──
                    const SliverToBoxAdapter(child: SacredSectionLabel(text: 'My Progress')),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildProgressSection(user.uid),
                      ),
                    ),

                    // ── GOLD RULE ──
                    const SliverToBoxAdapter(child: SacredDivider()),
                    // ── SADHAKA INFO ──
                    const SliverToBoxAdapter(child: SacredSectionLabel(text: 'Sādhaka Info')),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            GlassInfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email,
                            ),
                            if (_isEditing)
                              _buildSacredTextField(_nameController, 'Full Name', Icons.person_outline),
                            if (_isEditing)
                              _buildSacredTextField(_phoneController, 'Phone Number', Icons.phone_outlined),
                            if (!_isEditing)
                              GlassInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                value: user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Not set',
                              ),
                            if (!_isEditing)
                              GlassInfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Kshetra (Address)',
                                value: (user.address?.isNotEmpty == true) ? user.address! : 'Not set',
                              ),
                            if (_isEditing)
                              _buildSacredTextField(_addressController, 'Address', Icons.location_on_outlined),
                            GlassInfoRow(
                              icon: Icons.spa_outlined,
                              label: 'Birth Tithi',
                              value: _selectedDob != null
                                  ? DateFormat('d MMMM yyyy').format(_selectedDob!)
                                  : (user.dateOfBirth != null
                                      ? DateFormat('d MMMM yyyy').format(user.dateOfBirth!)
                                      : 'Not set'),
                            ),
                            if (_isEditing)
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(13),
                                  decoration: SacredDecorations.glassCard(),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34, height: 34,
                                        decoration: SacredDecorations.iconBox(),
                                        child: Icon(Icons.calendar_today, size: 14, color: SacredColors.parchment.withOpacity(0.7)),
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        'Tap to change date of birth',
                                        style: SacredTextStyles.infoValue(fontSize: 12).copyWith(
                                          color: SacredColors.parchment.withOpacity(0.4),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Two-column row
                            Row(
                              children: [
                                Expanded(
                                  child: _isEditing
                                      ? _buildSacredTextField(_branchController, 'College Branch', Icons.school_outlined)
                                      : GlassInfoRow(
                                          icon: Icons.school_outlined,
                                          label: 'Vidyashala',
                                          value: (user.collegeBranch?.isNotEmpty == true) ? user.collegeBranch! : 'Not set',
                                        ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _isEditing
                                      ? _buildSacredTextField(_yearController, 'Year', Icons.layers_outlined)
                                      : GlassInfoRow(
                                          icon: Icons.layers_outlined,
                                          label: 'Varsha',
                                          value: (user.year?.isNotEmpty == true) ? user.year! : 'Not set',
                                        ),
                                ),
                              ],
                            ),

                            // Status & Role info row
                            Row(
                              children: [
                                Expanded(
                                  child: GlassInfoRow(
                                    icon: Icons.admin_panel_settings_outlined,
                                    label: 'Role',
                                    value: user.role.toUpperCase(),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: GlassInfoRow(
                                    icon: Icons.check_circle_outline,
                                    label: 'Status',
                                    value: user.status.toUpperCase(),
                                    iconColor: user.status == 'active'
                                        ? const Color(0xFF6B8E6E)
                                        : (user.status == 'suspended'
                                            ? const Color(0xFFC45050)
                                            : SacredColors.ember),
                                  ),
                                ),
                              ],
                            ),
                            GlassInfoRow(
                              icon: Icons.date_range_outlined,
                              label: 'Enrolled',
                              value: DateFormat('MMM d, yyyy').format(user.enrollmentDate),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── PATHS OF STUDY / INTERESTS ──
                    if (!_isEditing && (user.interests?.isNotEmpty == true)) ...[
                      const SliverToBoxAdapter(child: SacredSectionLabel(text: 'Paths of Study')),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (user.interests ?? []).map((i) => SacredChip(label: i)).toList(),
                          ),
                        ),
                      ),
                    ],
                    if (_isEditing) ...[
                      const SliverToBoxAdapter(child: SacredSectionLabel(text: 'Interests & Skills')),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildSacredTextField(_interestsController, 'Interests (comma separated)', Icons.star_outline),
                              _buildSacredTextField(_skillsController, 'Skills (comma separated)', Icons.build_outlined),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (!_isEditing && (user.skills?.isNotEmpty == true)) ...[
                      const SliverToBoxAdapter(child: SacredSectionLabel(text: 'Skills')),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (user.skills ?? []).map((s) => SacredChip(label: s)).toList(),
                          ),
                        ),
                      ),
                    ],

                    // ── SAVE BUTTON ──
                    if (_isEditing)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: GestureDetector(
                            onTap: _isLoading ? null : () => _saveProfile(user.uid),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: SacredColors.parchment.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: SacredColors.parchment.withOpacity(0.25)),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: SacredColors.parchment.withOpacity(0.6),
                                        ),
                                      )
                                    : Text(
                                        'SAVE CHANGES',
                                        style: SacredTextStyles.sectionLabel(fontSize: 10).copyWith(
                                          color: SacredColors.parchment.withOpacity(0.7),
                                          letterSpacing: 3,
                                        ),
                                      ),
=======
      appBar: AppBar(
        title: const Text('Profile'),
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
                        _addressController.text = user.address ?? '';
                        _branchController.text = user.collegeBranch ?? '';
                        _yearController.text = user.year ?? '';
                        _interestsController.text = user.interests?.join(', ') ?? '';
                        _skillsController.text = user.skills?.join(', ') ?? '';
                        _selectedDob = user.dateOfBirth;
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
      backgroundColor: const Color(0xFFE8F5F9),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User profile not found.'));
          
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
                        backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                        backgroundImage: user.profilePhotoUrl.isNotEmpty ? NetworkImage(user.profilePhotoUrl) : null,
                        child: user.profilePhotoUrl.isEmpty
                            ? Text(
                                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 48, color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
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
                                color: Color(0xFF1565C0),
                                shape: BoxShape.circle,
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
                              ),
                            ),
                          ),
                        ),
<<<<<<< HEAD
                      ),

                    // ── BOTTOM SHLOKA QUOTE ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
                        child: Column(
                          children: [
                            SacredDivider(width: 60, margin: EdgeInsets.zero),
                            const SizedBox(height: 8),
                            Text(
                              '"Yogaḥ karmasu kauśalam"',
                              style: SacredTextStyles.shloka(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'EXCELLENCE IN ACTION IS YOGA · BG 2.50',
                              style: SacredTextStyles.infoKey(fontSize: 7).copyWith(
                                letterSpacing: 2,
                                color: SacredColors.parchment.withOpacity(0.22),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            SacredDivider(width: 60, margin: EdgeInsets.zero),
                          ],
                        ),
                      ),
                    ),

                    // ── LOGOUT BUTTON ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                        child: GestureDetector(
                          onTap: () async {
                            await ref.read(authServiceProvider).logout();
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A1010).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFC45050).withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, size: 14, color: const Color(0xFFC45050).withOpacity(0.6)),
                                const SizedBox(width: 8),
                                Text(
                                  'SIGN OUT',
                                  style: SacredTextStyles.sectionLabel(fontSize: 9).copyWith(
                                    color: const Color(0xFFC45050).withOpacity(0.6),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
=======
                      if (_isLoading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(color: Color(0xFF1565C0)),
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
                          _buildInfoRow(Icons.email, 'Email', user.email),
                          const Divider(),
                          _buildInfoRow(Icons.admin_panel_settings, 'Role', user.role.toUpperCase()),
                          const Divider(),
                          _buildInfoRow(Icons.check_circle_outline, 'Status', user.status.toUpperCase(), 
                              color: user.status == 'active' ? Colors.green : (user.status == 'suspended' ? Colors.red : const Color(0xFF1565C0))),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    enabled: _isEditing,
                    decoration: _inputDecoration('Address', Icons.location_on),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: _inputDecoration('Date of Birth', Icons.cake),
                      child: Text(_selectedDob != null ? DateFormat('MMM d, yyyy').format(_selectedDob!) : (_isEditing ? 'Select Date' : 'Not set')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _branchController,
                    enabled: _isEditing,
                    decoration: _inputDecoration('College Branch', Icons.school),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearController,
                    enabled: _isEditing,
                    decoration: _inputDecoration('Year of Study', Icons.calendar_today),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _interestsController,
                    enabled: _isEditing,
                    decoration: _inputDecoration('Interests (comma separated)', Icons.star),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillsController,
                    enabled: _isEditing,
                    decoration: _inputDecoration('Skills (comma separated)', Icons.build),
                  ),
                  
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _saveProfile(user.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: SacredColors.parchment.withOpacity(0.4),
            ),
<<<<<<< HEAD
          ),
          error: (error, stack) => Center(
            child: Text('Error loading profile: $error', style: SacredTextStyles.infoValue()),
=======
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
        error: (error, stack) => Center(child: Text('Error loading profile: \$error')),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
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
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
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
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
          ),
        ),
      ),
    );
  }

  // ── My Progress: Attendance + Assignments circles ──
  Widget _buildProgressSection(String uid) {
    final sessionsAsync = ref.watch(sessionListProvider);
    final attendanceAsync = ref.watch(studentAttendanceProvider(uid));
    final assignmentsAsync = ref.watch(assignmentsProvider);

    // Compute attendance percentage
    double attendancePercent = 0;
    int attendedCount = 0;
    int totalSessions = 0;

    sessionsAsync.whenData((sessions) {
      totalSessions = sessions.length;
    });
    attendanceAsync.whenData((records) {
      attendedCount = records.where((r) => r.status == 'present' || r.status == 'late').length;
    });
    if (totalSessions > 0) {
      attendancePercent = (attendedCount / totalSessions).clamp(0.0, 1.0);
    }

    // Compute assignment completion percentage
    double assignmentPercent = 0;
    int totalAssignments = 0;
    int completedAssignments = 0;

    assignmentsAsync.whenData((assignments) {
      totalAssignments = assignments.length;
    });

    // We need to check submissions for each assignment
    // For now we'll count assignments where we've submitted
    if (totalAssignments > 0) {
      for (int i = 0; i < totalAssignments; i++) {
        final assignments = assignmentsAsync.valueOrNull ?? [];
        if (i < assignments.length) {
          final sub = ref.watch(mySubmissionProvider((
            assignmentId: assignments[i].assignmentId,
            studentUid: uid,
          ))).valueOrNull;
          if (sub != null && (sub.status == 'submitted' || sub.status == 'completed')) {
            completedAssignments++;
          }
        }
      }
      assignmentPercent = (completedAssignments / totalAssignments).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: SacredDecorations.glassCard(radius: 18),
      child: Column(
        children: [
          Row(
            children: [
              // Attendance circle — tappable to open attendance history
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/attendance/history'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                    decoration: BoxDecoration(
                      color: SacredColors.glassBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 66,
                          height: 66,
                          child: CustomPaint(
                            painter: _ProgressRingPainter(
                              progress: attendancePercent,
                              color: const Color(0xFF8B7A99),
                              bgColor: SacredColors.parchment.withOpacity(0.08),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(attendancePercent * 100).round()}%',
                                    style: SacredTextStyles.ringPercent().copyWith(
                                      color: const Color(0xFF8B7A99).withOpacity(0.8),
                                    ),
                                  ),
                                  Text(
                                    '$attendedCount/$totalSessions',
                                    style: SacredTextStyles.progressLabel(fontSize: 6).copyWith(
                                      color: const Color(0xFF8B7A99).withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Icon(Icons.calendar_today_rounded, size: 11, color: const Color(0xFF8B7A99).withOpacity(0.4)),
                        const SizedBox(height: 4),
                        Text(
                          'ATTENDANCE',
                          style: SacredTextStyles.progressLabel(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Assignment circle
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                  decoration: BoxDecoration(
                    color: SacredColors.glassBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: SacredColors.parchment.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 66,
                        height: 66,
                        child: CustomPaint(
                          painter: _ProgressRingPainter(
                            progress: assignmentPercent,
                            color: SacredColors.ember,
                            bgColor: SacredColors.parchment.withOpacity(0.08),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(assignmentPercent * 100).round()}%',
                                  style: SacredTextStyles.ringPercent().copyWith(
                                    color: SacredColors.ember.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '$completedAssignments/$totalAssignments',
                                  style: SacredTextStyles.progressLabel(fontSize: 6).copyWith(
                                    color: SacredColors.ember.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Icon(Icons.assignment_rounded, size: 11, color: SacredColors.ember.withOpacity(0.4)),
                      const SizedBox(height: 4),
                      Text(
                        'ASSIGNMENTS',
                        style: SacredTextStyles.progressLabel(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Tap hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, size: 10, color: SacredColors.parchment.withOpacity(0.15)),
              const SizedBox(width: 4),
              Text(
                'Tap attendance to view details',
                style: SacredTextStyles.infoKey(fontSize: 7).copyWith(
                  color: SacredColors.parchment.withOpacity(0.2),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Hero Banner with mandala, avatar, name, badge ──
  Widget _buildHeroBanner(dynamic user, String initials) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x99281204), Color(0x000C0804)],
        ),
      ),
      child: Stack(
        children: [
          // Rotating mandala watermark
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(child: _MandalaWatermark()),
          ),
          Column(
            children: [
              // Top bar: back + edit/close
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x08FFFFFF),
                          border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
                        ),
                        child: Icon(Icons.arrow_back_ios_new, size: 12, color: SacredColors.parchment.withOpacity(0.5)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_isEditing) {
                          _nameController.text = user.fullName;
                          _phoneController.text = user.phoneNumber;
                          _addressController.text = user.address ?? '';
                          _branchController.text = user.collegeBranch ?? '';
                          _yearController.text = user.year ?? '';
                          _interestsController.text = user.interests?.join(', ') ?? '';
                          _skillsController.text = user.skills?.join(', ') ?? '';
                          _selectedDob = user.dateOfBirth;
                        }
                        setState(() => _isEditing = !_isEditing);
                      },
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x08FFFFFF),
                          border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
                        ),
                        child: Icon(
                          _isEditing ? Icons.close : Icons.edit_outlined,
                          size: 12,
                          color: SacredColors.parchment.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Avatar with dharma ring
              GestureDetector(
                onTap: () => _pickAndUploadImage(user.uid),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer dharma ring (rotating)
                    _DharmaRing(),
                    // Inner avatar circle
                    Container(
                      width: 66, height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment(-0.3, -0.5),
                          end: Alignment(0.5, 1),
                          colors: [Color(0xFF2A1A08), Color(0xFF160E05)],
                        ),
                        border: Border.all(color: SacredColors.parchment.withOpacity(0.22)),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF643205).withOpacity(0.3), blurRadius: 24),
                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: ClipOval(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Faint OM behind
                            Text('ॐ', style: TextStyle(fontSize: 38, color: SacredColors.parchment.withOpacity(0.06))),
                            // Photo or initials
                            if (user.profilePhotoUrl.isNotEmpty)
                              Image.network(user.profilePhotoUrl, fit: BoxFit.cover, width: 66, height: 66,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 1.5, color: SacredColors.parchment.withOpacity(0.4)),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Text(initials, style: GoogleFonts.cormorantSc(fontSize: 22, color: SacredColors.parchment.withOpacity(0.65), letterSpacing: 3)))
                            else
                              Text(initials, style: GoogleFonts.cormorantSc(fontSize: 22, color: SacredColors.parchment.withOpacity(0.65), letterSpacing: 3)),
                            if (_isLoading)
                              Container(
                                color: Colors.black45,
                                child: Center(
                                  child: SizedBox(width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 1.5, color: SacredColors.parchment.withOpacity(0.6)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Edit dot
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFF2E1606), Color(0xFF1A0E04)]),
                          border: Border.all(color: SacredColors.parchment.withOpacity(0.28)),
                        ),
                        child: Icon(Icons.edit, size: 9, color: SacredColors.parchment.withOpacity(0.6)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Name
              Text(user.fullName, style: SacredTextStyles.profileName()),
              const SizedBox(height: 6),
              // Devotee badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: SacredColors.parchment.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 3, height: 3, decoration: BoxDecoration(shape: BoxShape.circle, color: SacredColors.parchment.withOpacity(0.4))),
                    const SizedBox(width: 7),
                    Text(
                      'SĀDHAKA',
                      style: SacredTextStyles.sectionLabel(fontSize: 9).copyWith(
                        color: SacredColors.parchment.withOpacity(0.4),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(width: 3, height: 3, decoration: BoxDecoration(shape: BoxShape.circle, color: SacredColors.parchment.withOpacity(0.4))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sacred-themed text field ──
  Widget _buildSacredTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        style: SacredTextStyles.infoValue(fontSize: 14),
        validator: (val) {
          if (label == 'Full Name' && (val == null || val.isEmpty)) return 'Required';
          if (label == 'Phone Number' && (val == null || val.isEmpty)) return 'Required';
          return null;
        },
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: SacredTextStyles.infoKey(fontSize: 9).copyWith(letterSpacing: 1.5),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            width: 34, height: 34,
            decoration: SacredDecorations.iconBox(),
            child: Icon(icon, size: 14, color: SacredColors.parchment.withOpacity(0.5)),
          ),
          filled: true,
          fillColor: SacredColors.glassBg,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.3)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: SacredColors.ember.withOpacity(0.3)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.05)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Progress Ring Painter — used for attendance & assignment circles
// ═══════════════════════════════════════════════════════════════

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 4.5;

    // Background track
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ═══════════════════════════════════════════════════════════════
//  Mandala Watermark — Slowly rotating ornamental mandala
// ═══════════════════════════════════════════════════════════════

class _MandalaWatermark extends StatefulWidget {
  @override
  State<_MandalaWatermark> createState() => _MandalaWatermarkState();
}

class _MandalaWatermarkState extends State<_MandalaWatermark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child,
        );
      },
      child: CustomPaint(
        size: const Size(200, 200),
        painter: _MandalaPainter(),
      ),
    );
  }
}

class _MandalaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Concentric circles
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final r in [90.0, 70.0, 50.0, 30.0]) {
      circlePaint.color = SacredColors.parchment.withOpacity(r == 30 ? 0.07 : (r == 50 ? 0.05 : (r == 70 ? 0.06 : 0.08)));
      canvas.drawCircle(center, r, circlePaint);
    }

    // 8-petal lotus
    final petalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = SacredColors.parchment.withOpacity(0.09);

    for (int i = 0; i < 8; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * pi / 4);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -35), width: 16, height: 44),
        petalPaint,
      );
      canvas.restore();
    }

    // Radial lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = SacredColors.parchment.withOpacity(0.05);

    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 4;
      canvas.drawLine(
        Offset(center.dx + cos(angle) * 10, center.dy + sin(angle) * 10),
        Offset(center.dx + cos(angle) * 90, center.dy + sin(angle) * 90),
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx - cos(angle) * 10, center.dy - sin(angle) * 10),
        Offset(center.dx - cos(angle) * 90, center.dy - sin(angle) * 90),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
//  Dharma Ring — Rotating ring with 24 spokes around avatar
// ═══════════════════════════════════════════════════════════════

class _DharmaRing extends StatefulWidget {
  @override
  State<_DharmaRing> createState() => _DharmaRingState();
}

class _DharmaRingState extends State<_DharmaRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child,
        );
      },
      child: CustomPaint(
        size: const Size(82, 82),
        painter: _DharmaRingPainter(),
      ),
    );
  }
}

class _DharmaRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer circle
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = SacredColors.parchment.withOpacity(0.15);
    canvas.drawCircle(center, radius, circlePaint);

    // 24 spokes
    final spokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = SacredColors.parchment.withOpacity(0.2);

    for (int i = 0; i < 24; i++) {
      final angle = i * pi / 12;
      canvas.drawLine(
        Offset(center.dx + cos(angle) * (radius - 10), center.dy + sin(angle) * (radius - 10)),
        Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius),
        spokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

