import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color card;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  final Color parkingFree;
  final Color parkingOccupied;
  final Color parkingReserved;
  final Color parkingDisabled;
  final Color parkingElectric;

  final Color sensorOnline;
  final Color sensorOffline;
  final Color sensorError;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.parkingFree,
    required this.parkingOccupied,
    required this.parkingReserved,
    required this.parkingDisabled,
    required this.parkingElectric,
    required this.sensorOnline,
    required this.sensorOffline,
    required this.sensorError,
  });

  const AppThemeColors.dark()
      : background = AppColors.background,
        surface = AppColors.surface,
        surfaceLight = AppColors.surfaceLight,
        card = AppColors.card,
        border = AppColors.border,
        textPrimary = AppColors.textPrimary,
        textSecondary = AppColors.textSecondary,
        textMuted = AppColors.textMuted,
        success = AppColors.success,
        warning = AppColors.warning,
        danger = AppColors.danger,
        info = AppColors.info,
        parkingFree = AppColors.parkingFree,
        parkingOccupied = AppColors.parkingOccupied,
        parkingReserved = AppColors.parkingReserved,
        parkingDisabled = AppColors.parkingDisabled,
        parkingElectric = AppColors.parkingElectric,
        sensorOnline = AppColors.sensorOnline,
        sensorOffline = AppColors.sensorOffline,
        sensorError = AppColors.sensorError;

  const AppThemeColors.light()
      : background = const Color(0xFFF6F8FC),
        surface = Colors.white,
        surfaceLight = const Color(0xFFF3F6FB),
        card = Colors.white,
        border = const Color(0xFFE5E7EB),
        textPrimary = const Color(0xFF111827),
        textSecondary = const Color(0xFF4B5563),
        textMuted = const Color(0xFF6B7280),
        success = const Color(0xFF16A34A),
        warning = const Color(0xFFF59E0B),
        danger = const Color(0xFFEF4444),
        info = const Color(0xFF0EA5E9),
        parkingFree = const Color(0xFF22C55E),
        parkingOccupied = const Color(0xFFEF4444),
        parkingReserved = const Color(0xFFF59E0B),
        parkingDisabled = const Color(0xFF6B7280),
        parkingElectric = const Color(0xFF06B6D4),
        sensorOnline = const Color(0xFF22C55E),
        sensorOffline = const Color(0xFFF59E0B),
        sensorError = const Color(0xFFEF4444);

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? parkingFree,
    Color? parkingOccupied,
    Color? parkingReserved,
    Color? parkingDisabled,
    Color? parkingElectric,
    Color? sensorOnline,
    Color? sensorOffline,
    Color? sensorError,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      card: card ?? this.card,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      parkingFree: parkingFree ?? this.parkingFree,
      parkingOccupied: parkingOccupied ?? this.parkingOccupied,
      parkingReserved: parkingReserved ?? this.parkingReserved,
      parkingDisabled: parkingDisabled ?? this.parkingDisabled,
      parkingElectric: parkingElectric ?? this.parkingElectric,
      sensorOnline: sensorOnline ?? this.sensorOnline,
      sensorOffline: sensorOffline ?? this.sensorOffline,
      sensorError: sensorError ?? this.sensorError,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;

    return AppThemeColors(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceLight:
          Color.lerp(surfaceLight, other.surfaceLight, t) ?? surfaceLight,
      card: Color.lerp(card, other.card, t) ?? card,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      info: Color.lerp(info, other.info, t) ?? info,
      parkingFree: Color.lerp(parkingFree, other.parkingFree, t) ?? parkingFree,
      parkingOccupied:
          Color.lerp(parkingOccupied, other.parkingOccupied, t) ??
              parkingOccupied,
      parkingReserved:
          Color.lerp(parkingReserved, other.parkingReserved, t) ??
              parkingReserved,
      parkingDisabled:
          Color.lerp(parkingDisabled, other.parkingDisabled, t) ??
              parkingDisabled,
      parkingElectric:
          Color.lerp(parkingElectric, other.parkingElectric, t) ??
              parkingElectric,
      sensorOnline:
          Color.lerp(sensorOnline, other.sensorOnline, t) ?? sensorOnline,
      sensorOffline:
          Color.lerp(sensorOffline, other.sensorOffline, t) ?? sensorOffline,
      sensorError:
          Color.lerp(sensorError, other.sensorError, t) ?? sensorError,
    );
  }
}

extension ThemeDataX on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ??
      const AppThemeColors.dark();
}
