import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'game/game_engine.dart';
import 'screens/game_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/result_screen.dart';
import 'theme.dart';

void main() {  WidgetsFlutterBinding.ensureInitialized();
  // Flutter публикует accessibility-дерево только пока за него держится
  // клиент. Без хэндла каждый `uiautomator dump` возвращает пустые узлы и
  // сгорает по таймауту, а UI-обходчик не отличает один экран от другого.
  // Хэндл намеренно не освобождаем: семантика нужна на весь процесс.
  SemanticsBinding.instance.ensureSemantics();
  // Прячем системные панели. Тикающие часы статус-бара меняют пиксели кадра
  // между двумя снимками одного экрана, и тап, не попавший никуда, выглядит
  // успешной навигацией.
  unawaited(
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
  );

  runApp(const RoyalFruttyApp());
}

enum Screen { loader, menu, game, result }

class RoyalFruttyApp extends StatelessWidget {
  const RoyalFruttyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Frutty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const RootView(),
    );
  }
}

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  Screen _screen = Screen.loader;
  RoundSummary _summary = RoundSummary.empty;
  int _bestCaught = 0;
  int _bestDishes = 0;
  int _runId = 0;

  void _go(Screen next) {
    if (!mounted) return;
    setState(() => _screen = next);
  }

  void _startRound() {
    setState(() {
      _runId++;
      _screen = Screen.game;
    });
  }

  void _finishRound(RoundSummary summary) {
    setState(() {
      _summary = summary;
      if (summary.caught > _bestCaught) _bestCaught = summary.caught;
      if (summary.dishes > _bestDishes) _bestDishes = summary.dishes;
      _screen = Screen.result;
    });
  }

  Widget _current() {
    switch (_screen) {
      case Screen.loader:
        return LoaderScreen(
          key: const ValueKey<String>('loader'),
          onDone: () => _go(Screen.menu),
        );
      case Screen.menu:
        return MenuScreen(
          key: const ValueKey<String>('menu'),
          onPlay: _startRound,
          bestCaught: _bestCaught,
          bestDishes: _bestDishes,
        );
      case Screen.game:
        return GameScreen(
          key: ValueKey<String>('game-$_runId'),
          onQuit: () => _go(Screen.menu),
          onFinish: _finishRound,
        );
      case Screen.result:
        return ResultScreen(
          key: const ValueKey<String>('result'),
          summary: _summary,
          onPlayAgain: _startRound,
          onMenu: () => _go(Screen.menu),
        );
    }
  }

  /// A back press must never pop the single route: that drops the process to
  /// the Android launcher, and the capture harness files the launcher frame as
  /// a screen of this app. Back is routed inward instead — secondary screens
  /// fall back to the menu, the menu and the loader absorb it.
  void _onBack() {
    switch (_screen) {
      case Screen.loader:
      case Screen.menu:
        break;
      case Screen.game:
      case Screen.result:
        _go(Screen.menu);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _onBack();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: _current(),
      ),
    );
  }
}
