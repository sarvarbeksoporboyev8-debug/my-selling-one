import 'package:wakelock_plus/wakelock_plus.dart';

/// Utility for managing screen wakelock.
/// Keeps screen on during important operations like scanning or transactions.
class WakelockUtils {
  WakelockUtils._();

  /// Enable wakelock to keep screen on.
  static Future<void> enable() async {
    await WakelockPlus.enable();
  }

  /// Disable wakelock to allow screen to turn off.
  static Future<void> disable() async {
    await WakelockPlus.disable();
  }

  /// Check if wakelock is currently enabled.
  static Future<bool> get isEnabled => WakelockPlus.enabled;

  /// Toggle wakelock state.
  static Future<void> toggle() async {
    final enabled = await isEnabled;
    if (enabled) {
      await disable();
    } else {
      await enable();
    }
  }
}
