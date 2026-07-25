import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../domain/entities/work_order_detail.dart';
import '../../domain/entities/work_order_header_input.dart';
import '../cubit/order_detail_cubit.dart';
import '../cubit/order_detail_state.dart';
import 'sheet_widgets.dart';

Future<bool?> showEditOrderSheet(
  BuildContext context,
  OrderDetailCubit cubit,
  WorkOrderDetail detail,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _EditOrderSheet(detail: detail),
    ),
  );
}

class _EditOrderSheet extends StatefulWidget {
  final WorkOrderDetail detail;

  const _EditOrderSheet({required this.detail});

  @override
  State<_EditOrderSheet> createState() => _EditOrderSheetState();
}

class _EditOrderSheetState extends State<_EditOrderSheet> {
  late final TextEditingController _mileageController;
  late final TextEditingController _complaintController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _observationsController;
  late final TextEditingController _discountController;
  String? _fuelLevel;
  bool _saving = false;
  String? _errorCode;

  static const _fuelLevels = ['Vacío', '1/4', '1/2', '3/4', 'Lleno'];

  @override
  void initState() {
    super.initState();
    final d = widget.detail;
    _mileageController = TextEditingController(
      text: d.intakeMileage?.toString(),
    );
    _complaintController = TextEditingController(text: d.customerComplaint);
    _diagnosisController = TextEditingController(text: d.diagnosis);
    _observationsController = TextEditingController(text: d.observations);
    _discountController = TextEditingController(
      text: d.discount.toStringAsFixed(2),
    );
    _fuelLevel = d.fuelLevel;
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _complaintController.dispose();
    _diagnosisController.dispose();
    _observationsController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  String? _nullable(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _onSubmit() async {
    setState(() {
      _saving = true;
      _errorCode = null;
    });
    final cubit = context.read<OrderDetailCubit>();
    final ok = await cubit.updateHeader(
      WorkOrderHeaderInput(
        intakeMileage: int.tryParse(_mileageController.text.trim()),
        fuelLevel: _fuelLevel,
        customerComplaint: _nullable(_complaintController),
        diagnosis: _nullable(_diagnosisController),
        observations: _nullable(_observationsController),
        discount:
            double.tryParse(
              _discountController.text.trim().replaceAll(',', '.'),
            ) ??
            0,
      ),
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
              l10n.editOrder,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mileageController,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.intakeMileage,
                      prefixIcon: const Icon(Icons.speed_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    enabled: !_saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.discountLabel,
                      prefixIcon: const Icon(Icons.percent_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final level in _fuelLevels)
                  ChoiceChip(
                    label: Text(level),
                    selected: _fuelLevel == level,
                    onSelected: _saving
                        ? null
                        : (selected) => setState(
                            () => _fuelLevel = selected ? level : null,
                          ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _complaintController,
              enabled: !_saving,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.customerComplaint,
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.record_voice_over_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _diagnosisController,
              enabled: !_saving,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.diagnosis,
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.troubleshoot_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _observationsController,
              enabled: !_saving,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.observations,
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
            ),
            SheetErrorBanner(errorCode: _errorCode),
            const SizedBox(height: 24),
            SheetSubmitButton(
              saving: _saving,
              onPressed: _onSubmit,
              label: l10n.save,
            ),
          ],
        ),
      ),
    );
  }
}
