import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/error_localizer.dart';
import '../cubit/create_order_cubit.dart';
import '../cubit/create_order_state.dart';
import '../widgets/customer_quick_sheet.dart';
import '../widgets/vehicle_quick_sheet.dart';

class CreateWorkOrderPage extends StatelessWidget {
  const CreateWorkOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CreateOrderCubit>()
        ..searchVehicles('')
        ..loadDocumentTypes(),
      child: const _CreateOrderView(),
    );
  }
}

class _CreateOrderView extends StatefulWidget {
  const _CreateOrderView();

  @override
  State<_CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<_CreateOrderView> {
  static const _fuelLevels = ['Vacío', '1/4', '1/2', '3/4', 'Lleno'];

  int _step = 0;

  final _vehicleSearchController = TextEditingController();
  final _mileageController = TextEditingController();
  final _complaintController = TextEditingController();
  String? _fuelLevel;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _vehicleSearchController.dispose();
    _mileageController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  void _onVehicleSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) context.read<CreateOrderCubit>().searchVehicles(query);
    });
  }

  /// Plate typed in the search, to pre-fill vehicle creation.
  String get _typedPlate => _vehicleSearchController.text.trim().toUpperCase();

  /// No-results path: create the customer and chain straight into creating
  /// their vehicle with the searched plate pre-filled. If the sheet resolved
  /// an EXISTING customer instead (dedup by identification), it pops false
  /// and the step shows their vehicles rather than jumping to creation.
  Future<void> _createCustomerAndVehicle() async {
    final cubit = context.read<CreateOrderCubit>();
    final createdCustomer = await showCustomerQuickSheet(context, cubit);
    if (createdCustomer == true && mounted) {
      await showVehicleQuickSheet(context, cubit, initialPlate: _typedPlate);
    }
  }

  void _submit(BuildContext context) {
    context.read<CreateOrderCubit>().submit(
      intakeMileage: int.tryParse(_mileageController.text.trim()),
      fuelLevel: _fuelLevel,
      customerComplaint: _complaintController.text.trim().isEmpty
          ? null
          : _complaintController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<CreateOrderCubit, CreateOrderState>(
      listener: (context, state) {
        if (state.status == CreateOrderStatus.success) {
          // Hand the created code back to the list.
          context.pop(state.createdOrderCode);
        } else if (state.errorCode != null) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(localizeErrorCode(l10n, state.errorCode!)),
              ),
            );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.orderNew)),
          body: SafeArea(
            child: Column(
              children: [
                // Hidden while the keyboard is open: in landscape the fixed
                // indicator + bottom bar would not fit the remaining height.
                if (MediaQuery.of(context).viewInsets.bottom == 0)
                  _StepIndicator(
                    step: _step,
                    labels: [
                      l10n.stepVehicle,
                      l10n.stepReception,
                      l10n.stepConfirm,
                    ],
                  ),
                Expanded(
                  child: switch (_step) {
                    0 => _VehicleStep(
                      state: state,
                      vehicleSearchController: _vehicleSearchController,
                      onVehicleSearchChanged: _onVehicleSearchChanged,
                      typedPlate: _typedPlate,
                      onCreateCustomerAndVehicle: _createCustomerAndVehicle,
                    ),
                    1 => _ReceptionStep(
                      mileageController: _mileageController,
                      complaintController: _complaintController,
                      fuelLevels: _fuelLevels,
                      fuelLevel: _fuelLevel,
                      onFuelChanged: (value) =>
                          setState(() => _fuelLevel = value),
                    ),
                    _ => _SummaryStep(
                      state: state,
                      mileage: _mileageController.text.trim(),
                      fuelLevel: _fuelLevel,
                      complaint: _complaintController.text.trim(),
                    ),
                  },
                ),
                _BottomBar(
                  step: _step,
                  state: state,
                  onBack: () => setState(() => _step--),
                  onNext: () => setState(() => _step++),
                  onSkip: () => setState(() => _step = 2),
                  onSubmit: () => _submit(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal 3-dot step indicator with connectors.
class _StepIndicator extends StatelessWidget {
  final int step;
  final List<String> labels;

  const _StepIndicator({required this.step, required this.labels});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: i <= step
                      ? scheme.primary
                      : scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: i <= step
                      ? scheme.primary
                      : scheme.outlineVariant.withValues(alpha: 0.4),
                  child: i < step
                      ? Icon(Icons.check, size: 18, color: scheme.onPrimary)
                      : Text(
                          '${i + 1}',
                          style: textTheme.labelLarge?.copyWith(
                            color: i <= step
                                ? scheme.onPrimary
                                : scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: i == step
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: i == step ? FontWeight.w600 : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Step 1: pick the vehicle. Plate-first: search vehicles directly (plate or
/// owner data); fallback is creating customer+vehicle — the customer sheet
/// dedups by identification and can resolve an existing customer instead.
class _VehicleStep extends StatelessWidget {
  final CreateOrderState state;
  final TextEditingController vehicleSearchController;
  final ValueChanged<String> onVehicleSearchChanged;
  final String typedPlate;
  final VoidCallback onCreateCustomerAndVehicle;

  const _VehicleStep({
    required this.state,
    required this.vehicleSearchController,
    required this.onVehicleSearchChanged,
    required this.typedPlate,
    required this.onCreateCustomerAndVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<CreateOrderCubit>();
    final customer = state.customer;
    final selected = state.vehicle;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        if (customer == null && selected != null) ...[
          // Vehicle picked straight from the plate search.
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: scheme.primary, width: 2),
            ),
            child: ListTile(
              leading: Icon(
                Icons.directions_car_outlined,
                color: scheme.secondary,
              ),
              title: Text(selected.plate),
              subtitle: Text(
                '${selected.brand} ${selected.model}'
                '${selected.year != null ? ' • ${selected.year}' : ''}'
                '${selected.customerName != null ? '\n${selected.customerName}' : ''}',
              ),
              isThreeLine: selected.customerName != null,
              trailing: TextButton(
                onPressed: cubit.clearVehicleSelection,
                child: Text(l10n.change),
              ),
            ),
          ),
        ] else if (customer == null) ...[
          // Plate-first search (also matches the owner's name/ID).
          TextField(
            controller: vehicleSearchController,
            onChanged: onVehicleSearchChanged,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: l10n.searchVehiclesHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onCreateCustomerAndVehicle,
            icon: const Icon(Icons.person_add_outlined),
            label: Text(
              l10n.createCustomerAndVehicle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          if (state.searchingVehicles)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.vehicleResults.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.no_crash_outlined,
                    size: 48,
                    color: scheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noVehiclesFound,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            for (final vehicle in state.vehicleResults)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.secondary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.directions_car_outlined,
                    color: scheme.secondary,
                  ),
                ),
                title: Text(vehicle.plate),
                subtitle: Text(
                  '${vehicle.brand} ${vehicle.model}'
                  '${vehicle.year != null ? ' • ${vehicle.year}' : ''}'
                  '${vehicle.customerName != null ? '\n${vehicle.customerName}' : ''}',
                ),
                isThreeLine: vehicle.customerName != null,
                onTap: () => cubit.selectVehicleResult(vehicle),
              ),
            // Paginated search: offer the next page explicitly.
            if (state.vehiclesHasMore)
              Center(
                child: state.loadingMoreVehicles
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    : TextButton.icon(
                        onPressed: cubit.loadMoreVehicles,
                        icon: const Icon(Icons.expand_more),
                        label: Text(l10n.loadMore),
                      ),
              ),
          ],
        ] else ...[
          // Selected customer card with the option to change it.
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.secondary.withValues(alpha: 0.12),
                child: Icon(Icons.person_outline, color: scheme.secondary),
              ),
              title: Text(customer.fullName),
              subtitle: customer.phone != null ? Text(customer.phone!) : null,
              trailing: TextButton(
                onPressed: cubit.clearCustomer,
                child: Text(l10n.change),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectVehicleHint,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (state.loadingVehicles)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.vehicles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.noVehicles,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            for (final vehicle in state.vehicles)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: state.vehicle?.code == vehicle.code
                          ? scheme.primary
                          : scheme.outlineVariant.withValues(alpha: 0.4),
                      width: state.vehicle?.code == vehicle.code ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.directions_car_outlined,
                      color: scheme.secondary,
                    ),
                    title: Text(vehicle.plate),
                    subtitle: Text(
                      '${vehicle.brand} ${vehicle.model}'
                      '${vehicle.year != null ? ' • ${vehicle.year}' : ''}',
                    ),
                    trailing: state.vehicle?.code == vehicle.code
                        ? Icon(Icons.check_circle, color: scheme.primary)
                        : null,
                    onTap: () => cubit.selectVehicle(vehicle),
                  ),
                ),
              ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () =>
                showVehicleQuickSheet(context, cubit, initialPlate: typedPlate),
            icon: const Icon(Icons.add),
            label: Text(l10n.vehicleNew),
          ),
        ],
      ],
    );
  }
}

