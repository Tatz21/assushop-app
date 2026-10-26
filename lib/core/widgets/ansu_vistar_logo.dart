import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable brand logo component for ANSU VISTAR matching the official design.
class AnsuVistarLogo extends StatelessWidget {
  final double scale;
  final bool showTagline;
  final bool showSmileArc;

  const AnsuVistarLogo({
    super.key,
    this.scale = 1.0,
    this.showTagline = true,
    this.showSmileArc = true,
  });

  static const Color brandRed = Color(0xFFE51924);
  static const Color brandYellow = Color(0xFFFFC700);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Row: [ANSU Box]®   VISTAR
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ANSU Yellow Box with 4 Red Letter Tiles
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(2.2 * scale),
                  decoration: BoxDecoration(
                    color: brandYellow,
                    borderRadius: BorderRadius.circular(3.5 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: brandRed.withAlpha(25),
                        blurRadius: 6 * scale,
                        offset: Offset(0, 2 * scale),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLetterTile('A', scale),
                      SizedBox(width: 2.2 * scale),
                      _buildLetterTile('N', scale),
                      SizedBox(width: 2.2 * scale),
                      _buildLetterTile('S', scale),
                      SizedBox(width: 2.2 * scale),
                      _buildLetterTile('U', scale),
                    ],
                  ),
                ),
                // Registered Trademark Symbol ®
                Positioned(
                  top: -8 * scale,
                  right: -13 * scale,
                  child: Container(
                    width: 14 * scale,
                    height: 14 * scale,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: brandRed,
                        width: 1.2 * scale,
                      ),
                    ),
                    child: Text(
                      'R',
                      style: GoogleFonts.inter(
                        fontSize: 8.5 * scale,
                        fontWeight: FontWeight.w800,
                        color: brandRed,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 14 * scale),

            // VISTAR Bold Red Headline
            Text(
              'VISTAR',
              style: GoogleFonts.inter(
                fontSize: 33 * scale,
                fontWeight: FontWeight.w900,
                color: brandRed,
                letterSpacing: 0.8 * scale,
                height: 1.0,
              ),
            ),
          ],
        ),

        if (showTagline) ...[
          SizedBox(height: 22 * scale),
          // Tagline: "Connecting Every Market."
          Text(
            'Connecting Every Market.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.5 * scale,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: brandRed,
              letterSpacing: 0.15 * scale,
            ),
          ),
        ],

        if (showSmileArc) ...[
          SizedBox(height: 12 * scale),
          // Curved Smile Arc with Bullseye Target Node
          CustomPaint(
            size: Size(340 * scale, 76 * scale),
            painter: VistarSmileArcPainter(
              scale: scale,
              color: brandRed,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLetterTile(String letter, double scale) {
    return Container(
      width: 28 * scale,
      height: 28 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: brandRed,
        borderRadius: BorderRadius.circular(2 * scale),
      ),
      child: Text(
        letter,
        style: GoogleFonts.graduate(
          fontSize: 18 * scale,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}

/// Custom painter for the iconic curved smile arc with center target node.
class VistarSmileArcPainter extends CustomPainter {
  final double scale;
  final Color color;

  const VistarSmileArcPainter({
    this.scale = 1.0,
    this.color = const Color(0xFFE51924),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final targetCenter = Offset(w * 0.5, h * 0.72);
    final outerRadius = 18.0 * scale;
    final innerRadius = 9.5 * scale;

    // Draw the tapered smile arc paths
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Left tapered crescent
    final leftPath = Path();
    final leftStart = Offset(w * 0.04, h * 0.12);
    final leftConnectTop = Offset(targetCenter.dx - outerRadius * 0.95, targetCenter.dy - 3.2 * scale);
    final leftConnectBottom = Offset(targetCenter.dx - outerRadius * 0.95, targetCenter.dy + 3.2 * scale);

    leftPath.moveTo(leftStart.dx, leftStart.dy);
    // Upper curve down to target
    leftPath.quadraticBezierTo(
      w * 0.22,
      h * 0.44,
      leftConnectTop.dx,
      leftConnectTop.dy,
    );
    // Connect edge to target
    leftPath.lineTo(leftConnectBottom.dx, leftConnectBottom.dy);
    // Lower curve back to start, creating tapered crescent
    leftPath.quadraticBezierTo(
      w * 0.22,
      h * 0.49,
      leftStart.dx,
      leftStart.dy,
    );
    leftPath.close();
    canvas.drawPath(leftPath, arcPaint);

    // Right tapered crescent
    final rightPath = Path();
    final rightEnd = Offset(w * 0.96, h * 0.12);
    final rightConnectTop = Offset(targetCenter.dx + outerRadius * 0.95, targetCenter.dy - 3.2 * scale);
    final rightConnectBottom = Offset(targetCenter.dx + outerRadius * 0.95, targetCenter.dy + 3.2 * scale);

    rightPath.moveTo(rightConnectTop.dx, rightConnectTop.dy);
    // Upper curve to right end
    rightPath.quadraticBezierTo(
      w * 0.78,
      h * 0.44,
      rightEnd.dx,
      rightEnd.dy,
    );
    // Lower curve back from right end to target
    rightPath.quadraticBezierTo(
      w * 0.78,
      h * 0.49,
      rightConnectBottom.dx,
      rightConnectBottom.dy,
    );
    rightPath.close();
    canvas.drawPath(rightPath, arcPaint);

    // Center Bullseye Target Marker
    // 1. White background disc to cleanly occlude anything behind
    final whiteDiscPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(targetCenter, outerRadius, whiteDiscPaint);

    // 2. Outer red ring
    final outerRingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8 * scale
      ..isAntiAlias = true;
    canvas.drawCircle(targetCenter, outerRadius - (1.9 * scale), outerRingPaint);

    // 3. Inner solid red disc
    final innerDiscPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(targetCenter, innerRadius, innerDiscPaint);
  }

  @override
  bool shouldRepaint(covariant VistarSmileArcPainter oldDelegate) =>
      oldDelegate.scale != scale || oldDelegate.color != color;
}
