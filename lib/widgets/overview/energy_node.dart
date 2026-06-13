import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class EnergyNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isCenter;

  const EnergyNode({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = isCenter ? 88.0 : 72.0;
    return SizedBox(
      width: circleSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: isCenter ? 0.25 : 0.1),
              border: Border.all(
                color: color.withValues(alpha: isCenter ? 0.9 : 0.7),
                width: isCenter ? 2.5 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isCenter ? 0.35 : 0.2),
                  blurRadius: isCenter ? 20 : 10,
                  spreadRadius: isCenter ? 4 : 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: isCenter ? 36 : 28),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
