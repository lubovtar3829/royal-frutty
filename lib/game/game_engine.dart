import 'dart:math';

import 'package:flutter/foundation.dart';

import 'game_config.dart';
import 'recipes.dart';

enum ResultReason { allRecipes, mistakes, timeUp }

/// Outcome of a fruit reaching the catch line.
enum CatchOutcome { none, scored, mistake }

class FallingFruit {
  FallingFruit({
    required this.id,
    required this.lane,
    required this.type,
    required this.spawnedAtMs,
  });

  final int id;
  final int lane;
  final FruitType type;
  final int spawnedAtMs;
  bool resolved = false;

  /// 0.0 at spawn, 1.0 at the catch line.
  double progress(int nowMs) {
    final double t =
        (nowMs - spawnedAtMs) / GameConfig.fallDurationMs.toDouble();
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    return t;
  }
}

class ScorePopup {
  ScorePopup({required this.id, required this.lane, required this.bornMs});

  final int id;
  final int lane;
  final int bornMs;
}

/// Pure-ish round state. The screen only feeds it elapsed milliseconds and
/// lane taps; every transition (win / mistakes / timeout) ends in a result.
class GameEngine {
  GameEngine({int? seed}) : _rng = Random(seed);

  final Random _rng;

  int elapsedMs = 0;
  int basketLane = 1;
  int recipeIndex = 0;
  int mistakes = 0;
  int caught = 0;
  int playerInputCount = 0;

  final Map<FruitType, int> progress = <FruitType, int>{};
  final List<FallingFruit> fruits = <FallingFruit>[];
  final List<ScorePopup> popups = <ScorePopup>[];

  ResultReason? result;
  int mistakeFlashUntilMs = -1;
  int dishServedUntilMs = -1;
  int basketPopAtMs = -1;

  int _nextId = 1;
  int _spawnCount = 0;
  int _lastSpawnMs = -GameConfig.spawnIntervalMs;

  Recipe get recipe => kRecipes[recipeIndex.clamp(0, kRecipes.length - 1)];

  bool get isOver => result != null;

  int get dishesServed => recipeIndex.clamp(0, kRecipes.length);

  int get secondsLeft {
    final int left = GameConfig.roundDurationMs - elapsedMs;
    if (left <= 0) return 0;
    return (left / 1000).ceil();
  }

  int get accuracyPercent {
    final int total = caught + mistakes;
    if (total == 0) return 0;
    return ((caught / total) * 100).round();
  }

  bool get dishOverlayVisible => elapsedMs < dishServedUntilMs;

  bool get readyOverlayVisible => elapsedMs < GameConfig.readyOverlayMs;

  int need(FruitType type) => recipe.needs[type] ?? 0;

  int have(FruitType type) => progress[type] ?? 0;

  bool _hasRoom(FruitType type) => have(type) < need(type);

  void moveBasket(int lane) {
    if (isOver) return;
    final int clamped = lane.clamp(0, GameConfig.laneCount - 1);
    playerInputCount++;
    if (clamped == basketLane) return;
    basketLane = clamped;
  }

  void nudgeBasket(int delta) => moveBasket(basketLane + delta);

  /// Advances the round. [nowMs] is monotonic elapsed time since round start.
  void tick(int nowMs) {
    if (isOver) return;
    elapsedMs = nowMs;

    if (nowMs >= GameConfig.roundDurationMs) {
      _finish(ResultReason.timeUp);
      return;
    }

    if (nowMs >= GameConfig.readyOverlayMs &&
        nowMs - _lastSpawnMs >= GameConfig.spawnIntervalMs) {
      _lastSpawnMs = nowMs;
      _spawn(nowMs);
    }

    for (final FallingFruit fruit in fruits) {
      if (fruit.resolved) continue;
      if (fruit.progress(nowMs) < 1) continue;
      fruit.resolved = true;
      _resolve(fruit, nowMs);
      if (isOver) return;
    }

    fruits.removeWhere((FallingFruit f) => f.resolved);
    popups.removeWhere((ScorePopup p) => nowMs - p.bornMs > 420);
  }

