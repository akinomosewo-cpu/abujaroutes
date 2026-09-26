import 'package:hive_flutter/hive_flutter.dart';

/// Lightweight, optional local identity used only to credit a rider's
/// crowdsourced submissions on this device. This is NOT authentication:
/// there is no password, no account and no server-side login, and the
/// app is fully usable without ever setting a display name.
class DisplayNameService {
  DisplayNameService._();
  static const String boxName = 'profile_box';
  static const String _key = 'displayName';

  static Box? _box;

  /// Opens the local box. Safe to call multiple times. Best-effort: if
  /// Hive hasn't been initialized (e.g. in a test harness), this quietly
  /// no-ops so submitting a route never breaks or blocks.
  static Future<void> init() async {
    if (_box != null) return;
    try {
      _box = Hive.isBoxOpen(boxName) ? Hive.box(boxName) : await Hive.openBox(boxName);
    } catch (_) {
      _box = null;
    }
  }

  /// The rider's chosen display name, or null if never set.
  static String? getDisplayName() {
    final box = _box;
    if (box == null) return null;
    final value = box.get(_key) as String?;
    return (value == null || value.trim().isEmpty) ? null : value.trim();
  }

  static bool get hasDisplayName => getDisplayName() != null;

  static Future<void> setDisplayName(String name) async {
    await init();
    final box = _box;
    if (box == null) return;
    await box.put(_key, name.trim());
  }
}
