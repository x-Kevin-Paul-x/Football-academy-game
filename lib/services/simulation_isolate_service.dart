import 'dart:isolate';
import 'dart:typed_data';
import 'fast_math_engine.dart';

class MatchSimulationInput {
  final String matchId;
  final double homeSkill;
  final double awaySkill;

  MatchSimulationInput({
    required this.matchId,
    required this.homeSkill,
    required this.awaySkill,
  });
}

class MatchSimulationOutput {
  final String matchId;
  final int homeScore;
  final int awayScore;

  MatchSimulationOutput({
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
  });
}

class SimulationIsolateService {
  /// Offloads batch match simulations to a background Isolate thread using Isolate.run.
  /// Guarantees zero UI thread frame drops during heavy simulation batches.
  static Future<List<MatchSimulationOutput>> simulateBatchInIsolate(
    List<MatchSimulationInput> inputs,
  ) async {
    return Isolate.run(() {
      final List<MatchSimulationOutput> outputs = [];
      for (final input in inputs) {
        final score = FastMathEngine.simulateMatchScoreFast(
          homeAttackRating: input.homeSkill,
          awayAttackRating: input.awaySkill,
          homeDefRating: input.awaySkill * 0.9,
          awayDefRating: input.homeSkill * 0.9,
        );
        outputs.add(
          MatchSimulationOutput(
            matchId: input.matchId,
            homeScore: score[0],
            awayScore: score[1],
          ),
        );
      }
      return outputs;
    });
  }
}
