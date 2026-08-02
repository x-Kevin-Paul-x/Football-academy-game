import 'package:flutter/foundation.dart';

enum SoundEffect {
  whistle,
  goalCheer,
  menuClick,
  weekTick,
  cardDraw,
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isMuted = false;
  double _volume = 0.8;

  bool get isMuted => _isMuted;
  double get volume => _volume;

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void setVolume(double val) {
    _volume = val.clamp(0.0, 1.0);
  }

  void playSfx(SoundEffect effect) {
    if (_isMuted) return;
    if (kDebugMode) {
      debugPrint('[AudioService] Playing SFX: ${effect.name} at volume $_volume');
    }
  }
}
