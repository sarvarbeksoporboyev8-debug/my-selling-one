import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Utility for playing audio feedback sounds.
class AudioFeedback {
  AudioFeedback._();

  static final AudioPlayer _player = AudioPlayer();

  /// Play success sound (e.g., order confirmed, scan successful).
  static Future<void> playSuccess() async {
    await HapticFeedback.mediumImpact();
    // In production, load from assets:
    // await _player.play(AssetSource('sounds/success.mp3'));
  }

  /// Play error sound.
  static Future<void> playError() async {
    await HapticFeedback.heavyImpact();
  }

  /// Play notification sound (e.g., new message, order update).
  static Future<void> playNotification() async {
    await HapticFeedback.lightImpact();
    // In production, load from assets:
    // await _player.play(AssetSource('sounds/notification.mp3'));
  }

  /// Play scan beep sound.
  static Future<void> playScanBeep() async {
    await HapticFeedback.selectionClick();
  }

  /// Dispose the audio player when app closes.
  static Future<void> dispose() async {
    await _player.dispose();
  }
}
