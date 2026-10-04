import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:royal_frutty/game/game_config.dart';
import 'package:royal_frutty/game/game_engine.dart';
import 'package:royal_frutty/game/recipes.dart';
import 'package:royal_frutty/theme.dart';
import 'package:royal_frutty/widgets/clay_card.dart';

void main() {
  group('GameEngine', () {
    test('a fully passive shift always reaches a result', () {
      final GameEngine engine = GameEngine(seed: 7);
      for (int ms = 0; ms <= GameConfig.roundDurationMs; ms += 16) {
        engine.tick(ms);
        if (engine.isOver) break;
      }
      expect(engine.isOver, isTrue);
      expect(engine.result, isNotNull);
    });

    test('assist window costs no hearts and makes progress', () {
      final GameEngine engine = GameEngine(seed: 11);
      for (int ms = 0; ms < GameConfig.assistWindowMs; ms += 16) {
        engine.tick(ms);
      }
      expect(engine.mistakes, 0);
      expect(engine.caught, greaterThan(0));
      expect(engine.isOver, isFalse);
    });

    test('a passive shift still resolves shortly after the assist window', () {
      final GameEngine engine = GameEngine(seed: 5);
      for (int ms = 0; ms <= GameConfig.passiveBackstopMs; ms += 16) {
        engine.tick(ms);
        if (engine.isOver) break;
      }
      expect(engine.isOver, isTrue);
      expect(engine.result, ResultReason.mistakes);
    });

    test('moving the basket registers player input', () {
      final GameEngine engine = GameEngine(seed: 3);
      expect(engine.playerInputCount, 0);
      engine.nudgeBasket(1);
      expect(engine.playerInputCount, 1);
      expect(engine.basketLane, 2);
      engine.nudgeBasket(1);
      expect(engine.basketLane, 2);
    });

    test('every recipe needs exactly two fruit types', () {
      expect(kRecipes.length, 4);
      for (final Recipe recipe in kRecipes) {
        expect(recipe.needs.length, 2);
        expect(recipe.total, greaterThan(0));
      }
    });
  });

  testWidgets('StatCard renders its value and label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: const Scaffold(
          body: StatCard(
            value: '3/4',
            label: 'dishes',
            valueColor: AppPalette.leaf,
          ),
        ),
      ),
    );

    expect(find.text('3/4'), findsOneWidget);
    expect(find.text('DISHES'), findsOneWidget);
  });
}
