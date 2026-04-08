import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'ar_sphinx_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late Animation<double> _shimmerAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shimmerAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background — animated sand-dune gradient
          _buildBackground(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildSphinxCard(),
                  const SizedBox(height: 32),
                  _buildInstructions(),
                  const SizedBox(height: 40),
                  _buildLaunchButton(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B0B0F),
            Color(0xFF12100A),
            Color(0xFF1A1408),
            Color(0xFF0B0B0F),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _StarFieldPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Egyptian eye icon
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, _) => Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withValues(alpha: _glowAnim.value * 0.6),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.remove_red_eye_outlined,
              color: AppTheme.primaryGold,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'SPHINX AR',
          style: GoogleFonts.cinzel(
            color: AppTheme.primaryGold,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Augmented Reality Experience',
          style: GoogleFonts.inter(
            color: AppTheme.onSurfaceDim,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          width: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, AppTheme.primaryGold, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSphinxCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        ),
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withValues(alpha: _glowAnim.value * 0.25),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Sphinx image
                Image.asset(
                  'assets/images/sphinx_face.jpg',
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                ),
                // Shimmer overlay
                AnimatedBuilder(
                  animation: _shimmerAnim,
                  builder: (context, _) => Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(_shimmerAnim.value - 1, -0.3),
                        end: Alignment(_shimmerAnim.value + 0.5, 0.3),
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Gold corner decoration
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded,
                            color: AppTheme.primaryGold, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'USE THIS IMAGE AS TRACKING TARGET',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppTheme.primaryGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    final steps = [
      (Icons.print_rounded, 'Print or display this Sphinx image on your screen'),
      (Icons.camera_alt_rounded, 'Open the AR Experience and point your camera at it'),
      (Icons.auto_awesome_rounded, 'Watch the ancient pharaoh crown appear in AR'),
      (Icons.touch_app_rounded, 'Tap the 3D model to trigger a special effect'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HOW TO USE',
              style: GoogleFonts.cinzel(
                color: AppTheme.primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < steps.length - 1 ? 14 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(step.$1, color: AppTheme.primaryGold, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          step.$2,
                          style: GoogleFonts.inter(
                            color: AppTheme.onSurface,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLaunchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGold.withValues(alpha: _glowAnim.value * 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ARSphinxScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            },
            icon: const Icon(Icons.view_in_ar_rounded),
            label: const Text('ENTER AR EXPERIENCE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: const Color(0xFF1A1200),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              textStyle: GoogleFonts.cinzel(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Star-field background painter
class _StarFieldPainter extends CustomPainter {
  final _rng = math.Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < 60; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height * 0.5;
      final r = _rng.nextDouble() * 1.2 + 0.3;
      paint.color = Colors.white.withValues(alpha: _rng.nextDouble() * 0.3 + 0.05);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => false;
}
