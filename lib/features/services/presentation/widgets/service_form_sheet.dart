import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../domain/entities/service.dart';
import '../cubit/service_form_cubit.dart';
import '../cubit/service_form_state.dart';

Future<bool?> showServiceFormSheet(BuildContext context, {Service? service}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => getIt<ServiceFormCubit>(),
      child: _ServiceFormSheet(service: service),
    ),
  );
}

class _ServiceFormSheet extends StatefulWidget {
  final Service? service;

  const _ServiceFormSheet({this.service});

  @override
  State<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<_ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  bool get _isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name);
    _priceController = TextEditingController(
      text: widget.service?.price.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.service?.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Accepts "12.50" and "12,50".
  double? _parsePrice(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final description = _descriptionController.text.trim();
    context.read<ServiceFormCubit>().submit(
      code: widget.service?.code,
      name: _nameController.text.trim(),
      price: _parsePrice(_priceController.text)!,
      description: description.isEmpty ? null : description,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<ServiceFormCubit, ServiceFormState>(
      listener: (context, state) {
        if (state is ServiceFormSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is ServiceFormFailure) {
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
        final isSaving = state is ServiceFormSaving;

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
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
                  _isEdit ? l10n.serviceEdit : l10n.serviceNew,
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
                    labelText: l10n.serviceName,
                    prefixIcon: const Icon(Icons.handyman_outlined),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  enabled: !isSaving,
                  textInputAction: TextInputAction.next,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.servicePrice,
                    prefixIcon: const Icon(Icons.attach_money_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.requiredField;
                    }
                    final price = _parsePrice(value);
                    if (price == null || price <= 0) return l10n.invalidPrice;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !isSaving,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.serviceDescription,
                    alignLabelWithHint: true,
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
        );
      },
    );
  }
}
