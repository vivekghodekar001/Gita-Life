import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../app/sacred_theme.dart';
import '../../widgets/sacred_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Router redirect handles navigation based on user status
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: SacredColors.surface),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // Router redirect handles navigation
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: SacredColors.surface),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: SacredBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo ──
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: SacredColors.parchment.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.auto_stories, size: 34, color: SacredColors.parchment.withOpacity(0.35)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'GitaLife',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantSc(fontSize: 30, fontWeight: FontWeight.w600, color: SacredColors.parchment.withOpacity(0.75), letterSpacing: 3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.3), letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 36),
                    // ── Email ──
                    _sacredField(_emailController, 'Email', Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter your email';
                          if (!val.contains('@')) return 'Enter a valid email';
                          return null;
                        }),
                    const SizedBox(height: 14),
                    // ── Password ──
                    _sacredField(_passwordController, 'Password', Icons.lock_outline,
                        obscure: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter your password';
                          return null;
                        }),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: Text('Forgot password?', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.3))),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ── Login Button ──
                    GestureDetector(
                      onTap: _isLoading ? null : _login,
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
                            : Text('LOGIN', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 2, color: SacredColors.parchmentLight.withOpacity(0.7))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Divider(color: SacredColors.parchment.withOpacity(0.08))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.2), letterSpacing: 1)),
                        ),
                        Expanded(child: Divider(color: SacredColors.parchment.withOpacity(0.08))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ── Google Sign In ──
                    GestureDetector(
                      onTap: (_isLoading || _isGoogleLoading) ? null : _signInWithGoogle,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: SacredColors.parchment.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: SacredColors.parchment.withOpacity(0.1)),
                        ),
                        child: _isGoogleLoading
                            ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: SacredColors.parchment.withOpacity(0.3), strokeWidth: 1.5))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                    height: 18, width: 18,
                                    errorBuilder: (_, __, ___) => Icon(Icons.g_mobiledata, size: 18, color: SacredColors.parchment.withOpacity(0.3)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Sign in with Google', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.4))),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w300, color: SacredColors.parchment.withOpacity(0.3))),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text('Sign Up', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: SacredColors.parchment.withOpacity(0.6), decoration: TextDecoration.underline, decorationColor: SacredColors.parchment.withOpacity(0.3))),
                        ),
                      ],
                    ),
                  ],
                ),
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
