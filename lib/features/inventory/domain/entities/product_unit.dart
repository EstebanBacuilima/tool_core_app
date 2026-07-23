/// Allowed values for Product.unit (backend `ProductUnits`). Optional:
/// a product may have no unit. The wire value is the Spanish constant;
/// the UI label is localized in presentation.
enum ProductUnit {
  unidad('unidad'),
  par('par'),
  juego('juego'),
  kit('kit'),
  caja('caja'),
  litro('litro'),
  galon('galon'),
  kilogramo('kilogramo'),
  metro('metro');

  final String value;

  const ProductUnit(this.value);

  static ProductUnit? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final unit in values) {
      if (unit.value == value) return unit;
    }
    return null;
  }
}
