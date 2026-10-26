import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AnsuLogo extends StatelessWidget {
  final double scale;
  final bool showTagline;

  const AnsuLogo({
    super.key,
    this.scale = 1.0,
    this.showTagline = true,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ANSU Red Box with registration mark
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 6 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(6 * scale),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withAlpha(50),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 3 * scale),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLetter('A', scale),
                  SizedBox(width: 6 * scale),
                  _buildLetter('N', scale),
                  SizedBox(width: 6 * scale),
                  _buildLetter('S', scale),
                  SizedBox(width: 6 * scale),
                  _buildLetter('U', scale),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 3 * scale, top: 1 * scale),
              child: Text(
                '®',
                style: GoogleFonts.inter(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6 * scale),

        // Hindi Text "बज्र दन्ता" with ®
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'बज्र दन्ता',
              style: GoogleFonts.poppins(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryRed,
                letterSpacing: 0.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 2 * scale),
              child: Text(
                '®',
                style: GoogleFonts.inter(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2 * scale),

        // Curved Smile Arc with BAJRA DANTA text
        CustomPaint(
          size: Size(180 * scale, 26 * scale),
          painter: _SmileArcPainter(scale: scale),
          child: SizedBox(
            width: 180 * scale,
            height: 26 * scale,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 2 * scale),
                child: Text(
                  'BAJRA DANTA',
                  style: GoogleFonts.inter(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryRed,
                    letterSpacing: 1.5 * scale,
                  ),
                ),
              ),
            ),
          ),
        ),

        if (showTagline) ...[
          SizedBox(height: 18 * scale),
          Text(
            'Sales Team App',
            style: GoogleFonts.inter(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Field. Focus. Growth.',
            style: GoogleFonts.inter(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );
  }

  static Widget _buildLetter(String letter, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 1 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3 * scale),
      ),
      child: Text(
        letter,
        style: GoogleFonts.inter(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryRed,
        ),
      ),
    );
  }
}

class _SmileArcPainter extends CustomPainter {
  final double scale;

  _SmileArcPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * scale
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(10 * scale, 4 * scale);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 2 * scale,
      size.width - 10 * scale,
      4 * scale,
    );

    canvas.drawPath(path, paint);

    // Draw end dots
    final dotPaint = Paint()
      ..color = AppColors.primaryRed
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(10 * scale, 4 * scale), 2.5 * scale, dotPaint);
    canvas.drawCircle(
      Offset(size.width - 10 * scale, 4 * scale),
      2.5 * scale,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SmileArcPainter oldDelegate) =>
      oldDelegate.scale != scale;
}
