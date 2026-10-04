import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_engine.dart';
import '../game/recipes.dart';
import '../theme.dart';
import '../widgets/clay_button.dart';
import '../widgets/clay_card.dart';
import '../widgets/lane_board.dart';

/// End-of-shift card. Distinct overlay from both menu and gameplay so the
/// capture pipeline always sees a third, clearly different frame.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.summary,
    required this.onPlayAgain,
    required this.onMenu,
  });

  final RoundSummary summary;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.summary.reason) {
      case ResultReason.allRecipes:
        return 'ROYAL FEAST!';
      case ResultReason.mistakes:
        return 'SHIFT OVER!';
      case ResultReason.timeUp:
        return 'TIME UP!';
    }
  }

  Color get _titleColor {
    switch (widget.summary.reason) {
      case ResultReason.allRecipes:
        return AppPalette.leaf;
      case ResultReason.mistakes:
        return AppPalette.berry;
      case ResultReason.timeUp:
        return AppPalette.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final RoundSummary s = widget.summary;
    final Color wash = s.isWin ? AppPalette.leaf : AppPalette.royal;
    final Recipe next = kRecipes[s.dishes.clamp(0, kRecipes.length - 1) %
        kRecipes.length];

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgMenu),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                wash.withValues(alpha: s.isWin ? 0.35 : 0.45),
                AppPalette.creamA(0.92),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 4),
                  Image.asset(
                    AppAssets.spriteCrown,
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      color: _titleColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _medallions(s.dishes),
                  const SizedBox(height: 18),
                  _stats(s),
                  const Spacer(),
                  _nextRecipe(next),
                  const SizedBox(height: 16),
                  ClayButton(
                    label: 'PLAY AGAIN',
                    icon: Icons.refresh,
                    onTap: widget.onPlayAgain,
                  ),
                  const SizedBox(height: 12),
                  ClayButton(
                    label: 'MENU',
                    icon: Icons.home,
                    primary: false,
                    onTap: widget.onMenu,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _medallions(int dishes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < kRecipes.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _intro,
                curve: Interval(i * 0.12, 0.6 + i * 0.12, curve: Curves.easeOut),
              ),
              child: _medallion(kRecipes[i], i < dishes),
            ),
          ),
      ],
    );
  }

  Widget _medallion(Recipe recipe, bool done) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: done
              ? AppPalette.surfaceA(0.94)
              : AppPalette.royalA(0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: done
                ? recipe.accent.withValues(alpha: 0.55)
                : AppPalette.royalA(0.18),
            width: 2,
          ),
        ),
        child: done
            ? Stack(
                children: <Widget>[
                  Center(
                    child: FruitTile(type: recipe.types.first, size: 38),
                  ),
                  const Positioned(
                    right: 8,
                    bottom: 8,
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppPalette.leaf,
                    ),
                  ),
                ],
              )
            : Icon(
                Icons.lock_outline,
                size: 22,
                color: AppPalette.royalA(0.45),
              ),
      ),
    );
  }

  Widget _stats(RoundSummary s) {
    final List<Widget> cards = <Widget>[];
    if (s.dishes > 0) {
      cards.add(
        StatCard(
          value: '${s.dishes}/${kRecipes.length}',
          label: 'dishes',
          valueColor: AppPalette.leaf,
        ),
      );
    }
    if (s.accuracy > 0) {
      cards.add(
        StatCard(
          value: '${s.accuracy}%',
          label: 'accuracy',
          valueColor: AppPalette.gold,
        ),
      );
    }
    if (s.caught > 0) {
      cards.add(
        StatCard(
          value: '${s.caught}',
          label: 'caught',
          valueColor: AppPalette.berry,
        ),
      );
    }
    if (cards.length < 3 && s.mistakes > 0) {
      cards.add(
        StatCard(
          value: '${s.mistakes}',
          label: 'missed',
          valueColor: AppPalette.royal,
        ),
      );
    }
    if (cards.length < 2) {
      return const SizedBox.shrink();
    }

    final List<Widget> row = <Widget>[];
    for (int i = 0; i < cards.length && i < 3; i++) {
      if (i > 0) {
        row.add(const SizedBox(width: 10));
      }
      row.add(Expanded(child: cards[i]));
    }
    return Row(children: row);
  }

  Widget _nextRecipe(Recipe next) {
    return ClayCard(
      accent: next.accent,
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'NEXT RECIPE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AppPalette.royalA(0.62),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next.dish,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppPalette.royal,
                  ),
                ),
              ],
            ),
          ),
          FruitTile(type: next.types.first, size: 36),
          const SizedBox(width: 6),
          FruitTile(type: next.types.last, size: 36),
        ],
      ),
    );
  }
}
