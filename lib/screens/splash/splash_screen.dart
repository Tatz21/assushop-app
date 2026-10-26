import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/ansu_vistar_logo.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../state/app_state.dart';
import '../login/login_screen.dart';
import '../main_navigation_shell.dart';

/// Pixel-perfect Splash Screen matching the ANSU VISTAR design reference.
class SplashScreen extends StatefulWidget {
  final Duration duration;
  final bool autoNavigate;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2800),
    this.autoNavigate = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();

    if (widget.autoNavigate) {
      _navigationTimer = Timer(widget.duration, _navigateToNext);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final appState = Provider.of<AppState>(context, listen: false);
    final targetScreen = appState.isLoggedIn
        ? const MainNavigationShell()
        : const ResponsiveWrapper(child: LoginScreen());

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep status bar icons dark in top white section
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToNext,
        child: Stack(
          children: [
            // Layered Organic Waves Background (Bottom Section)
            Positioned.fill(
              child: CustomPaint(
                painter: SplashWavePainter(),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenHeight = constraints.maxHeight;
                      final screenWidth = constraints.maxWidth;
                      final isTablet = screenWidth > 600;
                      final scale = isTablet ? 1.15 : 1.0;

                      return Stack(
                        children: [
                          // Top Brand Section: ANSU VISTAR + Tagline + Smile Arc
                          Positioned(
                            top: screenHeight * 0.16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: AnsuVistarLogo(scale: scale),
                            ),
                          ),

                          // Bottom Footer: Stylized Leaf Icon + "Healthy People Healthier India"
                          Positioned(
                            bottom: screenHeight * 0.06,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // White Leaf Icon
                                  CustomPaint(
                                    size: Size(34 * scale, 38 * scale),
                                    painter: _SplashLeafPainter(scale: scale),
                                  ),
                                  SizedBox(width: 14 * scale),
                                  // Tagline text
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Healthy People',
                                        style: GoogleFonts.inter(
                                          fontSize: 17.5 * scale,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(height: 1 * scale),
                                      Text(
                                        'Healthier India',
                                        style: GoogleFonts.inter(
                                          fontSize: 17.5 * scale,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the layered organic background waves matching the design.
class SplashWavePainter extends CustomPainter {
  static const Color brandRed = Color(0xFFE51924);
  static const Color softPink = Color(0xFFFFB3B8);
  static const Color midCoral = Color(0xFFFF7A82);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Layer 1: Soft Light Pink/Coral Swoosh (Top-Left Layer)
    final pinkPaint = Paint()
      ..color = softPink
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path1 = Path();
    path1.moveTo(0, h * 0.52);
    path1.cubicTo(
      w * 0.14,
      h * 0.62,
      w * 0.38,
      h * 0.69,
      w * 0.70,
      h * 0.72,
    );
    path1.lineTo(w, h * 0.74);
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();
    canvas.drawPath(path1, pinkPaint);

    // 2. Layer 2: Mid Coral Swoosh (Below Pink on Left)
    final coralPaint = Paint()
      ..color = midCoral
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path2 = Path();
    path2.moveTo(0, h * 0.59);
    path2.cubicTo(
      w * 0.16,
      h * 0.66,
      w * 0.42,
      h * 0.72,
      w * 0.75,
      h * 0.73,
    );
    path2.lineTo(w, h * 0.75);
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();
    canvas.drawPath(path2, coralPaint);

    // 3. Layer 3: Solid Brand Red Bottom Section (Foreground)
    final redPaint = Paint()
      ..color = brandRed
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path3 = Path();
    path3.moveTo(0, h * 0.655);
    // Smooth asymmetric wave: dips gently in center-left, curves gracefully up to right edge
    path3.cubicTo(
      w * 0.32,
      h * 0.745,
      w * 0.68,
      h * 0.740,
      w,
      h * 0.650,
    );
    path3.lineTo(w, h);
    path3.lineTo(0, h);
    path3.close();
    canvas.drawPath(path3, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylized white organic leaf painter matching the design reference.
class _SplashLeafPainter extends CustomPainter {
  final double scale;

  _SplashLeafPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Stylized botanical leaf shape with inner swoosh notch
    final leafPath = Path();

    // Leaf stem base at bottom-left
    leafPath.moveTo(w * 0.22, h * 0.94);

    // Outer back curve sweeping up to pointed leaf tip
    leafPath.cubicTo(
      w * 0.02,
      h * 0.78,
      0,
      h * 0.36,
      w * 0.96,
      h * 0.08,
    );

    // Right top edge curving back down
    leafPath.cubicTo(
      w * 0.88,
      h * 0.28,
      w * 0.72,
      h * 0.50,
      w * 0.44,
      h * 0.62,
    );

    // Inner contour curving towards base
    leafPath.cubicTo(
      w * 0.35,
      h * 0.68,
      w * 0.26,
      h * 0.80,
      w * 0.22,
      h * 0.94,
    );

    leafPath.close();
    canvas.drawPath(leafPath, paint);

    // Second smaller bottom-left accent leaf lobe
    final lobePath = Path();
    lobePath.moveTo(w * 0.22, h * 0.94);
    lobePath.cubicTo(
      w * 0.12,
      h * 0.88,
      w * 0.08,
      h * 0.70,
      w * 0.30,
      h * 0.58,
    );
    lobePath.cubicTo(
      w * 0.26,
      h * 0.72,
      w * 0.24,
      h * 0.84,
      w * 0.22,
      h * 0.94,
    );
    lobePath.close();
    canvas.drawPath(lobePath, paint);
  }

  @override
  bool shouldRepaint(covariant _SplashLeafPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
