import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/errors/error_localizer.dart';
import '../cubit/create_order_cubit.dart';

Future<bool?> showVehicleQuickSheet(
  BuildContext context,
  CreateOrderCubit cubit, {
  String? initialPlate,
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
      child: _VehicleQuickSheet(initialPlate: initialPlate),
    ),
  );
}

class _VehicleQuickSheet extends StatefulWidget {
  final String? initialPlate;

  const _VehicleQuickSheet({this.initialPlate});

  @override
  State<_VehicleQuickSheet> createState() => _VehicleQuickSheetState();
}

class _VehicleQuickSheetState extends State<_VehicleQuickSheet> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();
  bool _saving = false;

  /// Backend error shown INSIDE the sheet (a page-level snackbar would
  /// be hidden behind the modal).
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    final initialPlate = widget.initialPlate?.trim();
    if (initialPlate != null && initialPlate.isNotEmpty) {
      _plateController.text = initialPlate.toUpperCase();
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  String? _nullable(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _errorCode = null;
    });
    final cubit = context.read<CreateOrderCubit>();
    final created = await cubit.createVehicle(
      plate: _plateController.text.trim().toUpperCase(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()),
      color: _nullable(_colorController),
      mileage: int.tryParse(_mileageController.text.trim()),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _errorCode = created ? null : cubit.state.errorCode;
    });
    if (created) Navigator.of(context).pop(true);
  }

  String? _requiredValidator(String? value, AppLocalizations l10n) =>
      (value == null || value.trim().isEmpty) ? l10n.requiredField : null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                l10n.vehicleNew,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _plateController,
                enabled: !_saving,
                autofocus: true,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.vehiclePlate,
                  prefixIcon: const Icon(Icons.pin_outlined),
                ),
                validator: (v) => _requiredValidator(v, l10n),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      enabled: !_saving,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.vehicleBrand,
                        prefixIcon: const Icon(Icons.directions_car_outlined),
                      ),
                      validator: (v) => _requiredValidator(v, l10n),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      enabled: !_saving,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.vehicleModel,
                        prefixIcon: const Icon(Icons.commute_outlined),
                      ),
                      validator: (v) => _requiredValidator(v, l10n),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      enabled: !_saving,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.vehicleYear,
                        prefixIcon: const Icon(Icons.event_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      enabled: !_saving,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.vehicleColor,
                        prefixIcon: const Icon(Icons.palette_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                enabled: !_saving,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.vehicleMileage,
                  prefixIcon: const Icon(Icons.speed_outlined),
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
                          style: textTheme.bodySmall
                              ?.copyWith(color: scheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _onSubmit,
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
      ),
    );
  }
}