  void _resolve(FallingFruit fruit, int nowMs) {
    if (fruit.lane != basketLane) return;

    final bool wanted = recipe.needs.containsKey(fruit.type);
    if (wanted && _hasRoom(fruit.type)) {
      progress[fruit.type] = have(fruit.type) + 1;
      caught++;
      basketPopAtMs = nowMs;
      popups.add(
        ScorePopup(id: _nextId++, lane: fruit.lane, bornMs: nowMs),
      );
      _checkRecipeDone(nowMs);
      return;
    }

    if (wanted) {
      // Already stocked up on this fruit — the cook simply sets it aside.
      return;
    }

    if (nowMs < GameConfig.assistWindowMs) {
      // Grace period: an item that turned useless because the order changed
      // mid-flight must not cost a heart.
      return;
    }

    mistakes++;
    mistakeFlashUntilMs = nowMs + 260;
    if (mistakes >= GameConfig.maxMistakes) {
      _finish(ResultReason.mistakes);
    }
  }

  void _checkRecipeDone(int nowMs) {
    for (final MapEntry<FruitType, int> entry in recipe.needs.entries) {
      if (have(entry.key) < entry.value) return;
    }
    progress.clear();
    recipeIndex++;
    if (recipeIndex >= kRecipes.length) {
      recipeIndex = kRecipes.length;
      _finish(ResultReason.allRecipes);
      return;
    }
    dishServedUntilMs = nowMs + GameConfig.dishServedMs;
  }

  void _finish(ResultReason reason) {
    result = reason;
    fruits.clear();
    popups.clear();
  }

  void _spawn(int nowMs) {
    final bool assisting = nowMs < GameConfig.assistWindowMs;
    final int slot = _spawnCount++;

    int lane;
    FruitType type;

    if (assisting && slot.isEven) {
      // Helpful drop straight into the basket lane so a passive run makes
      // visible progress before the capture agent arrives.
      type = _neededType() ?? _randomType();
      lane = basketLane;
    } else if (!assisting && slot.isOdd) {
      // Pressure phase: the kitchen throws junk at the basket lane.
      type = _wrongType();
      lane = basketLane;
    } else {
      type = _randomType();
      lane = _rng.nextInt(GameConfig.laneCount);
      final bool wanted =
          recipe.needs.containsKey(type) && _hasRoom(type);
      if (assisting && !wanted && lane == basketLane) {
        lane = (basketLane + 1) % GameConfig.laneCount;
      }
    }

    fruits.add(
      FallingFruit(
        id: _nextId++,
        lane: lane,
        type: type,
        spawnedAtMs: nowMs,
      ),
    );
  }

  FruitType? _neededType() {
    final List<FruitType> open = recipe.types
        .where(_hasRoom)
        .toList(growable: false);
    if (open.isEmpty) return null;
    return open[_rng.nextInt(open.length)];
  }

  FruitType _randomType() =>
      FruitType.values[_rng.nextInt(FruitType.values.length)];

  FruitType _wrongType() {
    final List<FruitType> junk = FruitType.values
        .where((FruitType t) => !recipe.needs.containsKey(t))
        .toList(growable: false);
    if (junk.isEmpty) return _randomType();
    return junk[_rng.nextInt(junk.length)];
  }
}

/// Immutable snapshot handed to the result screen.
@immutable
class RoundSummary {
  const RoundSummary({
    required this.reason,
    required this.dishes,
    required this.caught,
    required this.mistakes,
    required this.accuracy,
  });

  final ResultReason reason;
  final int dishes;
  final int caught;
  final int mistakes;
  final int accuracy;

  bool get isWin => reason == ResultReason.allRecipes;

  static const RoundSummary empty = RoundSummary(
    reason: ResultReason.timeUp,
    dishes: 0,
    caught: 0,
    mistakes: 0,
    accuracy: 0,
  );
}
