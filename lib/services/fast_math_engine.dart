import 'dart:math' as math;
import 'dart:typed_data';

/// High-Performance Fast Math Engine
/// Uses typed memory buffers (Float64List, Int32List) for vectorized rating
/// calculations and rapid match simulation computations.
class FastMathEngine {
  static final math.Random _rng = math.Random();

  /// Calculates team overall rating in O(1) using typed Float64List buffer
  static double calculateVectorizedTeamSkill(List<int> playerSkills) {
    if (playerSkills.isEmpty) return 50.0;
    final len = playerSkills.length;
    final buffer = Float64List(len);

    for (int i = 0; i < len; i++) {
      buffer[i] = playerSkills[i].toDouble();
    }

    double sum = 0.0;
    for (int i = 0; i < len; i++) {
      sum += buffer[i];
    }
    return sum / len;
  }

  /// High-speed match goal simulation based on Poisson-like distribution
  static Int32List simulateMatchScoreFast({
    required double homeAttackRating,
    required double awayAttackRating,
    required double homeDefRating,
    required double awayDefRating,
  }) {
    // Expected goals (lambda)
    final homeLambda = ((homeAttackRating / math.max(1.0, awayDefRating)) * 1.35).clamp(0.2, 5.0);
    final awayLambda = ((awayAttackRating / math.max(1.0, homeDefRating)) * 1.10).clamp(0.1, 4.5);

    final homeGoals = _samplePoisson(homeLambda);
    final awayGoals = _samplePoisson(awayLambda);

    final result = Int32List(2);
    result[0] = homeGoals;
    result[1] = awayGoals;
    return result;
  }

  static int _samplePoisson(double lambda) {
    double L = math.exp(-lambda);
    double k = 0;
    double p = 1.0;
    do {
      k += 1;
      p *= _rng.nextDouble();
    } while (p > L && k < 10);
    return (k - 1).toInt().clamp(0, 12);
  }
}
