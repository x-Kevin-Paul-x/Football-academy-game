import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SaveSlotInfo {
  final int slotIndex;
  final String academyName;
  final String saveDate;
  final int year;
  final double balance;

  SaveSlotInfo({
    required this.slotIndex,
    required this.academyName,
    required this.saveDate,
    required this.year,
    required this.balance,
  });

  Map<String, dynamic> toJson() => {
    'slotIndex': slotIndex,
    'academyName': academyName,
    'saveDate': saveDate,
    'year': year,
    'balance': balance,
  };

  factory SaveSlotInfo.fromJson(Map<String, dynamic> json) => SaveSlotInfo(
    slotIndex: json['slotIndex'] ?? 0,
    academyName: json['academyName'] ?? 'Academy',
    saveDate: json['saveDate'] ?? '',
    year: json['year'] ?? 2025,
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
  );
}

class SaveManager {
  static const int maxSlots = 5;
  static const String _slotPrefix = 'academy_save_slot_';
  static const String _metaPrefix = 'academy_save_meta_';

  Future<List<SaveSlotInfo?>> getAllSlotInfo() async {
    final prefs = await SharedPreferences.getInstance();
    List<SaveSlotInfo?> slots = [];

    for (int i = 0; i < maxSlots; i++) {
      final metaStr = prefs.getString('$_metaPrefix$i');
      if (metaStr != null && metaStr.isNotEmpty) {
        try {
          final map = jsonDecode(metaStr);
          slots.add(SaveSlotInfo.fromJson(map));
        } catch (_) {
          slots.add(null);
        }
      } else {
        slots.add(null);
      }
    }
    return slots;
  }

  Future<bool> saveToSlot(int slotIndex, String gameStateJson, SaveSlotInfo info) async {
    if (slotIndex < 0 || slotIndex >= maxSlots) return false;
    final prefs = await SharedPreferences.getInstance();
    final metaJson = jsonEncode(info.toJson());

    await prefs.setString('$_slotPrefix$slotIndex', gameStateJson);
    await prefs.setString('$_metaPrefix$slotIndex', metaJson);
    return true;
  }

  Future<String?> loadFromSlot(int slotIndex) async {
    if (slotIndex < 0 || slotIndex >= maxSlots) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_slotPrefix$slotIndex');
  }

  Future<bool> deleteSlot(int slotIndex) async {
    if (slotIndex < 0 || slotIndex >= maxSlots) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_slotPrefix$slotIndex');
    await prefs.remove('$_metaPrefix$slotIndex');
    return true;
  }
}