/// Step 2: reception data — everything optional.
class _ReceptionStep extends StatelessWidget {
  final TextEditingController mileageController;
  final TextEditingController complaintController;
  final List<String> fuelLevels;
  final String? fuelLevel;
  final ValueChanged<String?> onFuelChanged;

  const _ReceptionStep({
    required this.mileageController,
    required this.complaintController,
    required this.fuelLevels,
    required this.fuelLevel,
    required this.onFuelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        TextField(
          controller: mileageController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.intakeMileage,
            prefixIcon: const Icon(Icons.speed_outlined),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.fuelLevel,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final level in fuelLevels)
              ChoiceChip(
                label: Text(level),
                selected: fuelLevel == level,
                onSelected: (selected) =>
                    onFuelChanged(selected ? level : null),
              ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: complaintController,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.customerComplaint,
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.record_voice_over_outlined),
          ),
        ),
      ],
    );
  }
}

/// Step 3: read-only summary before creating.
class _SummaryStep extends StatelessWidget {
  final CreateOrderState state;
  final String mileage;
  final String? fuelLevel;
  final String complaint;

  const _SummaryStep({
    required this.state,
    required this.mileage,
    required this.fuelLevel,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vehicle = state.vehicle;

    Widget row(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.secondary),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              '$label: ',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                row(
                  Icons.person_outline,
                  l10n.summaryCustomer,
                  // Plate-first picks carry the owner on the vehicle itself.
                  state.customer?.fullName ?? vehicle?.customerName ?? '—',
                ),
                row(
                  Icons.directions_car_outlined,
                  l10n.summaryVehicle,
                  vehicle?.label ?? '—',
                ),
                if (mileage.isNotEmpty)
                  row(Icons.speed_outlined, l10n.intakeMileage, mileage),
                if (fuelLevel != null)
                  row(
                    Icons.local_gas_station_outlined,
                    l10n.fuelLevel,
                    fuelLevel!,
                  ),
                if (complaint.isNotEmpty)
                  row(
                    Icons.record_voice_over_outlined,
                    l10n.customerComplaint,
                    complaint,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: scheme.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.orderStartsInReception,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int step;
  final CreateOrderState state;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.step,
    required this.state,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saving = state.status == CreateOrderStatus.saving;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (step > 0)
                  Flexible(
                    child: OutlinedButton(
                      onPressed: saving ? null : onBack,
                      child: Text(
                        l10n.back,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (step == 1) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: TextButton(
                      onPressed: saving ? null : onSkip,
                      child: Text(
                        l10n.skipStep,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: switch (step) {
              0 => state.vehicle != null ? onNext : null,
              1 => onNext,
              _ => state.canSubmit ? onSubmit : null,
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(step == 2 ? l10n.createOrder : l10n.next, maxLines: 1),
          ),
        ],
      ),
    );
  }
}
