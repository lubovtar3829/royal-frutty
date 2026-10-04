import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_engine.dart';
import '../game/recipes.dart';
import '../theme.dart';

/// The only place a fruit is rendered — always a fixed square, BoxFit.contain.
class FruitTile extends StatelessWidget {
  const FruitTile({super.key, required this.type, required this.size});

  final FruitType type;
  final double size;

  static String assetFor(FruitType type) {
    switch (type) {
      case FruitType.strawberry:
        return AppAssets.spriteStrawberry;
      case FruitType.lemon:
        return AppAssets.spriteLemon;
      case FruitType.apple:
        return AppAssets.spriteApple;
      case FruitType.blueberry:
        return AppAssets.spriteBlueberry;
      case FruitType.plum:
        return AppAssets.spritePlum;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetFor(type),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Three-lane playfield. Geometry follows the frame rule so nothing can
/// overflow the rounded board edge.
class LaneBoard extends StatelessWidget {
  const LaneBoard({
    super.key,
    required this.engine,
    required this.onLaneTap,
  });

  static const double frame = 10; // padding 8 + border 2
  static const double basketBottom = 120;

  final GameEngine engine;
  final void Function(int lane) onLaneTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double areaH = constraints.maxHeight;
        final double maxW = math.min(constraints.maxWidth - 32, 380);
        final double laneW = ((maxW - 2 * frame) / 3).floorToDouble();
        final double boardW = laneW * 3 + 2 * frame;

        final double fruitSize = math.min(laneW * 0.62, 76);
        final double basketSize = math.min(laneW * 0.80, 96);

        double travel =
            areaH - basketBottom - basketSize * 0.45 - fruitSize;
        if (travel < 60) travel = math.max(areaH * 0.55, 60);

        final int now = engine.elapsedMs;
        final double popScale = _popScale(now);

        return Center(
          child: SizedBox(
            width: boardW,
            height: areaH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppPalette.royalA(0.07),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: AppPalette.royalA(0.16),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 1; i < 3; i++)
                    Positioned(
                      left: frame + laneW * i - 1,
                      top: 16,
                      bottom: 16,
                      width: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppPalette.royalA(0.10),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  for (final FallingFruit fruit in engine.fruits)
                    Positioned(
                      top: fruit.progress(now) * travel,
                      left: frame +
                          fruit.lane * laneW +
                          (laneW - fruitSize) / 2,
                      child: FruitTile(type: fruit.type, size: fruitSize),
                    ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    bottom: basketBottom,
                    left: frame +
                        engine.basketLane * laneW +
                        (laneW - basketSize) / 2,
                    child: Transform.scale(
                      scale: popScale,
                      child: Image.asset(
                        AppAssets.spriteBasket,
                        width: basketSize,
                        height: basketSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  for (final ScorePopup popup in engine.popups)
                    Positioned(
                      bottom: basketBottom +
                          basketSize +
                          ((now - popup.bornMs) / 420.0).clamp(0.0, 1.0) * 26,
                      left: frame + popup.lane * laneW,
                      width: laneW,
                      child: Opacity(
                        opacity: 1.0 -
                            ((now - popup.bornMs) / 420.0).clamp(0.0, 1.0),
                        child: Text(
                          '+1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: engine.recipe.accent,
                          ),
                        ),
                      ),
                    ),
                  if (now < engine.mistakeFlashUntilMs)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppPalette.berry.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                  for (int i = 0; i < 3; i++)
                    Positioned(
                      left: frame + laneW * i,
                      top: 0,
                      bottom: 0,
                      width: laneW,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onLaneTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _popScale(int now) {
    if (engine.basketPopAtMs < 0) return 1.0;
    final double t = (now - engine.basketPopAtMs) / 220.0;
    if (t < 0 || t > 1) return 1.0;
    return 1.0 + 0.12 * math.sin(t * math.pi);
  }
}
