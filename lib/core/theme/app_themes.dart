import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'calc_tokens.dart';

enum AppThemeId {
  classicLight,
  amoledDark,
  neonCyber,
  pastelSoft,
}

class AppThemeSpec {
  final AppThemeId id;
  final String name;
  final ThemeData data;

  const AppThemeSpec({required this.id, required this.name, required this.data});
}

class AppThemes {
  static List<AppThemeSpec> all = [
    AppThemeSpec(
      id: AppThemeId.classicLight,
      name: 'Classic Light',
      data: _classicLight(),
    ),
    AppThemeSpec(
      id: AppThemeId.amoledDark,
      name: 'AMOLED Dark',
      data: _amoledDark(),
    ),
    AppThemeSpec(
      id: AppThemeId.neonCyber,
      name: 'Neon / Cyber',
      data: _neonCyber(),
    ),
    AppThemeSpec(
      id: AppThemeId.pastelSoft,
      name: 'Pastel / Soft',
      data: _pastelSoft(),
    ),
  ];

  static ThemeData byId(AppThemeId id) => all.firstWhere((t) => t.id == id).data;
  static String nameOf(AppThemeId id) => all.firstWhere((t) => t.id == id).name;

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color primary,
    required Color secondary,
    required Color outline,
    required CalcTokens tokens,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      surface: surface,
      outline: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: GoogleFonts.spaceGroteskTextTheme().apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline.withOpacity(0.35)),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline.withOpacity(0.35)),
      extensions: <ThemeExtension<dynamic>>[tokens],
    );
  }

  static ThemeData _classicLight() {
    const scaffold = Color(0xFFF7F4EF); // warm paper
    const surface = Color(0xFFFFFFFF);
    const primary = Color(0xFF2E5AAC); // deep cobalt
    const secondary = Color(0xFF2AAE9D); // teal
    const outline = Color(0xFF24324A);

    const tokens = CalcTokens(
      displayBg: Color(0xFFFFFFFF),
      displayFg: Color(0xFF101521),
      keyBg: Color(0xFFF2F0EA),
      keyFg: Color(0xFF101521),
      keyBorder: Color(0xFF101521),
      keyShadow: Color(0x33000000),
      operatorBg: Color(0xFFE8F2FF),
      operatorFg: Color(0xFF2E5AAC),
      actionBg: Color(0xFFFFEFE7),
      actionFg: Color(0xFFB54B00),
      equalsBg: Color(0xFF2AAE9D),
      equalsFg: Color(0xFFFFFFFF),
      keyRadius: 22,
      keyElevation: 8,
    );

    return _base(
      brightness: Brightness.light,
      scaffold: scaffold,
      surface: surface,
      primary: primary,
      secondary: secondary,
      outline: outline,
      tokens: tokens,
    );
  }

  static ThemeData _amoledDark() {
    const scaffold = Color(0xFF000000);
    const surface = Color(0xFF0B0B0F);
    const primary = Color(0xFF00C2FF); // electric cyan
    const secondary = Color(0xFFB0FF5C); // acid lime
    const outline = Color(0xFF2C2C39);

    const tokens = CalcTokens(
      displayBg: Color(0xFF0B0B0F),
      displayFg: Color(0xFFEDEDF7),
      keyBg: Color(0xFF0F1017),
      keyFg: Color(0xFFEDEDF7),
      keyBorder: Color(0xFF2C2C39),
      keyShadow: Color(0x66000000),
      operatorBg: Color(0xFF071C22),
      operatorFg: Color(0xFF00C2FF),
      actionBg: Color(0xFF1A1410),
      actionFg: Color(0xFFFFB55A),
      equalsBg: Color(0xFF00C2FF),
      equalsFg: Color(0xFF001018),
      keyRadius: 26,
      keyElevation: 10,
    );

    return _base(
      brightness: Brightness.dark,
      scaffold: scaffold,
      surface: surface,
      primary: primary,
      secondary: secondary,
      outline: outline,
      tokens: tokens,
    );
  }

  static ThemeData _neonCyber() {
    const scaffold = Color(0xFF0B0620); // deep violet
    const surface = Color(0xFF120A2E);
    const primary = Color(0xFFFF2FD0); // neon magenta
    const secondary = Color(0xFF5CFFB5); // neon mint
    const outline = Color(0xFF2B1E58);

    const tokens = CalcTokens(
      displayBg: Color(0xFF120A2E),
      displayFg: Color(0xFFF2ECFF),
      keyBg: Color(0xFF17103B),
      keyFg: Color(0xFFF2ECFF),
      keyBorder: Color(0xFF2B1E58),
      keyShadow: Color(0x99000000),
      operatorBg: Color(0xFF1B0A2E),
      operatorFg: Color(0xFFFF2FD0),
      actionBg: Color(0xFF0A1D18),
      actionFg: Color(0xFF5CFFB5),
      equalsBg: Color(0xFFFF2FD0),
      equalsFg: Color(0xFF160018),
      keyRadius: 18,
      keyElevation: 14,
    );

    return _base(
      brightness: Brightness.dark,
      scaffold: scaffold,
      surface: surface,
      primary: primary,
      secondary: secondary,
      outline: outline,
      tokens: tokens,
    );
  }

  static ThemeData _pastelSoft() {
    const scaffold = Color(0xFFF6F3FF); // lavender mist
    const surface = Color(0xFFFFFBFF);
    const primary = Color(0xFF6A5ACD); // slate lavender
    const secondary = Color(0xFF3DB7A0); // soft aqua
    const outline = Color(0xFF3A3A4A);

    const tokens = CalcTokens(
      displayBg: Color(0xFFFFFBFF),
      displayFg: Color(0xFF1C1B1F),
      keyBg: Color(0xFFF0ECFF),
      keyFg: Color(0xFF1C1B1F),
      keyBorder: Color(0xFF6A5ACD),
      keyShadow: Color(0x22000000),
      operatorBg: Color(0xFFE9FFF9),
      operatorFg: Color(0xFF0D6F61),
      actionBg: Color(0xFFFFF0F5),
      actionFg: Color(0xFF8A1B4F),
      equalsBg: Color(0xFF6A5ACD),
      equalsFg: Color(0xFFFFFFFF),
      keyRadius: 30,
      keyElevation: 6,
    );

    return _base(
      brightness: Brightness.light,
      scaffold: scaffold,
      surface: surface,
      primary: primary,
      secondary: secondary,
      outline: outline,
      tokens: tokens,
    );
  }
}
