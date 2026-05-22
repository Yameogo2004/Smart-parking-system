import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand - V2 bleu ciel
  static const Color primary = Color(0xFF38BDF8);
  static const Color primaryDark = Color(0xFF0EA5E9);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color accent = Color(0xFF7DD3FC);

  // Backgrounds
  static const Color background = Color(0xFF070B14);
  static const Color surface = Color(0xFF0D1320);
  static const Color surfaceLight = Color(0xFF131C2B);
  static const Color card = Color(0xFF121A28);
  static const Color cardSoft = Color(0xFF182233);
  static const Color border = Color(0xFF233047);

  // Text
  static const Color textPrimary = Color(0xFFF4F7FB);
  static const Color textSecondary = Color(0xFFB6C2D2);
  static const Color textMuted = Color(0xFF7B8A9D);
  static const Color textOnPrimary = Color(0xFF06111D);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // Parking-specific
  static const Color parkingFree = Color(0xFF22C55E);
  static const Color parkingOccupied = Color(0xFFEF4444);
  static const Color parkingReserved = Color(0xFF38BDF8);
  static const Color parkingDisabled = Color(0xFF6B7280);
  static const Color parkingElectric = Color(0xFF14B8A6);

  // Alert levels
  static const Color alertInfo = Color(0xFF38BDF8);
  static const Color alertWarning = Color(0xFFF59E0B);
  static const Color alertCritical = Color(0xFFDC2626);

  // Sensor states
  static const Color sensorOnline = Color(0xFF22C55E);
  static const Color sensorOffline = Color(0xFF9CA3AF);
  static const Color sensorError = Color(0xFFEF4444);

  // Overlays
  static const Color overlayDark = Color(0x99000000);
  static const Color divider = Color(0xFF233047);

  // Sidebar / shell
  static const Color sidebarBackground = Color(0xFF050912);
  static const Color sidebarActive = Color(0xFF0F1C2E);
  static const Color topBarBackground = Color(0xCC070B14);

  // Neutral greys
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
