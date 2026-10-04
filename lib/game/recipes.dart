import 'package:flutter/material.dart';

import '../theme.dart';

enum FruitType { strawberry, lemon, apple, blueberry, plum }

extension FruitTypeLabel on FruitType {
  String get label {
    switch (this) {
      case FruitType.strawberry:
        return 'STRAWBERRY';
      case FruitType.lemon:
        return 'LEMON';
      case FruitType.apple:
        return 'APPLE';
      case FruitType.blueberry:
        return 'BLUEBERRY';
      case FruitType.plum:
        return 'PLUM';
    }
  }

  Color get tint {
    switch (this) {
      case FruitType.strawberry:
        return AppPalette.berry;
      case FruitType.lemon:
        return AppPalette.gold;
      case FruitType.apple:
        return AppPalette.leaf;
      case FruitType.blueberry:
        return AppPalette.sky;
      case FruitType.plum:
        return AppPalette.royal;
    }
  }
}

@immutable
class Recipe {
  const Recipe({
    required this.dish,
    required this.accent,
    required this.needs,
  });

  final String dish;
  final Color accent;
  final Map<FruitType, int> needs;

  int get total => needs.values.fold(0, (int a, int b) => a + b);

  List<FruitType> get types => needs.keys.toList(growable: false);
}

const List<Recipe> kRecipes = <Recipe>[
  Recipe(
    dish: 'BERRY TART',
    accent: AppPalette.berry,
    needs: <FruitType, int>{FruitType.strawberry: 3, FruitType.lemon: 3},
  ),
  Recipe(
    dish: 'SUNNY PIE',
    accent: AppPalette.gold,
    needs: <FruitType, int>{FruitType.lemon: 4, FruitType.apple: 3},
  ),
  Recipe(
    dish: 'GARDEN BOWL',
    accent: AppPalette.leaf,
    needs: <FruitType, int>{FruitType.apple: 4, FruitType.blueberry: 3},
  ),
  Recipe(
    dish: 'ROYAL PLATTER',
    accent: AppPalette.sky,
    needs: <FruitType, int>{FruitType.blueberry: 4, FruitType.plum: 4},
  ),
];
