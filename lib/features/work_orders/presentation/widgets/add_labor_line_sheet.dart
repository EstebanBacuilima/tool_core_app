import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../services/domain/entities/service.dart';
import '../cubit/order_detail_cubit.dart';
import '../cubit/order_detail_state.dart';
import 'sheet_widgets.dart';

Future<bool?> showAddLaborLineSheet(
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
        BlocProvider.value(value: cubit, child: const _AddLaborLineSheet()),
  );
}

class _AddLaborLineSheet extends StatefulWidget {
  const _AddLaborLineSheet();

  @override
  State<_AddLaborLineSheet> createState() => _AddLaborLineSheetState();
}

class _AddLaborLineSheetState extends State<_AddLaborLineSheet> {
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  bool _useCatalog = true;
  List<Service> _services = const [];
  Service? _selectedService;
  bool _loading = true;
  bool _saving = false;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = await context.read<OrderDetailCubit>().getServices();
      if (mounted) {
        setState(() => _services = services.where((s) => s.isActive).toList());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _hoursController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  bool get _canSubmit {
    final quantity = _parse(_quantityController);
    if (quantity == null || quantity <= 0) return false;
    if (_useCatalog) return _selectedService != null;
    return _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> _onSubmit() async {
    setState(() {
      _saving = true;
      _errorCode = null;
    });
    final cubit = context.read<OrderDetailCubit>();
    final ok = await cubit.addLabor(
      serviceCode: _useCatalog ? _selectedService!.code : null,
      description: _useCatalog ? null : _descriptionController.text.trim(),
      hours: _parse(_hoursController),
      quantity: _parse(_quantityController) ?? 1,
      unitPrice: _parse(_priceController),
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 20),
            Text(
              l10n.addLabor,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.handyman_outlined),
                  label: Text(l10n.laborFromCatalog),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.laborFreeForm),
                ),
              ],
              selected: {_useCatalog},
              onSelectionChanged: _saving
                  ? null
                  : (selection) =>
                        setState(() => _useCatalog = selection.first),
            ),
            const SizedBox(height: 16),
            if (_useCatalog)
              _loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String>(
                      initialValue: _selectedService?.code,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.selectService,
                        prefixIcon: const Icon(Icons.handyman_outlined),
                      ),
                      items: [
                        for (final service in _services)
                          DropdownMenuItem(
                            value: service.code,
                            child: Text(
                              '${service.name} '
                              '(\$${service.priceWithTax.toStringAsFixed(2)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _saving
                          ? null
                          : (code) => setState(
                              () => _selectedService = _services.firstWhere(
                                (s) => s.code == code,
                              ),
                            ),
                    )
            else
              TextField(
                controller: _descriptionController,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.laborDescription,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      prefixIcon: const Icon(Icons.numbers_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.laborHours,
                      prefixIcon: const Icon(Icons.schedule_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.laborUnitPrice,
                helperText: l10n.priceWithTaxHelper,
                prefixIcon: const Icon(Icons.attach_money_outlined),
              ),
            ),
            SheetErrorBanner(errorCode: _errorCode),
            const SizedBox(height: 24),
            SheetSubmitButton(
              saving: _saving,
              onPressed: _canSubmit ? _onSubmit : null,
              label: l10n.save,
            ),
          ],
        ),
      ),
    );
  }
}
