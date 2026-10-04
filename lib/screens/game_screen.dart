import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/game_engine.dart';
import '../theme.dart';
import '../widgets/clay_button.dart';
import '../widgets/game_hud.dart';
import '../widgets/lane_board.dart';

/// G2 floating-controls gameplay: three lanes fill the board, the control bar
/// hovers above the catch line without covering it.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.onQuit,
    required this.onFinish,
  });

  final VoidCallback onQuit;
  final void Function(RoundSummary summary) onFinish;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final GameEngine _engine = GameEngine();
  late final Ticker _ticker;
  Timer? _backstop;
  Timer? _engagedBackstop;
  bool _handedOff = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    // Armed exactly once. Only a completely passive session can trigger it,
    // which guarantees a result frame even with zero interaction.
    _backstop = Timer(
      const Duration(milliseconds: GameConfig.passiveBackstopMs),
      () {
        if (!mounted || _handedOff) return;
        if (_engine.playerInputCount > 0) return;
        _finish(
          RoundSummary(
            reason: ResultReason.timeUp,
            dishes: _engine.dishesServed,
            caught: _engine.caught,
            mistakes: _engine.mistakes,
            accuracy: _engine.accuracyPercent,
          ),
        );
      },
    );
  }

  /// Armed exactly once, on the first input. Never re-armed on later taps:
  /// re-arming would push the resolve past the capture window.
  void _armEngagedBackstop() {
    if (_engagedBackstop != null) return;
    _engagedBackstop = Timer(
      const Duration(milliseconds: GameConfig.engagedBackstopMs),
      () {
        if (!mounted || _handedOff) return;
        _finish(
          RoundSummary(
            reason: ResultReason.timeUp,
            dishes: _engine.dishesServed,
            caught: _engine.caught,
            mistakes: _engine.mistakes,
            accuracy: _engine.accuracyPercent,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _backstop?.cancel();
    _engagedBackstop?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_handedOff) return;
    _engine.tick(elapsed.inMilliseconds);
    if (_engine.isOver) {
      _finish(
        RoundSummary(
          reason: _engine.result ?? ResultReason.timeUp,
          dishes: _engine.dishesServed,
          caught: _engine.caught,
          mistakes: _engine.mistakes,
          accuracy: _engine.accuracyPercent,
        ),
      );
      return;
    }
    setState(() {});
  }

  void _finish(RoundSummary summary) {
    if (_handedOff) return;
    _handedOff = true;
    _ticker.stop();
    _backstop?.cancel();
    _engagedBackstop?.cancel();
    widget.onFinish(summary);
  }

  void _tapLane(int lane) {
    if (_handedOff) return;
    _engine.moveBasket(lane);
    _armEngagedBackstop();
    setState(() {});
  }

  void _nudge(int delta) {
    if (_handedOff) return;
    _engine.nudgeBasket(delta);
    _armEngagedBackstop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgGame),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppPalette.creamA(0.55),
                AppPalette.creamA(0.86),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                _header(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: RecipeStrip(
                    recipe: _engine.recipe,
                    progress: _engine.progress,
                    index: _engine.recipeIndex,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: LaneBoard(engine: _engine, onLaneTap: _tapLane),
                      ),
                      if (_engine.readyOverlayVisible)
                        Positioned.fill(child: _banner('GET READY')),
                      if (_engine.dishOverlayVisible)
                        Positioned.fill(child: _banner('DISH SERVED!')),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 24,
                        child: _controls(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 96,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ClayIconButton(
                  icon: Icons.close,
                  onTap: widget.onQuit,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: TimerPill(secondsLeft: _engine.secondsLeft),
              ),
            ),
            SizedBox(
              width: 96,
              child: Align(
                alignment: Alignment.centerRight,
                child: HeartsRow(mistakes: _engine.mistakes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banner(String text) {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: AppPalette.royal,
            borderRadius: BorderRadius.circular(26),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppPalette.royalA(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: AppPalette.cream,
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls() {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.creamA(0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppPalette.royalA(0.18), width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.royalA(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _goButton('< GO', () => _nudge(-1)),
          Text(
            'TAP A LANE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: AppPalette.royalA(0.55),
            ),
          ),
          _goButton('GO >', () => _nudge(1)),
        ],
      ),
    );
  }

  Widget _goButton(String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 110,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppPalette.royalA(0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppPalette.royalA(0.30), width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            height: 24 / 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: AppPalette.royal,
          ),
        ),
      ),
    );
  }
}
