import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'brand_theme.dart';

/// Active branding + light/dark preference.
class ThemeState extends Equatable {
  final BrandTheme brand;

  /// system (default) follows the device; light/dark force a mode.
  final ThemeMode mode;

  const ThemeState({required this.brand, required this.mode});

  const ThemeState.initial()
    : this(brand: BrandTheme.fallback, mode: ThemeMode.system);

  ThemeState copyWith({BrandTheme? brand, ThemeMode? mode}) =>
      ThemeState(brand: brand ?? this.brand, mode: mode ?? this.mode);

  @override
  List<Object?> get props => [brand, mode];
}
