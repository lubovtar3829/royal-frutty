import 'package:flutter/material.dart';

import '../theme.dart';

/// Base clay surface: soft white fill, accent border, double shadow.
class ClayCard extends StatelessWidget {
  const ClayCard({
    super.key,
    required this.child,
    required this.accent,
    this.radius = 26,
    this.padding = const EdgeInsets.all(14),
    this.height,
  });

  final Widget child;
  final Color accent;
  final double radius;
  final EdgeInsets padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppPalette.surfaceA(0.94),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: accent.withValues(alpha: 0.32), width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Single stat pill. Shared by MenuScreen and ResultScreen so the two screens
/// never drift apart visually.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.surfaceA(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: valueColor.withValues(alpha: 0.33),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: valueColor.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: valueColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: valueColor,
              fontFeatures: AppTheme.tabular,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppPalette.royalA(0.62),
            ),
          ),
        ],
      ),
    );
  }
}
