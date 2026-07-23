import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../domain/entities/product_unit.dart';

/// Localized label for a unit. The wire value never reaches the UI.
String localizeProductUnit(AppLocalizations l10n, ProductUnit unit) {
  return switch (unit) {
    ProductUnit.unidad => l10n.unitUnidad,
    ProductUnit.par => l10n.unitPar,
    ProductUnit.juego => l10n.unitJuego,
    ProductUnit.kit => l10n.unitKit,
    ProductUnit.caja => l10n.unitCaja,
    ProductUnit.litro => l10n.unitLitro,
    ProductUnit.galon => l10n.unitGalon,
    ProductUnit.kilogramo => l10n.unitKilogramo,
    ProductUnit.metro => l10n.unitMetro,
  };
}

/// Label for a raw unit value coming from the API; falls back to the raw
/// string for values the app does not know yet.
String? localizeProductUnitValue(AppLocalizations l10n, String? value) {
  if (value == null || value.isEmpty) return null;
  final unit = ProductUnit.fromValue(value);
  return unit == null ? value : localizeProductUnit(l10n, unit);
}
