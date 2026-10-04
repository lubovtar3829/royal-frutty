import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Static full-canvas grain for the loader. Painted once (shouldRepaint is
/// false) so it costs nothing per frame, while giving the loader frame enough
/// visual density to stay clearly distinct from the cream menu.
class GrainPainter extends CustomPainter {
  const GrainPainter({this.points = 130000, this.seed = 0x5B3D83});

  final int points;
  final int seed;

  static const List<Color> _tints = <Color>[
    Color(0x26FFF2DB),
    Color(0x1FF8C845),
    Color(0x1CEF5965),
    Color(0x1C58AEE0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    int state = seed == 0 ? 1 : seed;
    int next() {
      state ^= (state << 13) & 0x7FFFFFFF;
      state ^= state >> 17;
      state ^= (state << 5) & 0x7FFFFFFF;
      return state & 0x7FFFFFFF;
    }

    final int perPass = math.max(1, points ~/ _tints.length);
    for (int pass = 0; pass < _tints.length; pass++) {
      final Float32List buffer = Float32List(perPass * 2);
      for (int i = 0; i < perPass; i++) {
        buffer[i * 2] = (next() % 100000) / 100000.0 * size.width;
        buffer[i * 2 + 1] = (next() % 100000) / 100000.0 * size.height;
      }
      final Paint paint = Paint()
        ..color = _tints[pass]
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.square;
      canvas.drawRawPoints(ui.PointMode.points, buffer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GrainPainter oldDelegate) => false;
}
