import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandPalette extends Equatable {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color text;
  final Color background;
  final Color surface;

  const BrandPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.background,
    required this.surface,
  });

  @override
  List<Object?> get props => [
    primary,
    secondary,
    accent,
    text,
    background,
    surface,
  ];
}

class BrandTheme extends Equatable {
  final BrandPalette light;
  final BrandPalette dark;

  const BrandTheme({required this.light, required this.dark});

  /// Monochrome black & white palette: pure neutrals in both modes (dark is
  /// the mirror of light). Only `error` keeps a hue, for error semantics.
  static const BrandTheme fallback = BrandTheme(
    light: BrandPalette(
      primary: Color(0xFF0C2340),
      secondary: Color(0xFF1E3A5F),
      accent: Color(0xFFF7B61B),
      text: Color(0xFF0F172A),
      background: Color(0xFFF4F6F8),
      surface: Color(0xFFFFFFFF),
    ),
    dark: BrandPalette(
      primary: Color(0xFF1E3A5F),
      secondary: Color(0xFF0C2340),
      accent: Color(0xFFF7B61B),
      text: Color(0xFFF8FAFC),
      background: Color(0xFF071220),
      surface: Color(0xFF0C2340),
    ),
  );

  OutlineInputBorder _buildBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.0),
    borderSide: BorderSide(color: color),
  );

  static const Color _darkInk = Color(0xFF161C23);

  static Color _onColorFor(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : _darkInk;

  ThemeData _buildTheme(BrandPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: brightness,
        ).copyWith(
          primary: palette.primary,
          onPrimary: _onColorFor(palette.primary),
          secondary: palette.secondary,
          onSecondary: _onColorFor(palette.secondary),
          tertiary: palette.accent,
          onError: isDark ? _darkInk : Colors.white,
          surface: palette.surface,
          onSurface: palette.text,
          outlineVariant: palette.text.withValues(alpha: 0.2),
        );

    final textTheme = GoogleFonts.poppinsTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final appBarForeground = isDark ? palette.text : scheme.onPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: palette.background,
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: _buildBorder(scheme.outlineVariant),
        enabledBorder: _buildBorder(scheme.outlineVariant),
        focusedBorder: _buildBorder(scheme.primary),
        errorBorder: _buildBorder(scheme.error),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? palette.surface : palette.primary,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: appBarForeground,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: appBarForeground),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.tertiary.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: scheme.onSurface),
        iconTheme: IconThemeData(color: scheme.surface),
        deleteIconColor: scheme.surface,
      ),
    );
  }

  ThemeData toLightTheme() => _buildTheme(light, Brightness.light);
  ThemeData toDarkTheme() => _buildTheme(dark, Brightness.dark);

  @override
  List<Object?> get props => [light, dark];
}
