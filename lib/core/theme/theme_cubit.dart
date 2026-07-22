import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/session_storage.dart';
import 'brand_theme.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SessionStorage _storage;

  ThemeCubit(this._storage) : super(const ThemeState.initial());

  /// Restores the saved mode at startup (defaults to system).
  Future<void> loadSavedMode() async {
    final saved = await _storage.readThemeMode();
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    if (mode != state.mode) emit(state.copyWith(mode: mode));
  }

  /// Sets and persists the light/dark preference.
  Future<void> setMode(ThemeMode mode) async {
    await _storage.writeThemeMode(mode.name);
    emit(state.copyWith(mode: mode));
  }

  /// Applies a company brand (future: fetched from the backend after login).
  void applyBrand(BrandTheme brand) => emit(state.copyWith(brand: brand));

  /// Default theme
  void resetBrand() => emit(state.copyWith(brand: BrandTheme.fallback));
}
