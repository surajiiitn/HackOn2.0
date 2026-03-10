import 'package:flutter/material.dart';

/// Suraksha AI color system.
/// Electric Blue for digital/OSINT, Crimson for SOS/danger, Emerald for safety.
class AppColors {
  AppColors._();

  // Core backgrounds
  static const Color backgroundDark = Color(0xFF0A1122);
  static const Color surfaceDark = Color(0xFF161F33);
  static const Color surfaceVariant = Color(0xFF1E2A45);
  static const Color borderDark = Color(0xFF2A3A5A);

  // Primary — Electric Blue (OSINT / digital features)
  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color electricBlueLight = Color(0xFF60A5FA);
  static const Color electricBlueDim = Color(0x1A3B82F6);

  // Danger — Crimson Red (SOS / emergency)
  static const Color crimson = Color(0xFFDC2626);
  static const Color crimsonLight = Color(0xFFEF4444);
  static const Color crimsonDim = Color(0x33DC2626);

  // Safety — Emerald Green (safe routes / active status)
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDim = Color(0x1A10B981);

  // Warning — Amber
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDim = Color(0x1AF59E0B);

  // Accent — Orange (notifications / warnings)
  static const Color accentOrange = Color(0xFFEC5B13);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Slate tones for surfaces
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
}
