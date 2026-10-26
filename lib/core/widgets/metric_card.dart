import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum MetricCardType { green, blue, purple, red }

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final MetricCardType type;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color accentColor;

    switch (type) {
      case MetricCardType.green:
        bgColor = AppColors.greenCardBg;
        borderColor = AppColors.greenBorder;
        accentColor = AppColors.green;
        break;
      case MetricCardType.blue:
        bgColor = AppColors.blueCardBg;
        borderColor = AppColors.blueBorder;
        accentColor = AppColors.blue;
        break;
      case MetricCardType.purple:
        bgColor = AppColors.purpleCardBg;
        borderColor = AppColors.purpleBorder;
        accentColor = AppColors.purple;
        break;
      case MetricCardType.red:
        bgColor = const Color(0xFFFFF1F2);
        borderColor = const Color(0xFFFECDD3);
        accentColor = AppColors.primaryRed;
        break;
    }

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    icon,
                    size: 18,
                    color: accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
