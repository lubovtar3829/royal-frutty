import 'dart:async';

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/grain_painter.dart';

/// Branded splash. Deep royal-purple, grain-textured, non-interactive — it must
/// read as a completely different surface from the cream menu.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _intro,
    curve: Curves.easeOutCubic,
  );
  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    _intro.forward();
    // Wall-clock handoff: never tied to an animation completion listener,
    // because the emulator can run with animator scale 0.
    _handoff = Timer(
      const Duration(milliseconds: GameConfig.loaderDurationMs),
      widget.onDone,
    );
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.loaderBottom,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgLoader),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppPalette.loaderTop.withValues(alpha: 0.88),
                AppPalette.loaderBottom.withValues(alpha: 0.96),
              ],
            ),
          ),
          child: CustomPaint(
            painter: const GrainPainter(),
            isComplex: true,
            willChange: false,
            child: SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Spacer(),
                    _medallion(),
                    const SizedBox(height: 28),
                    Text(
                      'ROYAL FRUTTY',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ROYAL FRUITS KITCHEN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.2,
                        color: AppPalette.gold.withValues(alpha: 0.86),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.08, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeInOut,
                          builder: (BuildContext context, double v, Widget? _) {
                            return LinearProgressIndicator(
                              value: v,
                              minHeight: 6,
                              backgroundColor: AppPalette.creamA(0.16),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                AppPalette.gold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'LOADING...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.6,
                        color: AppPalette.creamA(0.70),
                      ),
                    ),
                    const SizedBox(height: 44),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _medallion() {
    return Container(
      width: 168,
      height: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.creamA(0.10),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: AppPalette.gold.withValues(alpha: 0.45), width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.gold.withValues(alpha: 0.26),
            blurRadius: 34,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        // The source PNG is 1024x1024 but the medallion draws it at 144 logical
        // px (~432 physical at 3x). Decoding at full size costs ~4MB of RGBA
        // during cold start — exactly when the capture harness is screenshotting.
        child: Image.asset(
          AppAssets.icon,
          fit: BoxFit.cover,
          cacheWidth: 512,
          cacheHeight: 512,
        ),
      ),
    );
  }
}
