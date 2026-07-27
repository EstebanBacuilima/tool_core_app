import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../shared/domain/entities/customer.dart';
import '../cubit/create_order_cubit.dart';
import '../cubit/create_order_state.dart';

const _identificationExistsCode = 'identification-already-exists';

Future<bool?> showCustomerQuickSheet(
  BuildContext context,
  CreateOrderCubit cubit,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _CustomerQuickSheet()),
  );
}

class _CustomerQuickSheet extends StatefulWidget {
  const _CustomerQuickSheet();

  @override
  State<_CustomerQuickSheet> createState() => _CustomerQuickSheetState();
}

class _CustomerQuickSheetState extends State<_CustomerQuickSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _identificationController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _documentTypeCode;
  bool _saving = false;

  String? _errorCode;

  Customer? _existingCustomer;
  Timer? _dedupDebounce;

  @override
  void dispose() {
    _dedupDebounce?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _identificationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _nullable(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  void _onIdentificationChanged(String value) {
    _dedupDebounce?.cancel();
    if (_existingCustomer != null) setState(() => _existingCustomer = null);
    final identification = value.trim();
    if (identification.isEmpty || identification.length < 10) return;
    _dedupDebounce = Timer(const Duration(milliseconds: 450), () async {
      final existing = await context
          .read<CreateOrderCubit>()
          .findCustomerByIdentification(identification);
      var textController = _identificationController.text.trim();
      if (!mounted || textController != identification) {
        return;
      }
      setState(() => _existingCustomer = existing);
    });
  }

  void _useExistingCustomer(Customer customer) {
    context.read<CreateOrderCubit>().selectCustomer(customer);
    Navigator.of(context).pop(false);
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _errorCode = null;
    });
    final cubit = context.read<CreateOrderCubit>();
    final created = await cubit.createCustomer(
      firstName: _firstNameController.text.trim(),
      lastName: _nullable(_lastNameController),
      documentTypeCode: _documentTypeCode,
      identificationNumber: _nullable(_identificationController),
      phone: _nullable(_phoneController),
    );
    if (!mounted) return;
    if (created) {
      setState(() => _saving = false);
      Navigator.of(context).pop(true);
      return;
    }
    final errorCode = cubit.state.errorCode;
    Customer? existing;
    if (errorCode == _identificationExistsCode) {
      existing = await cubit.findCustomerByIdentification(
        _identificationController.text.trim(),
      );
      if (!mounted) return;
    }
    setState(() {
      _saving = false;
      _existingCustomer = existing;
      _errorCode = existing == null ? errorCode : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              l10n.customerNew,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _identificationController,
              enabled: !_saving,
              autofocus: true,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              onChanged: _onIdentificationChanged,
              decoration: InputDecoration(
                labelText: l10n.customerIdentification,
                prefixIcon: const Icon(Icons.numbers_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              enabled: !_saving,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.customerFirstName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.requiredField
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              enabled: !_saving,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.customerLastName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<CreateOrderCubit, CreateOrderState>(
              buildWhen: (previous, current) =>
                  previous.documentTypes != current.documentTypes,
              builder: (context, state) => DropdownButtonFormField<String>(
                initialValue: _documentTypeCode,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.documentType,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                items: [
                  for (final type in state.documentTypes)
                    DropdownMenuItem(
                      value: type.code,
                      child: Text(type.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _documentTypeCode = value),
                validator: (value) =>
                    (_identificationController.text.trim().isNotEmpty &&
                        value == null)
                    ? l10n.errorDocumentTypeRequired
                    : null,
              ),
            ),
            if (_existingCustomer != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.tertiary.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: scheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.customerAlreadyExists,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _existingCustomer!.fullName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_existingCustomer!.phone != null)
                      Text(
                        _existingCustomer!.phone!,
                        style: textTheme.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            _useExistingCustomer(_existingCustomer!),
                        icon: const Icon(Icons.person_search_outlined),
                        label: Text(l10n.useThisCustomer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              enabled: !_saving,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.customerPhone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            if (_errorCode != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 20, color: scheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizeErrorCode(l10n, _errorCode!),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: (_saving || _existingCustomer != null)
                  ? null
                  : _onSubmit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: _saving
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
  }
}
