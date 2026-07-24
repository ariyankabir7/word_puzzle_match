import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress.dart';

class StorageService {
  static const String _progressKey = 'player_progress';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Player Progress ─────────────────────────────────────────────────────────

  PlayerProgress loadProgress() {
    final jsonStr = _prefs.getString(_progressKey);
    if (jsonStr == null) return PlayerProgress();
    try {
      return PlayerProgress.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );
    } catch (_) {
      return PlayerProgress();
    }
  }

  Future<void> saveProgress(PlayerProgress progress) async {
    await _prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<void> clearProgress() async {
    await _prefs.remove(_progressKey);
  }

  // ── Settings ────────────────────────────────────────────────────────────────

  bool getSoundEnabled() => _prefs.getBool('sound_enabled') ?? true;
  bool getMusicEnabled() => _prefs.getBool('music_enabled') ?? true;
  bool getHapticEnabled() => _prefs.getBool('haptic_enabled') ?? true;

  Future<void> setSoundEnabled(bool value) =>
      _prefs.setBool('sound_enabled', value);
  Future<void> setMusicEnabled(bool value) =>
      _prefs.setBool('music_enabled', value);
  Future<void> setHapticEnabled(bool value) =>
      _prefs.setBool('haptic_enabled', value);
}
