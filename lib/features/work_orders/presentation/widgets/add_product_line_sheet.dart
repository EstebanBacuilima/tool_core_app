import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../inventory/domain/entities/product.dart';
import '../cubit/order_detail_cubit.dart';
import '../cubit/order_detail_state.dart';
import 'sheet_widgets.dart';

Future<bool?> showAddProductLineSheet(
  BuildContext context,
  OrderDetailCubit cubit,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _AddProductLineSheet()),
  );
}

class _AddProductLineSheet extends StatefulWidget {
  const _AddProductLineSheet();

  @override
  State<_AddProductLineSheet> createState() => _AddProductLineSheetState();
}

class _AddProductLineSheetState extends State<_AddProductLineSheet> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  Timer? _debounce;
  List<Product> _results = const [];
  Product? _selected;
  bool _searching = false;
  bool _saving = false;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results = await context.read<OrderDetailCubit>().searchProducts(
        query,
      );
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) _search(query);
    });
  }

  double? _parseQuantity() =>
      double.tryParse(_quantityController.text.trim().replaceAll(',', '.'));

  Future<void> _onSubmit() async {
    final quantity = _parseQuantity();
    if (_selected == null || quantity == null || quantity <= 0) return;
    setState(() {
      _saving = true;
      _errorCode = null;
    });
    final cubit = context.read<OrderDetailCubit>();
    final ok = await cubit.addProduct(
      productCode: _selected!.code,
      quantity: quantity,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _errorCode = ok
          ? null
          : (cubit.state is OrderDetailLoaded
                ? (cubit.state as OrderDetailLoaded).errorCode
                : null);
    });
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final quantity = _parseQuantity();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              const SizedBox(height: 20),
              Text(
                l10n.addProduct,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchProducts,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _searching
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final product = _results[index];
                          final selected = _selected?.code == product.code;
                          return ListTile(
                            dense: true,
                            selected: selected,
                            leading: Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.settings_suggest_outlined,
                              color: selected
                                  ? scheme.primary
                                  : scheme.secondary,
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              '\$${product.salePriceWithTax.toStringAsFixed(2)}'
                              ' • ${l10n.stockLabel}: '
                              '${product.stock?.toStringAsFixed(0) ?? '0'}',
                            ),
                            onTap: () => setState(() => _selected = product),
                          );
                        },
                      ),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.quantity,
                  prefixIcon: const Icon(Icons.numbers_outlined),
                ),
              ),
              SheetErrorBanner(errorCode: _errorCode),
              const SizedBox(height: 16),
              SheetSubmitButton(
                saving: _saving,
                onPressed:
                    (_selected != null && quantity != null && quantity > 0)
                    ? _onSubmit
                    : null,
                label: l10n.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
