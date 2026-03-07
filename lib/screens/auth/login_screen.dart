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
  bool _obscurePassword = true;

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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B6914).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.15)),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF8B6914).withOpacity(0.08), blurRadius: 16),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: Image.asset(
                            'assets/app_logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.auto_stories, size: 34, color: const Color(0xFF4A2C0A).withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'GitaLife',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantSc(fontSize: 30, fontWeight: FontWeight.w600, color: const Color(0xFF4A2C0A).withOpacity(0.85), letterSpacing: 3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C4033).withOpacity(0.80), letterSpacing: 1.5),
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
                        obscure: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: const Color(0xFF8B6914).withOpacity(0.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter your password';
                          return null;
                        }),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: Text('Forgot password?', style: GoogleFonts.jost(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF8B4513).withOpacity(0.80))),
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
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B4513), Color(0xFFC8722A)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF8B4513).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Color(0xFFF5E8D0), strokeWidth: 1.5))
                            : Text('LOGIN', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 2, color: const Color(0xFFF5E8D0))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Divider(color: const Color(0xFF8B6914).withOpacity(0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: GoogleFonts.jost(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF4A2C0A).withOpacity(0.60), letterSpacing: 1)),
                        ),
                        Expanded(child: Divider(color: const Color(0xFF8B6914).withOpacity(0.2))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ── Google Sign In — CSS-spec button ──
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: (_isLoading || _isGoogleLoading) ? null : _signInWithGoogle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 44,
                          decoration: BoxDecoration(
                            color: (_isLoading || _isGoogleLoading)
                                ? const Color(0xFFEBEBEB)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                offset: Offset(0, -1),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Color(0x40000000),
                                offset: Offset(0, 1),
                                blurRadius: 1,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: _isGoogleLoading
                              ? const Center(
                                  child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Color(0xFF757575)),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CustomPaint(
                                          painter: _GoogleLogoPainter()),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF757575),
                                        fontFamily: 'sans-serif',
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF4A2C0A).withOpacity(0.72))),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text('Sign Up', style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF8B4513), decoration: TextDecoration.underline, decorationColor: const Color(0xFF8B4513).withOpacity(0.4))),
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
      {bool obscure = false, Widget? suffixIcon, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF3A2010)),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.jost(fontSize: 12, color: const Color(0xFF4A2C0A).withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFF8B6914).withOpacity(0.5), size: 18),
        suffixIcon: suffixIcon != null ? Padding(padding: const EdgeInsets.only(right: 8), child: suffixIcon) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.35),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: const Color(0xFF8B6914).withOpacity(0.2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: const Color(0xFF8B6914).withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: const Color(0xFF8B4513).withOpacity(0.5))),
        errorStyle: GoogleFonts.jost(fontSize: 10, color: SacredColors.ember.withOpacity(0.8)),
      ),
    );
  }
}

// ── Google Logo Painter ──────────────────────────────────────────────────────
// Official 4-path Google G logo using SVG path data (Blue, Green, Yellow, Red).
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 18;
    final double sy = size.height / 18;
    canvas.scale(sx, sy);

    // Blue path
    final bluePath = Path()
      ..moveTo(17.64, 9.205)
      ..cubicTo(17.64, 8.566, 17.583, 7.953, 17.476, 7.364)
      ..lineTo(9, 7.364)
      ..lineTo(9, 10.845)
      ..lineTo(13.844, 10.845)
      ..cubicTo(13.382, 12.234, 12.468, 13.392, 11.048, 14.101)
      ..lineTo(11.048, 16.360)
      ..lineTo(13.956, 16.360)
      ..cubicTo(15.658, 14.793, 16.640, 12.485, 16.640, 9.205)
      ..close();
    canvas.drawPath(bluePath, Paint()..color = const Color(0xFF4285F4));

    // Green path
    final greenPath = Path()
      ..moveTo(9, 18)
      ..cubicTo(11.430, 18, 13.467, 17.194, 14.956, 15.820)
      ..lineTo(12.048, 13.561)
      ..cubicTo(11.242, 14.101, 10.211, 14.421, 9, 14.421)
      ..cubicTo(6.656, 14.421, 4.672, 12.837, 3.964, 10.710)
      ..lineTo(0.957, 10.710)
      ..lineTo(0.957, 13.042)
      ..cubicTo(2.439, 15.983, 5.482, 18, 9, 18)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF34A853));

    // Yellow path
    final yellowPath = Path()
      ..moveTo(3.964, 10.710)
      ..cubicTo(3.783, 10.170, 3.682, 9.593, 3.682, 9)
      ..cubicTo(3.682, 8.407, 3.783, 7.830, 3.964, 7.290)
      ..lineTo(3.964, 4.958)
      ..lineTo(0.957, 4.958)
      ..cubicTo(0.348, 6.173, 0, 7.548, 0, 9)
      ..cubicTo(0, 10.452, 0.348, 11.827, 0.957, 13.042)
      ..lineTo(3.964, 10.710)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFBBC05));

    // Red path
    final redPath = Path()
      ..moveTo(9, 3.580)
      ..cubicTo(10.321, 3.580, 11.508, 4.034, 12.440, 4.925)
      ..lineTo(15.022, 2.345)
      ..cubicTo(13.463, 0.891, 11.426, 0, 9, 0)
      ..cubicTo(5.482, 0, 2.439, 2.017, 0.957, 4.958)
      ..lineTo(3.964, 7.290)
      ..cubicTo(4.672, 5.163, 6.656, 3.580, 9, 3.580)
      ..close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
