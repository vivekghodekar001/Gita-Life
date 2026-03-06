import 'dart:math';
import 'package:flutter/material.dart';
import '../app/sacred_theme.dart';

// ═══════════════════════════════════════════════════════════════
//  Ancient Book Widget — Realistic leather-bound Bhagavad Gita
//  with gold inlay, page layers, candlelight sheen animation
// ═══════════════════════════════════════════════════════════════

class AncientBookWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final double width;
  final double height;

  const AncientBookWidget({
    super.key,
    this.onTap,
    this.width = 200,
    this.height = 270,
  });

  @override
  State<AncientBookWidget> createState() => _AncientBookWidgetState();
}

class _AncientBookWidgetState extends State<AncientBookWidget>
    with TickerProviderStateMixin {
  late final AnimationController _sheenController;
  late final AnimationController _flickerController;
  late final AnimationController _hoverController;
  late final Animation<double> _sheenAnimation;
  late final Animation<double> _flickerAnimation;
  late final Animation<double> _hoverAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Sheen / candlelight sweep on cover
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _sheenAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _sheenController, curve: Curves.easeInOut),
    );

    // Candle flicker glow beneath
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _flickerAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _flickerController, curve: Curves.easeInOut),
    );

    // Hover tilt
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _sheenController.dispose();
    _flickerController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The book with candle glow
        AnimatedBuilder(
          animation: Listenable.merge([_sheenAnimation, _flickerAnimation, _hoverAnimation]),
          builder: (context, child) {
            final hover = _hoverAnimation.value;
            final yOffset = -6.0 * hover;
            final rotY = -6.0 * hover * pi / 180;
            final rotX = 3.0 * hover * pi / 180;
            final scale = _isPressed ? 0.97 : 1.0;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..translate(0.0, yOffset, 0.0)
                ..rotateY(rotY)
                ..rotateX(rotX)
                ..scale(scale),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Candle glow under book
                  Positioned(
                    bottom: -12,
                    child: AnimatedBuilder(
                      animation: _flickerAnimation,
                      builder: (context, _) {
                        return Container(
                          width: 160,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Color.fromRGBO(180, 80, 20, 0.18 * _flickerAnimation.value),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // The Book
                  MouseRegion(
                    onEnter: (_) => _hoverController.forward(),
                    onExit: (_) => _hoverController.reverse(),
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isPressed = true),
                      onTapUp: (_) {
                        setState(() => _isPressed = false);
                        widget.onTap?.call();
                      },
                      onTapCancel: () => setState(() => _isPressed = false),
                      child: SizedBox(
                        width: widget.width,
                        height: widget.height,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Page layers (visible on right side)
                            Positioned(
                              right: -3,
                              top: 4,
                              bottom: 4,
                              width: 14,
                              child: _buildPageLayers(),
                            ),
                            // Spine shadow on left
                            Positioned(
                              left: -14,
                              top: 3,
                              bottom: 3,
                              width: 14,
                              child: _buildSpineShadow(),
                            ),
                            // Main book body
                            Positioned.fill(
                              child: _buildBookBody(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 18),
        // "Open to read" label with breathing animation
        _BreathingLabel(text: 'Open to read · swipe for verses'),
      ],
    );
  }

  Widget _buildBookBody() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3),
          bottomLeft: Radius.circular(3),
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          // Deep shadow behind
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 40,
            offset: const Offset(6, 6),
          ),
          // Warm glow
          BoxShadow(
            color: const Color(0xFF783C0A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(3),
          bottomLeft: Radius.circular(3),
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: Stack(
          children: [
            // Leather base texture
            Positioned.fill(child: _buildLeatherTexture()),
            // Aged vignette edges
            Positioned.fill(child: _buildAgedEdges()),
            // Spine
            _buildSpine(),
            // Gold edges top/bottom
            _buildGoldEdges(),
            // Gold inlay frame
            _buildGoldFrame(),
            // Center emblem (OM + lines)
            _buildEmblem(),
            // Title text
            _buildTitleText(),
            // Candlelight sheen overlay
            AnimatedBuilder(
              animation: _sheenAnimation,
              builder: (context, _) {
                return Positioned(
                  left: 25,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: _sheenAnimation.value * 0.6,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-0.3, -1),
                          end: Alignment(1, 1),
                          colors: [
                            Color(0x0FFFC864),
                            Colors.transparent,
                            Color(0x1A000000),
                          ],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeatherTexture() {
    return CustomPaint(
      painter: _LeatherTexturePainter(),
    );
  }

  Widget _buildAgedEdges() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.6, -0.8),
          radius: 1.0,
          colors: [
            const Color(0xFF502A0A).withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.6, 0.8),
            radius: 1.0,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.transparent,
            ],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpine() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 22,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF0E0804),
              Color(0xFF1C1008),
              Color(0xFF281606),
              Color(0xFF1C1008),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x66000000),
              offset: Offset(2, 0),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 1,
            height: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  SacredColors.parchment.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoldEdges() {
    return Stack(
      children: [
        // Top gold edge
        Positioned(
          left: 20,
          right: 0,
          top: 0,
          height: 3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B6914),
                  Color(0xFFC8A96E),
                  Color(0xFFD4AF37),
                  Color(0xFFA07820),
                  Color(0xFF8B6914),
                ],
              ),
            ),
          ),
        ),
        // Bottom gold edge
        Positioned(
          left: 20,
          right: 0,
          bottom: 0,
          height: 3,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B6914),
                  Color(0xFFC8A96E),
                  Color(0xFFD4AF37),
                  Color(0xFFA07820),
                  Color(0xFF8B6914),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoldFrame() {
    return Positioned(
      left: 28,
      right: 10,
      top: 12,
      bottom: 12,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: SacredColors.parchment.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: SacredColors.parchment.withOpacity(0.12)),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _buildEmblem() {
    return Positioned(
      left: 28,
      right: 10,
      top: 0,
      bottom: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top ornamental line
          _buildEmblemLine(),
          const SizedBox(height: 8),
          // OM symbol
          Text(
            'ॐ',
            style: TextStyle(
              fontSize: 44,
              color: SacredColors.parchment.withOpacity(0.55),
              fontFamily: 'NotoSerifDevanagari',
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          // Bottom ornamental line
          _buildEmblemLine(),
        ],
      ),
    );
  }

  Widget _buildEmblemLine() {
    return Container(
      width: 60,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            SacredColors.parchment.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildTitleText() {
    return Positioned(
      left: 28,
      right: 10,
      bottom: 20,
      child: Column(
        children: [
          Text(
            'BHAGAVAD GITA',
            style: SacredTextStyles.bookTitle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'As It Is',
            style: SacredTextStyles.bookSubtitle(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageLayers() {
    return Stack(
      children: [
        // Outermost page
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFFE8D5B0), Color(0xFFD4BE8A)],
              ),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
          ),
        ),
        // Middle page
        Positioned(
          right: 1,
          top: 0,
          bottom: 0,
          left: 2,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFFDEC890), Color(0xFFC8A870)],
              ),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(3)),
            ),
          ),
        ),
        // Innermost page
        Positioned(
          right: 3,
          top: 0,
          bottom: 0,
          left: 4,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFFC8B878), Color(0xFFB89E60)],
              ),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpineShadow() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.5),
            const Color(0xFF0A0604),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Leather Texture Painter — Renders realistic leather grain
// ═══════════════════════════════════════════════════════════════

class _LeatherTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Base leather gradient
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment(-0.3, -1),
        end: Alignment(0.5, 1),
        colors: [
          Color(0xFF2C1606),
          Color(0xFF3D2008),
          Color(0xFF4A2A0A),
          Color(0xFF3A1E08),
          Color(0xFF2E1608),
          Color(0xFF3D2210),
          Color(0xFF261408),
          Color(0xFF1E1006),
        ],
        stops: [0.0, 0.15, 0.30, 0.45, 0.60, 0.75, 0.90, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Add subtle grain lines (vertical)
    final grainPaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 0.5;
    final random = Random(42);
    for (double x = 0; x < size.width; x += 4 + random.nextDouble() * 4) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + random.nextDouble() * 2, size.height),
        grainPaint,
      );
    }

    // Horizontal grain (less frequent)
    for (double y = 0; y < size.height; y += 6 + random.nextDouble() * 6) {
      grainPaint.color = Colors.black.withOpacity(0.02 + random.nextDouble() * 0.02);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + random.nextDouble() * 2),
        grainPaint,
      );
    }

    // Leather imperfection spots (subtle dark patches)
    final spotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 12; i++) {
      spotPaint.color = Colors.black.withOpacity(0.02 + random.nextDouble() * 0.03);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            random.nextDouble() * size.width,
            random.nextDouble() * size.height,
          ),
          width: 8 + random.nextDouble() * 20,
          height: 4 + random.nextDouble() * 12,
        ),
        spotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
//  Breathing Label — Fades in and out gently
// ═══════════════════════════════════════════════════════════════

class _BreathingLabel extends StatefulWidget {
  final String text;
  const _BreathingLabel({required this.text});

  @override
  State<_BreathingLabel> createState() => _BreathingLabelState();
}

class _BreathingLabelState extends State<_BreathingLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Text(
            widget.text,
            style: SacredTextStyles.bookSubtitle(fontSize: 11).copyWith(
              color: SacredColors.parchment.withOpacity(0.3),
              letterSpacing: 1.5,
            ),
          ),
        );
      },
    );
  }
}
