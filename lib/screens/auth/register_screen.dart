import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> userData = {
        'fullName': _nameController.text.trim(),
        'rollNumber': _rollNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'profilePhotoUrl': '',
        'role': 'student',
        'status': 'pending',
        'enrollmentDate': FieldValue.serverTimestamp(),
        'fcmToken': '',
      };
      
      await ref.read(authServiceProvider).registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        userData,
      );
      // Navigation is handled by router based on auth state and 'pending' status
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: SacredColors.surface),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(Icons.arrow_back_ios_new, size: 16, color: SacredColors.parchment.withOpacity(0.4)),
                      ),
                      const SizedBox(width: 14),
                      Text('Create Account', style: SacredTextStyles.sectionLabel()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Fill in your details to get started.',
                      style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.3))),
                  const SizedBox(height: 28),
                  _sacredField(_nameController, 'Full Name', Icons.person_outline,
                      validator: (val) => (val == null || val.isEmpty) ? 'Enter your name' : null),
                  const SizedBox(height: 14),
                  _sacredField(_rollNumberController, 'Roll Number (optional)', Icons.badge_outlined),
                  const SizedBox(height: 14),
                  _sacredField(_emailController, 'Email', Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter your email';
                        if (!val.contains('@')) return 'Enter a valid email';
                        return null;
                      }),
                  const SizedBox(height: 14),
                  _sacredField(_phoneController, 'Phone Number', Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) => (val == null || val.isEmpty) ? 'Enter your phone number' : null),
                  const SizedBox(height: 14),
                  _sacredField(_passwordController, 'Password', Icons.lock_outline,
                      obscure: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter a password';
                        if (val.length < 6) return 'Minimum 6 characters';
                        return null;
                      }),
                  const SizedBox(height: 14),
                  _sacredField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline,
                      obscure: true,
                      validator: (val) => val != _passwordController.text ? 'Passwords do not match' : null),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: _isLoading ? null : _register,
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: SacredColors.parchment.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: SacredColors.parchment.withOpacity(0.2)),
                      ),
                      child: _isLoading
                          ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: SacredColors.parchment.withOpacity(0.4), strokeWidth: 1.5))
                          : Text('CREATE ACCOUNT', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 2, color: SacredColors.parchmentLight.withOpacity(0.7))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.3))),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text('Login', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: SacredColors.parchment.withOpacity(0.6), decoration: TextDecoration.underline, decorationColor: SacredColors.parchment.withOpacity(0.3))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sacredField(TextEditingController controller, String label, IconData icon,
      {bool obscure = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w300, color: SacredColors.parchmentLight.withOpacity(0.75)),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jost(fontSize: 12, color: SacredColors.parchment.withOpacity(0.35)),
        prefixIcon: Icon(icon, color: SacredColors.parchment.withOpacity(0.3), size: 18),
        filled: true,
        fillColor: SacredColors.parchment.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: SacredColors.parchment.withOpacity(0.25))),
        errorStyle: GoogleFonts.jost(fontSize: 10, color: SacredColors.ember.withOpacity(0.7)),
      ),
    );
  }
}
