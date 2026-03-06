import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/sacred_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (mounted) {
      if (onboardingComplete) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SacredColors.ink,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: SacredColors.ink,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
<<<<<<< HEAD
              SacredColors.ember.withOpacity(0.08),
              SacredColors.ink,
=======
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF00695C),
>>>>>>> 99ad060b4b09886d59c8fea80b57098b146f9ed0
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: SacredColors.parchment.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: SacredColors.parchment.withOpacity(0.1), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Image.asset(
                        'assets/splash.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.auto_stories,
                          size: 44,
                          color: SacredColors.parchment.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'GitaLife',
                    style: GoogleFonts.cormorantSc(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      color: SacredColors.parchment.withOpacity(0.8),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Spiritual Companion',
                    style: GoogleFonts.jost(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: SacredColors.parchment.withOpacity(0.3),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 56),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        SacredColors.parchment.withOpacity(0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
