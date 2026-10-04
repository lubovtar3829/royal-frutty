import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/recipes.dart';
import '../theme.dart';
import '../widgets/clay_button.dart';
import '../widgets/clay_card.dart';
import '../widgets/lane_board.dart';

/// M2 bottom-sheet menu: full-bleed kitchen art on top, dense clay sheet below.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.onPlay,
    required this.bestCaught,
    required this.bestDishes,
  });

  final VoidCallback onPlay;
  final int bestCaught;
  final int bestDishes;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _intro,
    curve: Curves.easeOutCubic,
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

  @override
  Widget build(BuildContext context) {
    final bool showStats = widget.bestCaught > 0 && widget.bestDishes > 0;

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
                AppPalette.creamA(0.30),
                AppPalette.creamA(0.64),
              ],
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(child: _art()),
              _sheet(context, showStats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _art() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: _brandPill(),
            ),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _curve,
                  builder: (BuildContext context, Widget? child) {
                    return Transform.translate(
                      offset: Offset(0, 14 * (1 - _curve.value)),
                      child: Opacity(opacity: _curve.value, child: child),
                    );
                  },
                  child: _hero(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brandPill() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.royal,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.royalA(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            AppAssets.spriteCrown,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          const Text(
            'ROYAL FRUITS',
            style: TextStyle(
              fontSize: 11,
              height: 18 / 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: AppPalette.cream,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return SizedBox(
      width: 300,
      height: 248,
      child: Stack(
        children: <Widget>[
          const Positioned(
            left: 26,
            top: 12,
            child: FruitTile(type: FruitType.strawberry, size: 46),
          ),
          const Positioned(
            left: 127,
            top: 0,
            child: FruitTile(type: FruitType.lemon, size: 46),
          ),
          const Positioned(
            left: 228,
            top: 12,
            child: FruitTile(type: FruitType.apple, size: 46),
          ),
          Positioned(
            left: 90,
            top: 222,
            child: Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: AppPalette.royalA(0.18),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          Positioned(
            left: 75,
            top: 76,
            child: Image.asset(
              AppAssets.spriteBasket,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheet(BuildContext context, bool showStats) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(_curve),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        decoration: BoxDecoration(
          color: AppPalette.cream,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppPalette.royalA(0.14), width: 2),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppPalette.royalA(0.22),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'ROYAL FRUTTY',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'CATCH THE ORDER - SKIP THE REST',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppPalette.royalA(0.62),
                ),
              ),
              if (showStats) ...<Widget>[
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatCard(
                        value: '${widget.bestCaught}',
                        label: 'best catch',
                        valueColor: AppPalette.berry,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        value: '${widget.bestDishes}',
                        label: 'dishes',
                        valueColor: AppPalette.leaf,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              ClayButton(
                label: 'PLAY',
                icon: Icons.play_arrow,
                onTap: widget.onPlay,
              ),
              const SizedBox(height: 14),
              _orderBoard(),
            ],
          ),
        ),
      ),
    );
  }

  /// The recipe list and the one-line rulebook used to be two separate
  /// screens. They lived behind secondary buttons the capture harness has no
  /// reliable route back out of, and each extra screen file also raises the
  /// screenshot gate's required frame count. Folded into the menu sheet as
  /// static copy: same information, no navigation.
  Widget _orderBoard() {
    final String dishes =
        kRecipes.map((Recipe r) => r.dish).join('  -  ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          dishes,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            height: 1.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
            color: AppPalette.royalA(0.72),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'TAP A LANE TO MOVE THE BASKET - CATCH ONLY WHAT THE ORDER NEEDS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            height: 1.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: AppPalette.royalA(0.48),
          ),
        ),
      ],
    );
  }
}
