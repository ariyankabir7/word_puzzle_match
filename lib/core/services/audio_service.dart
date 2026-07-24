import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  void updateSettings({required bool sound, required bool music}) {
    _soundEnabled = sound;
    _musicEnabled = music;
    if (!music) stopMusic();
  }

  // ── Background Music ─────────────────────────────────────────────────────

  Future<void> playMusic(String assetPath) async {
    if (!_musicEnabled) return;
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource(assetPath));
      await _bgPlayer.setVolume(0.4);
    } catch (_) {
      // Audio files not bundled yet; silently ignore
    }
  }

  Future<void> stopMusic() async {
    await _bgPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _bgPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (!_musicEnabled) return;
    await _bgPlayer.resume();
  }

  // ── Sound Effects ─────────────────────────────────────────────────────────

  Future<void> playSfx(String assetPath) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (_) {
      // Audio files not bundled yet; silently ignore
    }
  }

  // Convenience SFX methods
  Future<void> playWordFound() => playSfx('audio/word_found.mp3');
  Future<void> playWrongSwipe() => playSfx('audio/wrong_swipe.mp3');
  Future<void> playLevelComplete() => playSfx('audio/level_complete.mp3');
  Future<void> playButtonTap() => playSfx('audio/button_tap.mp3');
  Future<void> playStarEarned() => playSfx('audio/star_earned.mp3');

  Future<void> dispose() async {
    await _bgPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
