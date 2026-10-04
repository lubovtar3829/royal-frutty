import 'package:flutter/material.dart';

import '../theme.dart';

/// Claymorphism button. Primary = berry/gold gradient, secondary = tinted fill.
/// Icons are always 24px and the label line-height matches, so the row never
/// drifts out of alignment.
class ClayButton extends StatefulWidget {
  const ClayButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = true,
    this.height,
    this.fontSize,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool primary;
  final double? height;
  final double? fontSize;

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) => _press.forward();
  void _up(TapUpDetails _) => _press.reverse();
  void _cancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final bool primary = widget.primary;
    final double height = widget.height ?? (primary ? 64 : 52);
    final double fontSize = widget.fontSize ?? (primary ? 20 : 15);

    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _press,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: 1.0 - (_press.value * 0.05),
            child: child,
          );
        },
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    colors: <Color>[AppPalette.berry, AppPalette.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: primary ? null : AppPalette.royalA(0.10),
            borderRadius: BorderRadius.circular(primary ? 28 : 22),
            border: Border.all(
              color: primary
                  ? AppPalette.surfaceA(0.50)
                  : AppPalette.royalA(0.28),
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: primary
                    ? AppPalette.berry.withValues(alpha: 0.42)
                    : AppPalette.royalA(0.14),
                blurRadius: primary ? 22 : 12,
                offset: Offset(0, primary ? 10 : 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(
                  widget.icon,
                  size: 24,
                  color: primary ? AppPalette.cream : AppPalette.royal,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 24 / fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: primary ? 2.4 : 1.4,
                  color: primary ? AppPalette.cream : AppPalette.royal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular 48x48 icon button used in screen headers.
class ClayIconButton extends StatelessWidget {
  const ClayIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppPalette.creamA(0.92),
          shape: BoxShape.circle,
          border: Border.all(color: AppPalette.royalA(0.18), width: 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppPalette.royalA(0.20),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, size: 24, color: AppPalette.royal),
      ),
    );
  }
}
