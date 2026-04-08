
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ARHudOverlay extends StatefulWidget {
  final bool isDetected;
  final String? detectedImageName;
  final bool isInitializing;

  const ARHudOverlay({
    super.key,
    required this.isDetected,
    this.detectedImageName,
    required this.isInitializing,
  });

  @override
  State<ARHudOverlay> createState() => _ARHudOverlayState();
}

class _ARHudOverlayState extends State<ARHudOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _detectedController;
  late Animation<double> _pulseAnim;
  late Animation<double> _detectedAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _detectedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _detectedAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _detectedController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(ARHudOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDetected && !oldWidget.isDetected) {
      _detectedController.forward(from: 0);
    } else if (!widget.isDetected && oldWidget.isDetected) {
      _detectedController.reverse();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _detectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Corner scan brackets
        _buildScanBrackets(),

        // Top status bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStatusBadge(),
            ),
          ),
        ),

        // Bottom info card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildInfoCard(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanBrackets() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        final color = widget.isDetected
            ? AppTheme.primaryGold
            : Colors.white.withValues(alpha: widget.isInitializing ? 0.3 : _pulseAnim.value);
        return CustomPaint(
          painter: _ScanBracketPainter(color: color),
          child: const SizedBox.expand(),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    IconData icon;
    String label;

    if (widget.isInitializing) {
      badgeColor = Colors.white.withValues(alpha: 0.15);
      icon = Icons.hourglass_empty_rounded;
      label = 'Initializing AR Session…';
    } else if (widget.isDetected) {
      badgeColor = AppTheme.primaryGold.withValues(alpha: 0.2);
      icon = Icons.verified_rounded;
      label = 'Sphinx Detected!';
    } else {
      badgeColor = Colors.black.withValues(alpha: 0.35);
      icon = Icons.search_rounded;
      label = 'Scanning for Sphinx…';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDetected
              ? AppTheme.primaryGold.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: widget.isDetected
            ? [
                BoxShadow(
                  color: AppTheme.primaryGold.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isInitializing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            )
          else
            Icon(icon,
                size: 16,
                color:
                    widget.isDetected ? AppTheme.primaryGold : Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: widget.isDetected ? AppTheme.primaryGold : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return ScaleTransition(
      scale: widget.isDetected ? _detectedAnim : const AlwaysStoppedAnimation(1.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDetected
              ? AppTheme.primaryGold.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDetected
                ? AppTheme.primaryGold.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),

        ),
        child: widget.isDetected
            ? Row(
                children: [
                  const Icon(Icons.touch_app_rounded,
                      color: AppTheme.primaryGold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ancient Power Activated',
                          style: GoogleFonts.cinzel(
                            color: AppTheme.primaryGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap the Sphinx crown to interact',
                          style: GoogleFonts.inter(
                            color: AppTheme.onSurfaceDim,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, _) => Icon(
                      Icons.center_focus_strong_rounded,
                      color: Colors.white.withValues(alpha: _pulseAnim.value),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Point camera at the Sphinx face image',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Custom painter for scan-bracket corners
class _ScanBracketPainter extends CustomPainter {
  final Color color;
  _ScanBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 32.0;
    const bracketLen = 28.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const halfW = 90.0;
    const halfH = 90.0;

    final corners = [
      [cx - halfW + margin, cy - halfH + margin, 1.0, 1.0],
      [cx + halfW - margin, cy - halfH + margin, -1.0, 1.0],
      [cx - halfW + margin, cy + halfH - margin, 1.0, -1.0],
      [cx + halfW - margin, cy + halfH - margin, -1.0, -1.0],
    ];

    for (final c in corners) {
      final x = c[0];
      final y = c[1];
      final dx = c[2] * bracketLen;
      final dy = c[3] * bracketLen;
      canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanBracketPainter old) => old.color != color;
}
