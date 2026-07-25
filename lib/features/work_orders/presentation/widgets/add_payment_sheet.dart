import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../domain/entities/payment_method.dart';
import '../cubit/order_detail_cubit.dart';
import '../cubit/order_detail_state.dart';
import 'sheet_widgets.dart';

Future<bool?> showAddPaymentSheet(
  BuildContext context,
  OrderDetailCubit cubit, {
  required double balance,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _AddPaymentSheet(balance: balance),
    ),
  );
}

class _AddPaymentSheet extends StatefulWidget {
  final double balance;

  const _AddPaymentSheet({required this.balance});

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  bool _saving = false;
  String? _errorCode;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _methodLabel(AppLocalizations l10n, PaymentMethod method) =>
      switch (method) {
        PaymentMethod.cash => l10n.methodCash,
        PaymentMethod.transfer => l10n.methodTransfer,
        PaymentMethod.card => l10n.methodCard,
        PaymentMethod.other => l10n.methodOther,
      };

  double? _parseAmount() =>
      double.tryParse(_amountController.text.trim().replaceAll(',', '.'));

  Future<void> _onSubmit() async {
    final amount = _parseAmount();
    if (amount == null || amount <= 0) return;
    setState(() {
      _saving = true;
      _errorCode = null;
    });
    final cubit = context.read<OrderDetailCubit>();
    final ok = await cubit.addPayment(
      amount: amount,
      method: _method,
      reference: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
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
    final amount = _parseAmount();

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 20),
          Text(
            l10n.addPayment,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.balanceLabel}: \$${widget.balance.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.paymentAmount,
              prefixIcon: const Icon(Icons.attach_money_outlined),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _method,
            decoration: InputDecoration(
              labelText: l10n.paymentMethod,
              prefixIcon: const Icon(Icons.payments_outlined),
            ),
            items: [
              for (final method in PaymentMethod.values)
                DropdownMenuItem(
                  value: method,
                  child: Text(_methodLabel(l10n, method)),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _method = value!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: l10n.paymentReference,
                    prefixIcon: const Icon(Icons.tag_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.paymentNotes,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                ),
              ),
            ],
          ),
          SheetErrorBanner(errorCode: _errorCode),
          const SizedBox(height: 24),
          SheetSubmitButton(
            saving: _saving,
            onPressed: (amount != null && amount > 0) ? _onSubmit : null,
            label: l10n.save,
          ),
        ],
      ),
    );
  }
}
