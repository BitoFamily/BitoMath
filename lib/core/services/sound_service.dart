import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Fire-and-forget sound effects. Silently no-ops on web or if files missing.
/// Place MP3 files in assets/audio/:
///   correct.mp3  — short positive chime
///   wrong.mp3    — short buzz/thud
///   streak.mp3   — brief fanfare for every 5-in-a-row
///   complete.mp3 — longer fanfare for results screen
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool enabled = true;

  void _play(String filename) {
    if (!enabled || kIsWeb) return;
    try {
      final player = AudioPlayer();
      unawaited(player.play(AssetSource('audio/$filename')));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (_) {}
  }

  void correct() => _play('correct.mp3');
  void wrong() => _play('wrong.mp3');
  void streak() => _play('streak.mp3');
  void complete() => _play('complete.mp3');
}
