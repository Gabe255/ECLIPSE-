import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores a user-selected image for the app-wide library background.
class WallpaperProvider extends ChangeNotifier {
  static const _preferenceKey = 'eclipse.wallpaper.path';

  String? _wallpaperPath;
  bool _isLoading = true;

  String? get wallpaperPath => _wallpaperPath;
  bool get isLoading => _isLoading;
  bool get hasWallpaper =>
      _wallpaperPath != null && File(_wallpaperPath!).existsSync();

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedPath = preferences.getString(_preferenceKey);
      if (savedPath != null && await File(savedPath).exists()) {
        _wallpaperPath = savedPath;
      } else if (savedPath != null) {
        await preferences.remove(_preferenceKey);
      }
    } catch (_) {
      _wallpaperPath = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> chooseWallpaper() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return false;

      final picked = result.files.single;
      final bytes = picked.bytes ??
          (picked.path != null ? await File(picked.path!).readAsBytes() : null);
      if (bytes == null || bytes.isEmpty) return false;

      final supportDirectory = await getApplicationSupportDirectory();
      final wallpaperDirectory = Directory(
        path.join(supportDirectory.path, 'wallpaper'),
      );
      await wallpaperDirectory.create(recursive: true);

      final extension = path.extension(picked.name).toLowerCase();
      final safeExtension = RegExp(r'^\\.(png|jpe?g|webp|bmp|gif)$')
              .hasMatch(extension)
          ? extension
          : '.jpg';
      final destination = File(
        path.join(wallpaperDirectory.path, 'library_wallpaper$safeExtension'),
      );
      await destination.writeAsBytes(bytes, flush: true);

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_preferenceKey, destination.path);
      _wallpaperPath = destination.path;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearWallpaper() async {
    final oldPath = _wallpaperPath;
    _wallpaperPath = null;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_preferenceKey);
    if (oldPath != null) {
      try {
        final file = File(oldPath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}
