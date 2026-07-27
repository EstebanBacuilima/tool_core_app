import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../domain/entities/movement_type.dart';
import '../../domain/entities/product.dart';
import '../cubit/stock_movement_cubit.dart';
import '../cubit/stock_movement_state.dart';

/// Opens the stock movement sheet for [product]. Returns true when a
/// movement was registered.
Future<bool?> showStockMovementSheet(BuildContext context, Product product) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => getIt<StockMovementCubit>(),
      child: _StockMovementSheet(product: product),
    ),
  );
}

class _StockMovementSheet extends StatefulWidget {
  final Product product;

  const _StockMovementSheet({required this.product});

  @override
  State<_StockMovementSheet> createState() => _StockMovementSheetState();
}

class _StockMovementSheetState extends State<_StockMovementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  MovementType _type = MovementType.entry;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  double? _parseQuantity(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final reason = _reasonController.text.trim();
    context.read<StockMovementCubit>().submit(
      productCode: widget.product.code,
      type: _type,
      quantity: _parseQuantity(_quantityController.text)!,
      reason: reason.isEmpty ? null : reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<StockMovementCubit, StockMovementState>(
      listener: (context, state) {
        if (state is StockMovementSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is StockMovementFailure) {
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
        final isSaving = state is StockMovementSaving;

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
                    l10n.stockMovement,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<MovementType>(
                    segments: [
                      ButtonSegment(
                        value: MovementType.entry,
                        icon: const Icon(Icons.arrow_downward),
                        label: Text(l10n.movementEntry),
                      ),
                      ButtonSegment(
                        value: MovementType.exit,
                        icon: const Icon(Icons.arrow_upward),
                        label: Text(l10n.movementExit),
                      ),
                      ButtonSegment(
                        value: MovementType.adjustment,
                        icon: const Icon(Icons.tune),
                        label: Text(l10n.movementAdjustment),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: isSaving
                        ? null
                        : (selection) =>
                              setState(() => _type = selection.first),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    enabled: !isSaving,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      prefixIcon: const Icon(Icons.numbers_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      final quantity = _parseQuantity(value);
                      // adjustment admits 0 (set the count to zero).
                      final min = _type == MovementType.adjustment ? -1 : 0;
                      if (quantity == null || quantity <= min) {
                        return l10n.invalidQuantity;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    enabled: !isSaving,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.movementReason,
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
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
