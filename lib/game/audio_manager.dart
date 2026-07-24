import 'package:audioplayers/audioplayers.dart';

/// Plays the synthesized 8-bit sounds.
///
/// * Sound effects: on by default, toggleable.
/// * Music ("Akh, Samara-gorodok", chiptune arrangement of the folk tune):
///   OFF by default, toggleable. Same theme throughout, but each level
///   gets its own arrangement — level 1's original chiptune, a jazz take
///   for level 2, an upbeat icy version for level 3, hellish heavy rock
///   for level 4, and a relaxed blues for level 5.
class AudioManager {
  bool sfxOn = true;
  bool musicOn = false;

  final AudioPlayer _music = AudioPlayer();
  // Small pool so overlapping effects don't cut each other off.
  final List<AudioPlayer> _pool = List.generate(4, (_) => AudioPlayer());
  int _next = 0;

  int _level = 1;

  AudioManager() {
    // Ignore failures (e.g. platforms/tests without an audio backend).
    _music.setReleaseMode(ReleaseMode.loop).catchError((_) {});
    _music.setVolume(0.45).catchError((_) {});
    for (final p in _pool) {
      p.setReleaseMode(ReleaseMode.stop).catchError((_) {});
    }
  }

  String _trackFor(int level) =>
      level == 1 ? 'audio/music.wav' : 'audio/music_level$level.wav';

  void playSfx(String name) {
    if (!sfxOn) return;
    final p = _pool[_next];
    _next = (_next + 1) % _pool.length;
    // Fire and forget; audio failures should never break the game.
    p.stop().then((_) => p.play(AssetSource('audio/$name.wav'), volume: 0.8))
        .catchError((_) {});
  }

  void toggleSfx() => sfxOn = !sfxOn;

  Future<void> toggleMusic() async {
    musicOn = !musicOn;
    try {
      if (musicOn) {
        await _music.play(AssetSource(_trackFor(_level)));
      } else {
        await _music.pause();
      }
    } catch (_) {
      // e.g. autoplay restrictions — ignore.
    }
  }

  /// Called whenever the current game level changes. Swaps to that
  /// level's arrangement, picking up right away if music is playing.
  Future<void> setLevel(int level) async {
    if (level == _level) return;
    _level = level;
    if (!musicOn) return;
    try {
      await _music.stop();
      await _music.play(AssetSource(_trackFor(_level)));
    } catch (_) {
      // e.g. autoplay restrictions — ignore.
    }
  }

  void dispose() {
    _music.dispose();
    for (final p in _pool) {
      p.dispose();
    }
  }
}
