import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandTheme extends Equatable {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color text;
  final Color background;

  const BrandTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.background,
  });

  /// App default palette, used until a company brand is loaded.
  static const BrandTheme fallback = BrandTheme(
    primary: Color(0xFF0F4C81),
    secondary: Color(0xFF2C3E50),
    accent: Color(0xFF00A8CC),
    text: Color(0xFF1C2833),
    background: Color(0xFFFAFAFA),
  );

  ThemeData toThemeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final base = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );

    final scheme = isDark
        ? base.copyWith(
            primary: secondary,
            onPrimary: background,
            secondary: accent,
            onSecondary: primary,
            tertiary: accent,
            onTertiary: primary,
            surface: text,
            onSurface: background,
            surfaceContainerLow: primary,
            surfaceContainer: primary,
            outlineVariant: accent,
          )
        : base.copyWith(
            primary: primary,
            onPrimary: background,
            secondary: secondary,
            onSecondary: background,
            tertiary: accent,
            onTertiary: primary,
            surface: background,
            onSurface: text,
            outlineVariant: secondary,
          );

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: color),
    );

    final textTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryColor: scheme.primary,
      scaffoldBackgroundColor: scheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        border: border(scheme.outlineVariant),
        enabledBorder: border(scheme.outlineVariant),
        focusedBorder: border(scheme.primary),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error),
        disabledBorder: border(scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      iconTheme: IconThemeData(color: scheme.secondary),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: scheme.onPrimary),
      ),
    );
  }

  @override
  List<Object?> get props => [primary, secondary, accent, text, background];
}
