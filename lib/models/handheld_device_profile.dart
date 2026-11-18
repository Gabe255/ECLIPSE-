import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Validated recommendation data for a known handheld device.
///
/// Profiles are advisory only: they never claim an emulator is installed and
/// never hide a system that the user has explicitly chosen to keep visible.
class HandheldDeviceProfile {
  const HandheldDeviceProfile({
    required this.id,
    required this.displayName,
    required this.displayMode,
    required this.recommendedSystems,
    required this.advancedSystems,
    required this.allowUserOverride,
  });

  final String id;
  final String displayName;
  final String displayMode;
  final List<String> recommendedSystems;
  final List<String> advancedSystems;
  final bool allowUserOverride;

  static const fallback = HandheldDeviceProfile(
    id: 'generic-android',
    displayName: 'Android handheld',
    displayMode: 'auto',
    recommendedSystems: <String>[],
    advancedSystems: <String>[],
    allowUserOverride: true,
  );

  factory HandheldDeviceProfile.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schema_version'];
    if (schemaVersion != 1) {
      throw const FormatException('Unsupported device profile schema');
    }

    final id = json['id'];
    final displayName = json['display_name'];
    final display = json['display'];
    final systems = json['systems'];
    if (id is! String ||
        id.trim().isEmpty ||
        displayName is! String ||
        displayName.trim().isEmpty ||
        display is! Map ||
        systems is! Map) {
      throw const FormatException('Invalid device profile structure');
    }

    final displayMode = display['mode'];
    if (displayMode is! String ||
        !const {'auto', 'single', 'dual'}.contains(displayMode)) {
      throw const FormatException('Invalid device display mode');
    }

    List<String> readSystemList(Object? value) {
      if (value is! List || value.any((entry) => entry is! String)) {
        throw const FormatException('Invalid system recommendation list');
      }
      return List<String>.unmodifiable(
        value
            .map((entry) => (entry as String).trim().toLowerCase())
            .where((entry) => entry.isNotEmpty),
      );
    }

    final allowOverride = systems['allow_user_override'];
    if (allowOverride is! bool) {
      throw const FormatException('Missing user override policy');
    }

    return HandheldDeviceProfile(
      id: id.trim(),
      displayName: displayName.trim(),
      displayMode: displayMode,
      recommendedSystems: readSystemList(systems['recommended']),
      advancedSystems: readSystemList(systems['advanced']),
      allowUserOverride: allowOverride,
    );
  }

  /// Selects a bundled profile from Android's manufacturer/model identifiers.
  /// Unknown hardware deliberately receives the generic fallback.
  static String? assetPathForDevice(String manufacturer, String model) {
    final maker = manufacturer.trim().toLowerCase();
    final deviceModel = model.trim().toLowerCase();
    if (maker != 'ayn') return null;
    if (deviceModel.contains('thor')) {
      return 'assets/device_profiles/ayn-thor.json';
    }
    if (deviceModel.contains('odin 3') || deviceModel.contains('odin3')) {
      return 'assets/device_profiles/odin3.json';
    }
    return null;
  }

  /// Detects supported AYN devices at runtime. On other platforms/devices,
  /// returns the generic profile without failing app startup.
  static Future<HandheldDeviceProfile> detectCurrentDevice({
    AssetBundle? bundle,
    String? manufacturer,
    String? model,
  }) async {
    try {
      String maker = manufacturer ?? '';
      String deviceModel = model ?? '';
      if (maker.isEmpty || deviceModel.isEmpty) {
        if (!Platform.isAndroid) return fallback;
        final info = await DeviceInfoPlugin().androidInfo;
        maker = info.manufacturer;
        deviceModel = info.model;
      }
      final path = assetPathForDevice(maker, deviceModel);
      if (path == null) return fallback;
      return await loadAsset(path, bundle: bundle);
    } catch (_) {
      return fallback;
    }
  }

  /// Loads a bundled profile, falling back safely when it is missing or invalid.
  static Future<HandheldDeviceProfile> loadAsset(
    String assetPath, {
    AssetBundle? bundle,
  }) async {
    try {
      final source = await (bundle ?? rootBundle).loadString(assetPath);
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) return fallback;
      return HandheldDeviceProfile.fromJson(decoded);
    } on FormatException {
      return fallback;
    } on FlutterError {
      return fallback;
    }
  }
}
