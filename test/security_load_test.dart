import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:football_academy_game/game_state_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameStateManager Security Tests', () {
    late Directory tempDir;
    late GameStateManager gameStateManager;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync();

      // Mock path_provider using MethodChannel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return tempDir.path;
          }
          return null;
        },
      );

      gameStateManager = GameStateManager();
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
       // Remove mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
    });

    test('loadGame should reject save file with invalid academy name (XSS risk)', () async {
      final saveFile = File('${tempDir.path}/academy_save.json');

      // Create valid JSON structure but with malicious name
      final maliciousJson = {
        "currentDate": "2025-01-01T00:00:00.000",
        "academyName": "<script>alert(1)</script>", // Malicious name
        "academyPlayers": [],
        "hiredStaff": [],
        "balance": 50000.0,
        "weeklyIncome": 1000,
        "totalWeeklyWages": 0,
        "activeTournaments": [],
        "completedTournaments": [],
        "trainingFacilityLevel": 1,
        "scoutingFacilityLevel": 1,
        "medicalBayLevel": 1,
        "academyReputation": 100,
        "newsItems": [],
        "difficulty": "Normal",
        "themeMode": "system",
        "rivalAcademies": [],
        "aiClubs": [],
        "playerAcademyTier": 0,
        "fans": 100,
        "merchandiseStoreLevel": 0
      };

      await saveFile.writeAsString(jsonEncode(maliciousJson));

      final result = await gameStateManager.loadGame();

      // Expect failure (false) because validation should reject it
      expect(result, isFalse, reason: "Should reject save with invalid academy name");
    });

     test('loadGame should reject save file with huge player list (DoS risk)', () async {
      final saveFile = File('${tempDir.path}/academy_save.json');

      // Create a list of 300 dummy players
      final List<Map<String, dynamic>> hugePlayerList = List.generate(300, (index) => {
        "id": "player_$index",
        "name": "Player $index",
        "age": 18,
        "naturalPosition": "Forward",
        "assignedPosition": "Forward",
        "potentialSkill": 80,
        "weeklyWage": 100,
        "reputation": 10,
        "matchesPlayed": 0,
        "goalsScored": 0,
        "assists": 0,
        "fatigue": 0.0,
        "stamina": 100,
        "isScouted": false,
        "preferredPositions": ["Forward"],
        "positionalAffinity": {"Forward": 50},
        "aggression": 10,
        "composure": 10,
        "concentration": 10,
        "decision": 10,
        "determination": 10,
        "flair": 10,
        "leadership": 10,
        "teamwork": 10,
        "vision": 10,
        "workRate": 10,
        "acceleration": 10,
        "agility": 10,
        "balance": 10,
        "jumpingReach": 10,
        "naturalFitness": 10,
        "pace": 10,
        "strength": 10,
        "crossing": 10,
        "dribbling": 10,
        "finishing": 10,
        "firstTouch": 10,
        "heading": 10,
        "longShots": 10,
        "passing": 10,
        "penaltyTaking": 10,
        "technique": 10,
        "marking": 10,
        "tackling": 10,
        "defensivePositioning": 10,
        "aerialReach": 10,
        "commandOfArea": 10,
        "communicationGK": 10,
        "eccentricity": 10,
        "handling": 10,
        "kicking": 10,
        "oneOnOnes": 10,
        "reflexes": 10,
        "rushingOut": 10,
        "throwing": 10
      });

      final maliciousJson = {
        "currentDate": "2025-01-01T00:00:00.000",
        "academyName": "My Academy",
        "academyPlayers": hugePlayerList, // Too many players
        "hiredStaff": [],
        "balance": 50000.0,
        "weeklyIncome": 1000,
        "totalWeeklyWages": 0,
        "activeTournaments": [],
        "completedTournaments": [],
        "trainingFacilityLevel": 1,
        "scoutingFacilityLevel": 1,
        "medicalBayLevel": 1,
        "academyReputation": 100,
        "newsItems": [],
        "difficulty": "Normal",
        "themeMode": "system",
        "rivalAcademies": [],
         "aiClubs": [],
        "playerAcademyTier": 0,
        "fans": 100,
        "merchandiseStoreLevel": 0
      };

      await saveFile.writeAsString(jsonEncode(maliciousJson));

      final result = await gameStateManager.loadGame();

      expect(result, isFalse, reason: "Should reject save with too many players");
    });
  });
}
