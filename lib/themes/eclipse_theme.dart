import 'package:flutter/material.dart';
import 'package:neostation/themes/corner_radii.dart';
import 'package:neostation/themes/chrome_surface.dart';

// ECLIPSE is an optional signature theme, not a forced app-wide palette.
const Color _primary = Color(0xFF9B7BFF);
const Color _onPrimary = Color(0xFF160D2B);
const Color _surface = Color(0xFF211B32);
const Color _onSurface = Color(0xFFF3EEFF);
const Color _background = Color(0xFF100C19);
const Color _outline = Color(0xFF493B67);
const Color _shadow = Color(0xFF080610);

const Color _batteryFull = Color(0xFF00D390);
const Color _batteryMedium = Color(0xFFFFC247);
const Color _batteryLow = Color(0xFFFF627D);
const Color _batteryPower = Color(0xFF64C7FF);
const Color _error = Color(0xFFFF627D);
const Color _success = Color(0xFF00D390);
const Color _warning = Color(0xFFFFC247);
const Color _info = Color(0xFF64C7FF);

final ThemeData eclipseTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: _primary,
    onPrimary: _onPrimary,
    secondary: Color(0xFFC6B5FF),
    onSecondary: _onPrimary,
    tertiary: Color(0xFF65D9E8),
    surface: _surface,
    onSurface: _onSurface,
    outline: _outline,
    shadow: _shadow,
    error: _error,
  ),
  scaffoldBackgroundColor: _background,
  cardColor: _surface,
  extensions: [CornerRadii.m(), ChromeSurface.standard()],
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: _onSurface,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      color: _onSurface,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: _onSurface,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(color: _onSurface, fontSize: 16),
    bodyMedium: TextStyle(color: _onSurface, fontSize: 14),
    bodySmall: TextStyle(color: _onSurface, fontSize: 12),
    labelLarge: TextStyle(
      color: _onSurface,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
);

class EclipseCustomColors {
  Color get batteryFull => _batteryFull;
  Color get batteryMedium => _batteryMedium;
  Color get batteryLow => _batteryLow;
  Color get batteryPower => _batteryPower;
  Color get errorColor => _error;
  Color get onErrorColor => const Color(0xFF4D0218);
  Color get successColor => _success;
  Color get onSuccessColor => const Color(0xFF004C39);
  Color get infoColor => _info;
  Color get onInfoColor => const Color(0xFF042E49);
  Color get warningColor => _warning;
  Color get onWarningColor => const Color(0xFF793205);
}
