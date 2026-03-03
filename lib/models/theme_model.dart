import 'package:flutter/material.dart';

enum AppTheme {
  royal,      // White cards, clean lines (Findmypast style)
  dark,       // Dark navy with glowing accents
  vintage,    // Sepia/aged parchment look
  forest,     // Deep green nature theme
  rose,       // Soft pink/blush luxury theme
  midnight,   // Deep blue starfield theme
}

enum CardStyle {
  royal,     // White card with circular photo, clean shadow
  compact,   // Dense info card
  portrait,  // Tall card with large avatar
  minimal,   // Just name + badge
}

class FamilyThemeData {
  final AppTheme theme;
  final String name;
  final String emoji;

  // Background
  final Color scaffoldBg;
  final Color canvasBg;
  final bool showGridDots;
  final Color gridColor;

  // Cards
  final Color cardBg;
  final Color cardBorder;
  final Color cardShadow;
  final double cardRadius;
  final Color maleCardBg;
  final Color femaleCardBg;
  final Color maleCardBorder;
  final Color femaleCardBorder;
  final Color selectedCardBg;
  final Color selectedCardBorder;

  // Typography
  final Color namePrimary;
  final Color nameSecondary;
  final Color dateColor;
  final Color badgeColor;
  final Color badgeText;

  // Connectors
  final Color lineColor;
  final Color spouseLineColor;
  final double lineWidth;
  final bool dashedSpouseLine;

  // Sidebar
  final Color sidebarBg;
  final Color sidebarAccent;
  final Color sidebarText;

  // Generation badge
  final Color genBadgeBg;
  final Color genBadgeText;

  // Focus badge
  final Color focusBadgeBg;
  final Color focusBadgeText;

  const FamilyThemeData({
    required this.theme,
    required this.name,
    required this.emoji,
    required this.scaffoldBg,
    required this.canvasBg,
    required this.showGridDots,
    required this.gridColor,
    required this.cardBg,
    required this.cardBorder,
    required this.cardShadow,
    required this.cardRadius,
    required this.maleCardBg,
    required this.femaleCardBg,
    required this.maleCardBorder,
    required this.femaleCardBorder,
    required this.selectedCardBg,
    required this.selectedCardBorder,
    required this.namePrimary,
    required this.nameSecondary,
    required this.dateColor,
    required this.badgeColor,
    required this.badgeText,
    required this.lineColor,
    required this.spouseLineColor,
    required this.lineWidth,
    required this.dashedSpouseLine,
    required this.sidebarBg,
    required this.sidebarAccent,
    required this.sidebarText,
    required this.genBadgeBg,
    required this.genBadgeText,
    required this.focusBadgeBg,
    required this.focusBadgeText,
  });
}

