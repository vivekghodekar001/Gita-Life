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
<<<<<<< HEAD
      // Router redirect handles navigation based on user status
=======
      if (mounted) context.go('/home');
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
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
<<<<<<< HEAD
      // Router redirect handles navigation
=======
      if (mounted) context.go('/home');
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
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
<<<<<<< HEAD
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
=======
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Beautiful Krishna-inspired header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF00695C)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_stories, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GitaLife',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your Spiritual Companion',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Form section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to continue your spiritual journey',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter email';
                            if (!val.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter password';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Color(0xFF1565C0)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('LOGIN', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 16),
                        const Row(children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR', style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: (_isLoading || _isGoogleLoading) ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF1565C0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isGoogleLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Image.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  height: 22,
                                  width: 22,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.g_mobiledata, size: 22),
                                ),
                          label: const Text(
                            'Sign in with Google',
                            style: TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
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
