import 'package:flutter/material.dart';

import '../game/recipes.dart';
import '../theme.dart';
import 'lane_board.dart';

/// Countdown pill. Turns berry-red and pulses once when the shift is nearly
/// over — a single forward/reverse pass, never a repeating controller.
class TimerPill extends StatefulWidget {
  const TimerPill({super.key, required this.secondsLeft});

  final int secondsLeft;

  @override
  State<TimerPill> createState() => _TimerPillState();
}

class _TimerPillState extends State<TimerPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  bool _pulsed = false;

  bool get _urgent => widget.secondsLeft <= 10;

  @override
  void didUpdateWidget(covariant TimerPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_urgent && !_pulsed) {
      _pulsed = true;
      _pulse.forward().whenComplete(() {
        if (mounted) {
          _pulse.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String text = widget.secondsLeft.toString().padLeft(2, '0');
    return AnimatedBuilder(
      animation: _pulse,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(scale: 1.0 + _pulse.value * 0.06, child: child);
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _urgent ? AppPalette.berry : AppPalette.royal,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppPalette.royalA(0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.timer, size: 20, color: AppPalette.gold),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                height: 20 / 18,
                fontWeight: FontWeight.w900,
                color: AppPalette.cream,
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three hearts; a spent one falls back to the outline glyph.
class HeartsRow extends StatelessWidget {
  const HeartsRow({super.key, required this.mistakes});

  final int mistakes;

  @override
  Widget build(BuildContext context) {
    final int left = 3 - mistakes;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              i < left ? Icons.favorite : Icons.favorite_border,
              size: 22,
              color: i < left ? AppPalette.berry : AppPalette.royalA(0.35),
            ),
          ),
      ],
    );
  }
}

/// Current order header: dish name plus one counter per required fruit.
class RecipeStrip extends StatelessWidget {
  const RecipeStrip({
    super.key,
    required this.recipe,
    required this.progress,
    required this.index,
  });

  final Recipe recipe;
  final Map<FruitType, int> progress;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppPalette.surfaceA(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: recipe.accent.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: recipe.accent.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'RECIPE ${index + 1} OF ${kRecipes.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: AppPalette.royalA(0.62),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                recipe.dish,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.royal,
                ),
              ),
            ],
          ),
          const Spacer(),
          for (final FruitType type in recipe.types)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _counter(type),
            ),
        ],
      ),
    );
  }

  Widget _counter(FruitType type) {
    final int have = progress[type] ?? 0;
    final int need = recipe.needs[type] ?? 0;
    final double value = need == 0 ? 0 : (have / need).clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FruitTile(type: type, size: 30),
            const SizedBox(width: 6),
            Text(
              '$have/$need',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: type.tint,
                fontFeatures: AppTheme.tabular,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            width: 56,
            height: 5,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppPalette.royalA(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(type.tint),
            ),
          ),
        ),
      ],
    );
  }
}
