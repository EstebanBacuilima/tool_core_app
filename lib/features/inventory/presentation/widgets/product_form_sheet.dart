import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_input.dart';
import '../../domain/entities/product_unit.dart';
import '../cubit/product_form_cubit.dart';
import '../cubit/product_form_state.dart';
import 'product_unit_labels.dart';

/// Opens the create/edit product sheet. Returns true when saved.
Future<bool?> showProductFormSheet(
  BuildContext context, {
  required List<ProductCategory> categories,
  Product? product,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => getIt<ProductFormCubit>(),
      child: _ProductFormSheet(categories: categories, product: product),
    ),
  );
}

/// Category tree flattened for the dropdown, indenting children.
class _CategoryOption {
  final String code;
  final String label;

  const _CategoryOption(this.code, this.label);
}

List<_CategoryOption> _flatten(List<ProductCategory> categories,
    [int depth = 0]) {
  return [
    for (final category in categories) ...[
      _CategoryOption(category.code, '${'    ' * depth}${category.name}'),
      ..._flatten(category.children, depth + 1),
    ],
  ];
}

class _ProductFormSheet extends StatefulWidget {
  final List<ProductCategory> categories;
  final Product? product;

  const _ProductFormSheet({required this.categories, this.product});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _brandController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _descriptionController;
  String? _categoryCode;
  ProductUnit? _unit;
  late bool _isTaxable;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _salePriceController =
        TextEditingController(text: p?.salePriceWithTax.toStringAsFixed(2));
    _costPriceController =
        TextEditingController(text: p?.costPrice.toStringAsFixed(2));
    _brandController = TextEditingController(text: p?.brand);
    _unit = ProductUnit.fromValue(p?.unit);
    _barcodeController = TextEditingController(text: p?.barcode);
    _descriptionController = TextEditingController(text: p?.description);
    _categoryCode = p?.categoryCode;
    _isTaxable = p?.isTaxable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  double? _parsePrice(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  String? _nullable(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProductFormCubit>().submit(
          code: widget.product?.code,
          input: ProductInput(
            name: _nameController.text.trim(),
            categoryCode: _categoryCode!,
            description: _nullable(_descriptionController),
            brand: _nullable(_brandController),
            barcode: _nullable(_barcodeController),
            unit: _unit?.value,
            costPrice: _parsePrice(_costPriceController.text)!,
            salePrice: _parsePrice(_salePriceController.text)!,
            isTaxable: _isTaxable,
          ),
        );
  }

  String? _priceValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.requiredField;
    final price = _parsePrice(value);
    if (price == null || price < 0) return l10n.invalidPrice;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final options = _flatten(widget.categories);

    return BlocConsumer<ProductFormCubit, ProductFormState>(
      listener: (context, state) {
        if (state is ProductFormSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is ProductFormFailure) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(localizeErrorCode(l10n, state.code)),
              ),
            );
        }
      },
      builder: (context, state) {
        final isSaving = state is ProductFormSaving;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isEdit ? l10n.productEdit : l10n.productNew,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    enabled: !isSaving,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.productName,
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? l10n.requiredField
                            : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _categoryCode,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.productCategory,
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: [
                      for (final option in options)
                        DropdownMenuItem(
                          value: option.code,
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: isSaving
                        ? null
                        : (value) => setState(() => _categoryCode = value),
                    validator: (value) =>
                        value == null ? l10n.requiredField : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _salePriceController,
                          enabled: !isSaving,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.salePrice,
                            helperText: _isTaxable
                                ? l10n.priceWithTaxHelper
                                : l10n.priceZeroRatedHelper,
                            helperMaxLines: 2,
                            prefixIcon: const Icon(Icons.attach_money_outlined),
                          ),
                          validator: (v) => _priceValidator(v, l10n),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _costPriceController,
                          enabled: !isSaving,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.costPrice,
                            helperText: l10n.costPriceHelper,
                            helperMaxLines: 2,
                            prefixIcon:
                                const Icon(Icons.shopping_cart_outlined),
                          ),
                          validator: (v) => _priceValidator(v, l10n),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _brandController,
                          enabled: !isSaving,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.productBrand,
                            prefixIcon: const Icon(Icons.sell_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        // Units are backend-validated constants: dropdown,
                        // never free text.
                        child: DropdownButtonFormField<ProductUnit?>(
                          initialValue: _unit,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.productUnit,
                            prefixIcon: const Icon(Icons.straighten_outlined),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(l10n.unitNone),
                            ),
                            for (final unit in ProductUnit.values)
                              DropdownMenuItem(
                                value: unit,
                                child: Text(
                                  localizeProductUnit(l10n, unit),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: isSaving
                              ? null
                              : (value) => setState(() => _unit = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _barcodeController,
                    enabled: !isSaving,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.productBarcode,
                      prefixIcon: const Icon(Icons.qr_code_2_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !isSaving,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.serviceDescription,
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _isTaxable,
                    onChanged: isSaving
                        ? null
                        : (value) => setState(() => _isTaxable = value),
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.taxable, style: textTheme.bodyLarge),
                    subtitle: Text(
                      _isTaxable
                          ? l10n.taxableSubtitle
                          : l10n.zeroRatedSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isSaving ? null : _onSubmit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(l10n.save),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
