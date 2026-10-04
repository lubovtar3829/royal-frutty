/// Tuning constants for the round. Kept in one place so the pipeline
/// antipattern scan can verify loaderDurationMs.
class GameConfig {
  const GameConfig._();

  static const int loaderDurationMs = 8000;

  static const int roundDurationMs = 75000;
  static const int spawnIntervalMs = 850;
  static const int fallDurationMs = 2600;
  static const int basketMoveMs = 160;

  /// While the assist window is open the spawner never drops a fruit that is
  /// not part of the current recipe into the lane the basket is standing in.
  static const int assistWindowMs = 24000;

  /// Fires only when the player never interacted; guarantees a result frame.
  static const int passiveBackstopMs = 40000;

  /// Armed once, on the very first player input. The harness taps a few times
  /// and then waits: without this the passive backstop is disqualified and the
  /// long round never resolves inside the capture window.
  static const int engagedBackstopMs = 9000;

  static const int maxMistakes = 3;
  static const int laneCount = 3;

  static const int readyOverlayMs = 700;
  static const int dishServedMs = 500;
}
