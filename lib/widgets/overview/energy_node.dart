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
    final size = isCenter ? 88.0 : 72.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.6), width: isCenter ? 2.5 : 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: isCenter ? 20 : 12,
                spreadRadius: isCenter ? 4 : 2,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: isCenter ? 36 : 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
