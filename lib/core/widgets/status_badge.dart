import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/outlet_model.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final OutletStatus status;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 10.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;

    switch (status) {
      case OutletStatus.visited:
        bgColor = AppColors.green;
        break;
      case OutletStatus.pending:
        bgColor = AppColors.blue;
        break;
      case OutletStatus.notVisited:
        bgColor = AppColors.gray;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