class FamilyThemes {
  static const Map<AppTheme, FamilyThemeData> themes = {
    AppTheme.royal: FamilyThemeData(
      theme: AppTheme.royal,
      name: 'Royal',
      emoji: '👑',
      scaffoldBg: Color(0xFFF4F4F4),
      canvasBg: Color(0xFFFFFFFF),
      showGridDots: true,
      gridColor: Color(0xFFE8E8E8),
      cardBg: Color(0xFFFFFFFF),
      cardBorder: Color(0xFFE0E0E0),
      cardShadow: Color(0x1A000000),
      cardRadius: 10,
      maleCardBg: Color(0xFFFFFFFF),
      femaleCardBg: Color(0xFFFFFFFF),
      maleCardBorder: Color(0xFFBBDEFB),
      femaleCardBorder: Color(0xFFF8BBD9),
      selectedCardBg: Color(0xFFFFF8E1),
      selectedCardBorder: Color(0xFFF9A825),
      namePrimary: Color(0xFF1A1A2E),
      nameSecondary: Color(0xFF555555),
      dateColor: Color(0xFF888888),
      badgeColor: Color(0xFFE8C97F),
      badgeText: Color(0xFF5D4037),
      lineColor: Color(0xFFBBBBBB),
      spouseLineColor: Color(0xFFBBBBBB),
      lineWidth: 1.5,
      dashedSpouseLine: true,
      sidebarBg: Color(0xFF1A1A2E),
      sidebarAccent: Color(0xFFE8C97F),
      sidebarText: Color(0xFFFFFFFF),
      genBadgeBg: Color(0xFFE8C97F),
      genBadgeText: Color(0xFF5D4037),
      focusBadgeBg: Color(0xFF1A73E8),
      focusBadgeText: Color(0xFFFFFFFF),
    ),

    AppTheme.dark: FamilyThemeData(
      theme: AppTheme.dark,
      name: 'Dark',
      emoji: '🌙',
      scaffoldBg: Color(0xFF0D1117),
      canvasBg: Color(0xFF0D1117),
      showGridDots: true,
      gridColor: Color(0x12FFFFFF),
      cardBg: Color(0xFF161B22),
      cardBorder: Color(0xFF30363D),
      cardShadow: Color(0x40000000),
      cardRadius: 12,
      maleCardBg: Color(0xFF1A2332),
      femaleCardBg: Color(0xFF231A2E),
      maleCardBorder: Color(0xFF4A90D9),
      femaleCardBorder: Color(0xFFD94A90),
      selectedCardBg: Color(0xFF1F3A1F),
      selectedCardBorder: Color(0xFF52B788),
      namePrimary: Color(0xFFE6EDF3),
      nameSecondary: Color(0xFF8B949E),
      dateColor: Color(0xFF6E7681),
      badgeColor: Color(0xFF238636),
      badgeText: Color(0xFFFFFFFF),
      lineColor: Color(0xFF30363D),
      spouseLineColor: Color(0xFFD94A90),
      lineWidth: 2.0,
      dashedSpouseLine: true,
      sidebarBg: Color(0xFF010409),
      sidebarAccent: Color(0xFF52B788),
      sidebarText: Color(0xFFE6EDF3),
      genBadgeBg: Color(0xFF1F6FEB),
      genBadgeText: Color(0xFFFFFFFF),
      focusBadgeBg: Color(0xFF238636),
      focusBadgeText: Color(0xFFFFFFFF),
    ),

    AppTheme.vintage: FamilyThemeData(
      theme: AppTheme.vintage,
      name: 'Vintage',
      emoji: '📜',
      scaffoldBg: Color(0xFFF5EFE0),
      canvasBg: Color(0xFFFDF6E3),
      showGridDots: false,
      gridColor: Color(0xFFD4C5A0),
      cardBg: Color(0xFFFAF0DC),
      cardBorder: Color(0xFFB8966E),
      cardShadow: Color(0x30B8966E),
      cardRadius: 6,
      maleCardBg: Color(0xFFF5EFE0),
      femaleCardBg: Color(0xFFFFF0E8),
      maleCardBorder: Color(0xFF8B6914),
      femaleCardBorder: Color(0xFFB8606A),
      selectedCardBg: Color(0xFFF5DEB3),
      selectedCardBorder: Color(0xFF8B4513),
      namePrimary: Color(0xFF3B2614),
      nameSecondary: Color(0xFF6B4C2A),
      dateColor: Color(0xFF8B7355),
      badgeColor: Color(0xFF8B4513),
      badgeText: Color(0xFFFFF8E7),
      lineColor: Color(0xFFB8966E),
      spouseLineColor: Color(0xFFB8606A),
      lineWidth: 1.5,
      dashedSpouseLine: true,
      sidebarBg: Color(0xFF3B2614),
      sidebarAccent: Color(0xFFD4A853),
      sidebarText: Color(0xFFFDF6E3),
      genBadgeBg: Color(0xFFD4A853),
      genBadgeText: Color(0xFF3B2614),
      focusBadgeBg: Color(0xFF8B4513),
      focusBadgeText: Color(0xFFFFF8E7),
    ),

    AppTheme.forest: FamilyThemeData(
      theme: AppTheme.forest,
      name: 'Forest',
      emoji: '🌿',
      scaffoldBg: Color(0xFF0F1F15),
      canvasBg: Color(0xFF0F1F15),
      showGridDots: true,
      gridColor: Color(0x12FFFFFF),
      cardBg: Color(0xFF162B1E),
      cardBorder: Color(0xFF2D5A3D),
      cardShadow: Color(0x40000000),
      cardRadius: 14,
      maleCardBg: Color(0xFF1A3327),
      femaleCardBg: Color(0xFF2A1F30),
      maleCardBorder: Color(0xFF4CAF82),
      femaleCardBorder: Color(0xFFA78BCA),
      selectedCardBg: Color(0xFF1F4A2F),
      selectedCardBorder: Color(0xFF76C442),
      namePrimary: Color(0xFFD4EDDA),
      nameSecondary: Color(0xFF9CC9A8),
      dateColor: Color(0xFF6B9E78),
      badgeColor: Color(0xFF2E7D32),
      badgeText: Color(0xFFFFFFFF),
      lineColor: Color(0xFF2D5A3D),
      spouseLineColor: Color(0xFF9C6FAD),
      lineWidth: 2.0,
      dashedSpouseLine: true,
      sidebarBg: Color(0xFF0A1410),
      sidebarAccent: Color(0xFF76C442),
      sidebarText: Color(0xFFD4EDDA),
      genBadgeBg: Color(0xFF2E7D32),
      genBadgeText: Color(0xFFFFFFFF),
      focusBadgeBg: Color(0xFF76C442),
      focusBadgeText: Color(0xFF0A1410),
    ),

    AppTheme.rose: FamilyThemeData(
      theme: AppTheme.rose,
      name: 'Rose',
      emoji: '🌹',
      scaffoldBg: Color(0xFFFFF0F3),
      canvasBg: Color(0xFFFFF5F7),
      showGridDots: true,
      gridColor: Color(0xFFFFCDD5),
      cardBg: Color(0xFFFFFFFF),
      cardBorder: Color(0xFFFFB3C1),
      cardShadow: Color(0x20E91E63),
      cardRadius: 16,
      maleCardBg: Color(0xFFF0F4FF),
      femaleCardBg: Color(0xFFFFF0F5),
      maleCardBorder: Color(0xFF90CAF9),
      femaleCardBorder: Color(0xFFF48FB1),
      selectedCardBg: Color(0xFFFFF3E0),
      selectedCardBorder: Color(0xFFFF8A65),
      namePrimary: Color(0xFF4A0E2E),
      nameSecondary: Color(0xFF9C4060),
      dateColor: Color(0xFFBA6880),
      badgeColor: Color(0xFFE91E63),
      badgeText: Color(0xFFFFFFFF),
      lineColor: Color(0xFFFFAEC0),
      spouseLineColor: Color(0xFFE91E63),
      lineWidth: 1.5,
      dashedSpouseLine: true,
      sidebarBg: Color(0xFF4A0E2E),
      sidebarAccent: Color(0xFFFF80AB),
      sidebarText: Color(0xFFFFFFFF),
      genBadgeBg: Color(0xFFE91E63),
      genBadgeText: Color(0xFFFFFFFF),
      focusBadgeBg: Color(0xFFFF6090),
      focusBadgeText: Color(0xFFFFFFFF),
    ),

    AppTheme.midnight: FamilyThemeData(
      theme: AppTheme.midnight,
      name: 'Midnight',
      emoji: '✨',
      scaffoldBg: Color(0xFF080820),
      canvasBg: Color(0xFF080820),
      showGridDots: true,
      gridColor: Color(0x0FFFFFFF),
      cardBg: Color(0xFF10103A),
      cardBorder: Color(0xFF2E2E6E),
      cardShadow: Color(0x407B68EE),
      cardRadius: 12,
      maleCardBg: Color(0xFF0D1B4A),
      femaleCardBg: Color(0xFF2D0D3A),
      maleCardBorder: Color(0xFF6B9FFF),
      femaleCardBorder: Color(0xFFBB6BFF),
      selectedCardBg: Color(0xFF1A1A5A),
      selectedCardBorder: Color(0xFF00E5FF),
      namePrimary: Color(0xFFE8EAFF),
      nameSecondary: Color(0xFF9999CC),
      dateColor: Color(0xFF6666AA),
      badgeColor: Color(0xFF3F3FA0),
      badgeText: Color(0xFFCCCCFF),
      lineColor: Color(0xFF2E2E6E),
      spouseLineColor: Color(0xFFBB6BFF),
      lineWidth: 2.0,
      dashedSpouseLine: true,
      sidebarBg: Color(0xFF050515),
      sidebarAccent: Color(0xFF00E5FF),
      sidebarText: Color(0xFFE8EAFF),
      genBadgeBg: Color(0xFF3F3FA0),
      genBadgeText: Color(0xFFCCCCFF),
      focusBadgeBg: Color(0xFF00E5FF),
      focusBadgeText: Color(0xFF080820),
    ),
  };

  static FamilyThemeData get(AppTheme theme) => themes[theme]!;
}
