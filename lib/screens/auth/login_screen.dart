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
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B6914).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF8B6914).withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF8B6914).withOpacity(0.08), blurRadius: 16),
                          ],
                        ),
                        child: Icon(Icons.auto_stories, size: 34, color: const Color(0xFF4A2C0A).withOpacity(0.5)),
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
// Proper 4-colour Google G logo.
// In Flutter drawArc: 0° = 3 o'clock (right), angles go clockwise.
// Gap (mouth) centred at 0° (right side), 54° wide: 333° → 27°
//   Green  : 27°  →  90°  ( 63° — lower-right quadrant)
//   Yellow : 90°  → 165°  ( 75° — bottom)
//   Red    : 165° → 333°  (168° — left + upper arc)
//   Blue   : crossbar only (fills gap + right-side cap; no thin arc needed)
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    // Ring dimensions — stroke ~24% of size for a bold G at small sizes
    final double r  = size.width * 0.36;
    final double sw = size.width * 0.22;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    const double deg = 0.017453292519943; // π/180

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    // Green  27° → 90°  (63°)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 27 * deg, 63 * deg, false, paint);

    // Yellow  90° → 165°  (75°)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 90 * deg, 75 * deg, false, paint);

    // Red  165° → 333°  (168°)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 165 * deg, 168 * deg, false, paint);

    // Blue crossbar — covers the gap and the centre-to-right extension.
    // Height = stroke width; left edge = cx; right edge = outer circle edge.
    final double barH  = sw * 0.82;          // slightly narrower than stroke for clean look
    final double barX  = cx;                 // starts at circle centre
    final double barW  = r + sw * 0.50;      // extends to outer ring edge
    canvas.drawRect(
      Rect.fromLTWH(barX, cy - barH / 2, barW, barH),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.fill,
    );

    // Blue short arc cap (upper-right, fills the gap top)
    // 333° → 360°+27° — just draw the full short arc in two calls
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 333 * deg, 27 * deg, false, paint); // 333→360
    canvas.drawArc(rect, 0 * deg,   27 * deg, false, paint); // 0→27
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
