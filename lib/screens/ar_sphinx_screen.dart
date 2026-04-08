import 'dart:async';
import 'dart:math' as math;
import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_plus/models/ar_node.dart';
import 'package:ar_flutter_plugin_plus/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../theme/app_theme.dart';
import '../widgets/ar_hud_overlay.dart';

/// The main AR screen.
///
/// Image tracking flow:
///   1. [onARViewCreated] — initialises session with [trackingImagePaths].
///   2. [_onImageDetected] fires whenever the engine finds the Sphinx image.
///   3. [_placeSphinxContent] creates (or updates) a 3D node at the image pose.
///   4. [_handleTap] shows an overlay when the user taps anywhere.
class ARSphinxScreen extends StatefulWidget {
  const ARSphinxScreen({super.key});

  @override
  State<ARSphinxScreen> createState() => _ARSphinxScreenState();
}

class _ARSphinxScreenState extends State<ARSphinxScreen>
    with TickerProviderStateMixin {
  // ── AR managers ────────────────────────────────────────────────────────────
  ARSessionManager? _sessionManager;
  ARObjectManager? _objectManager;

  // ── Scene state ────────────────────────────────────────────────────────────
  ARNode? _sphinxNode;
  bool _isInitializing = true;
  bool _isDetected = false;
  String? _detectedName;

  // ── Tap-effect overlay ─────────────────────────────────────────────────────
  bool _showTapEffect = false;
  late AnimationController _tapEffectController;
  late Animation<double> _tapEffectAnim;

  // ── Particle burst ─────────────────────────────────────────────────────────
  bool _showParticles = false;
  late AnimationController _particleController;
  late Animation<double> _particleAnim;

  // ── Sphinx model ────────────────────────────────────────────────────────────
  // Path to your local 3D model (must be a .glb or .gltf file).
  // 1. Add your file to: assets/models/sphinx_crown.gltf
  // 2. Ensure it's declared in pubspec.yaml.
  static const String _primaryWebModelPath =
      'https://modelviewer.dev/shared-assets/models/Astronaut.glb';



  @override
  void initState() {
    super.initState();

    _tapEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _tapEffectAnim = CurvedAnimation(
        parent: _tapEffectController, curve: Curves.easeOut);
    _tapEffectController.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _showTapEffect = false);
      }
    });

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _particleAnim = CurvedAnimation(
        parent: _particleController, curve: Curves.easeOut);
    _particleController.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _showParticles = false);
      }
    });
  }

  @override
  void dispose() {
    _tapEffectController.dispose();
    _particleController.dispose();
    if (_sphinxNode != null) {
      _objectManager?.removeNode(_sphinxNode!);
      _sphinxNode = null;
    }
    _sessionManager?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AR Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    _sessionManager = sessionManager;
    _objectManager = objectManager;

    // Called after image-tracking configuration completes.
    _sessionManager!.onImageTrackingConfigured = (success) {
      if (mounted) {
        setState(() => _isInitializing = false);
        if (!success) {
          _showSnackError('Image tracking configuration failed.');
        }
      }
    };

    // Initialise the AR session with image tracking enabled.
    try {
      await _sessionManager!.onInitialize(
        showFeaturePoints: false,
        showPlanes: false,
        showWorldOrigin: false,
        handleTaps: true,

        // ── Image tracking ────────────────────────────────────────────────────
        // The asset path must match exactly what is declared in pubspec.yaml.
        trackingImagePaths: ['assets/images/sphinx_face.jpg'],
        continuousImageTracking: true,
        imageTrackingUpdateIntervalMs: 100, // update every 100 ms

        // ── Lighting estimation ───────────────────────────────────────────────
        lightIntensityMultiplier: 2500,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _isInitializing = false);
      _showSnackError(
        e.message ??
            'ARCore initialization was interrupted. Please reopen AR view.',
      );
      return;
    }

    _objectManager!.onInitialize();

    // Wire up the image-detected callback.
    _sessionManager!.onImageDetected = _onImageDetected;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Image detection callback
  // ─────────────────────────────────────────────────────────────────────────

  void _onImageDetected(String imageName, Matrix4 transformation) {
    if (!mounted) return;

    setState(() {
      _isInitializing = false;
      _isDetected = true;
      _detectedName = imageName;
    });

    _placeSphinxContent(transformation);
  }

  Future<bool> _safeAddNode(ARNode node) async {
    try {
      final added = await _objectManager!
          .addNode(node)
          .timeout(const Duration(seconds: 4), onTimeout: () => false);
      return added == true;
    } catch (_) {
      return false;
    }
  }

  /// Creates (first call) or repositions (subsequent calls) the 3D AR node
  /// so that it sits on top of the detected Sphinx image in world space.
  Future<void> _placeSphinxContent(Matrix4 worldTransform) async {
    if (_objectManager == null) return;

    // Clone the world transform so we don't mutate the original.
    final modelTransform = Matrix4.fromFloat64List(worldTransform.storage);

    // Keep placement centered on target; small lift along negative Z helps avoid z-fighting.
    modelTransform.translateByVector3(vm.Vector3(0.0, 0.0, -0.08));

    // Large scale for clear first-run visibility.
    const double scale = 0.25;
    modelTransform.scaleByVector3(vm.Vector3(scale, scale, scale));

    if (_sphinxNode == null) {
      // ── First detection — create node with known-good remote GLB.
      final webNode = ARNode(
        type: NodeType.webGLB,
        uri: _primaryWebModelPath,
        transformation: modelTransform,
        name: 'sphinx_visible_test_model',
      );
      final webAdded = await _safeAddNode(webNode);
      if (webAdded == true && mounted) {
        setState(() {
          _sphinxNode = webNode;
        });
        _showSnackInfo('Model loaded. If visible, your local model was the issue.');
      } else if (mounted) {
        _showSnackError('Image detected, but model failed to load.');
      }
    } else {
      // ── Subsequent updates — reposition only ──────────────────────────────
      if (mounted) {
        setState(() {
          _sphinxNode!.transform = modelTransform;
        });
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tap interaction
  // ─────────────────────────────────────────────────────────────────────────

  void _handleTap() {
    if (!_isDetected) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _showTapEffect = true;
      _showParticles = true;
    });
    _tapEffectController.forward(from: 0);
    _particleController.forward(from: 0);
  }

  void _showSnackError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSnackInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueGrey.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          children: [
            // ── AR View ────────────────────────────────────────────────────
            ARView(
              onARViewCreated: onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.none,
            ),

            // Dim camera feed after detection to reduce background distraction.
            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                color: Colors.black.withValues(alpha: _isDetected ? 0.25 : 0.0),
              ),
            ),

            // ── HUD overlay ────────────────────────────────────────────────
            AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              opacity: _isDetected ? 0.22 : 1.0,
              child: ARHudOverlay(
                isDetected: _isDetected,
                detectedImageName: _detectedName,
                isInitializing: _isInitializing,
              ),
            ),

            // Positioned(
            //   left: 16,
            //   right: 16,
            //   top: MediaQuery.of(context).padding.top + 72,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //     decoration: BoxDecoration(
            //       color: Colors.black.withValues(alpha: 0.45),
            //       borderRadius: BorderRadius.circular(10),
            //       border: Border.all(color: Colors.white24),
            //     ),
            //     child: Text(
            //       _debugStatus,
            //       textAlign: TextAlign.center,
            //       style: GoogleFonts.inter(
            //         color: Colors.white,
            //         fontSize: 12,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // ),

            // ── Gold particle burst when tapped ────────────────────────────
            if (_showParticles)
              AnimatedBuilder(
                animation: _particleAnim,
                builder: (context, _) => CustomPaint(
                  painter: _ParticlePainter(progress: _particleAnim.value),
                  child: const SizedBox.expand(),
                ),
              ),

            // ── Golden flash + text when tapped ────────────────────────────
            if (_showTapEffect)
              FadeTransition(
                opacity: Tween<double>(begin: 0.4, end: 0.0)
                    .animate(_tapEffectAnim),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryGold.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                      radius: 0.9,
                    ),
                  ),
                  child: Center(
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.8)
                          .animate(_tapEffectAnim),
                      child: Text(
                        '✨  Ancient Power Awakened!  ✨',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          color: AppTheme.primaryGold,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: AppTheme.primaryGold.withValues(alpha: 0.9),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      elevation: 0,
      title: Text(
        'SPHINX AR',
        style: GoogleFonts.cinzel(
          color: AppTheme.primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: AppTheme.primaryGold),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

// ── Gold particle burst painter ─────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  static final List<_Particle> _particles = List.generate(48, (i) {
    final angle = (i / 48) * 2 * math.pi;
    final speed = 70.0 + (i % 6) * 35.0;
    final size = 4.0 + (i % 5).toDouble();
    return _Particle(angle: angle, speed: speed, size: size);
  });

  const _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint();

    for (final p in _particles) {
      final dist = p.speed * progress;
      final x = cx + dist * math.cos(p.angle);
      final y = cy + dist * math.sin(p.angle);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final radius = p.size * (1.0 - progress * 0.4);

      paint.color = AppTheme.primaryGold.withValues(alpha: opacity * 0.95);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}
