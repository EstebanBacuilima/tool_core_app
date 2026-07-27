import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/work_order_detail.dart';
import '../../domain/entities/work_order_status_codes.dart';
import '../cubit/order_detail_cubit.dart';
import '../cubit/order_detail_state.dart';
import '../widgets/add_labor_line_sheet.dart';
import '../widgets/add_payment_sheet.dart';
import '../widgets/add_product_line_sheet.dart';
import '../widgets/change_status_sheet.dart';
import '../widgets/edit_order_sheet.dart';

class WorkOrderDetailPage extends StatelessWidget {
  final String orderCode;

  const WorkOrderDetailPage({super.key, required this.orderCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDetailCubit>(param1: orderCode)..load(),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  Future<void> _confirmRemove(
    BuildContext context, {
    required Future<bool> Function() action,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDeleteLine),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) await action();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<OrderDetailCubit, OrderDetailState>(
      listener: (context, state) {
        // Errors from non-sheet actions (e.g. removing a line).
        if (state is OrderDetailLoaded && state.errorCode != null) {
          _snack(context, localizeErrorCode(l10n, state.errorCode!));
        }
      },
      builder: (context, state) {
        return switch (state) {
          OrderDetailInitial() || OrderDetailLoading() => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
          OrderDetailFailure(:final code) => Scaffold(
            appBar: AppBar(),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(localizeErrorCode(l10n, code)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context.read<OrderDetailCubit>().load(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
          OrderDetailLoaded() => _LoadedView(
            state: state,
            onSnack: (message) => _snack(context, message),
            onConfirmRemove: (action) =>
                _confirmRemove(context, action: action),
          ),
        };
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  final OrderDetailLoaded state;
  final void Function(String message) onSnack;
  final void Function(Future<bool> Function() action) onConfirmRemove;

  const _LoadedView({
    required this.state,
    required this.onSnack,
    required this.onConfirmRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<OrderDetailCubit>();
    final detail = state.detail;
    final locked = detail.isLocked;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.orderNumber),
        actions: [
          if (!locked)
            IconButton(
              tooltip: l10n.editOrder,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final saved = await showEditOrderSheet(context, cubit, detail);
                if (saved == true) onSnack(l10n.changesSaved);
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: cubit.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _StatusStrip(state: state),
            if (locked) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.orderLockedBanner)),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final changed = await showChangeStatusSheet(
                    context,
                    cubit,
                    currentStatusCode: detail.statusCode,
                    statuses: state.statuses,
                  );
                  if (changed == true) onSnack(l10n.statusUpdated);
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.advanceStatus),
              ),
            ],
            const SizedBox(height: 16),
            _InfoCard(detail: detail),
            const SizedBox(height: 16),
            _LinesSection(
              title: l10n.partsSection,
              icon: Icons.settings_suggest_outlined,
              addLabel: l10n.addProduct,
              locked: locked,
              onAdd: () async {
                final added = await showAddProductLineSheet(context, cubit);
                if (added == true) onSnack(l10n.changesSaved);
              },
              children: [
                for (final line in detail.products)
                  _LineTile(
                    title: line.productName,
                    subtitle:
                        '${line.quantity} × \$${line.unitPrice.toStringAsFixed(2)}',
                    total: line.total,
                    locked: locked,
                    onDelete: () =>
                        onConfirmRemove(() => cubit.removeProduct(line.id)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _LinesSection(
              title: l10n.laborSection,
              icon: Icons.handyman_outlined,
              addLabel: l10n.addLabor,
              locked: locked,
              onAdd: () async {
                final added = await showAddLaborLineSheet(context, cubit);
                if (added == true) onSnack(l10n.changesSaved);
              },
              children: [
                for (final line in detail.labors)
                  _LineTile(
                    title: line.description,
                    subtitle: line.hours != null
                        ? '${line.hours}h × \$${line.unitPrice.toStringAsFixed(2)}'
                        : '${line.quantity} × \$${line.unitPrice.toStringAsFixed(2)}',
                    total: line.total,
                    locked: locked,
                    onDelete: () =>
                        onConfirmRemove(() => cubit.removeLabor(line.id)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _TotalsCard(detail: detail),
            const SizedBox(height: 16),
            _PaymentsSection(
              state: state,
              onAdd: () async {
                final added = await showAddPaymentSheet(
                  context,
                  cubit,
                  balance: detail.balance,
                );
                if (added == true) onSnack(l10n.paymentSaved);
              },
            ),
            const SizedBox(height: 16),
            _HistorySection(detail: detail),
          ],
        ),
      ),
    );
  }
}

/// Horizontal workflow strip: the 5 states with the current highlighted.
class _StatusStrip extends StatelessWidget {
  final OrderDetailLoaded state;

  const _StatusStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final flow = state.statuses
        .where((s) => s.code != WorkOrderStatusCodes.cancelled)
        .toList();
    final currentIndex = flow.indexWhere(
      (s) => s.code == state.detail.statusCode,
    );
    final cancelled = state.detail.statusCode == WorkOrderStatusCodes.cancelled;

    if (cancelled) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: scheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.detail.statusName,
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < flow.length; i++) ...[
            if (i > 0)
              Container(
                width: 20,
                height: 2,
                color: i <= currentIndex
                    ? scheme.primary
                    : scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: i == currentIndex
                    ? scheme.primary
                    : i < currentIndex
                    ? scheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: i > currentIndex
                    ? Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              child: Text(
                flow[i].name,
                style: textTheme.labelSmall?.copyWith(
                  color: i == currentIndex
                      ? scheme.onPrimary
                      : i < currentIndex
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: i == currentIndex ? FontWeight.w600 : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final WorkOrderDetail detail;

  const _InfoCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget row(IconData icon, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.secondary),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: textTheme.bodySmall)),
        ],
      ),
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(Icons.person_outline, detail.customer.fullName),
            row(Icons.directions_car_outlined, detail.vehicle.label),
            if (detail.intakeMileage != null)
              row(
                Icons.speed_outlined,
                '${l10n.intakeMileage}: ${detail.intakeMileage} km',
              ),
            if (detail.fuelLevel != null)
              row(
                Icons.local_gas_station_outlined,
                '${l10n.fuelLevel}: ${detail.fuelLevel}',
              ),
            if (detail.customerComplaint != null)
              row(Icons.record_voice_over_outlined, detail.customerComplaint!),
            if (detail.diagnosis != null)
              row(
                Icons.troubleshoot_outlined,
                '${l10n.diagnosis}: ${detail.diagnosis}',
              ),
            if (detail.observations != null)
              row(Icons.notes_outlined, detail.observations!),
          ],
        ),
      ),
    );
  }
}

class _LinesSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String addLabel;
  final bool locked;
  final VoidCallback onAdd;
  final List<Widget> children;

  const _LinesSection({
    required this.title,
    required this.icon,
    required this.addLabel,
    required this.locked,
    required this.onAdd,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: scheme.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!locked)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text(addLabel),
              ),
          ],
        ),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '—',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          ...children,
      ],
    );
  }
}

class _LineTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double total;
  final bool locked;
  final VoidCallback onDelete;

  const _LineTile({
    required this.title,
    required this.subtitle,
    required this.total,
    required this.locked,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (!locked)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.delete_outline, size: 20, color: scheme.error),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final WorkOrderDetail detail;

  const _TotalsCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget row(String label, double value, {bool bold = false, Color? color}) {
      final style = bold
          ? textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            )
          : textTheme.bodySmall?.copyWith(color: color);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            const SizedBox(width: 8),
            Text('\$${value.toStringAsFixed(2)}', style: style),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.secondary.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            row(l10n.subtotalParts, detail.subtotalProducts),
            row(l10n.subtotalLabor, detail.subtotalLabors),
            if (detail.discount > 0) row(l10n.discountLabel, -detail.discount),
            row(
              '${l10n.taxLabel} (${detail.taxRatePercent.toStringAsFixed(0)}%)',
              detail.taxAmount,
            ),
            const Divider(height: 16),
            row(l10n.totalLabel, detail.total, bold: true),
            row(l10n.paidLabel, detail.paidAmount),
            row(
              l10n.balanceLabel,
              detail.balance,
              bold: true,
              color: detail.balance > 0 ? scheme.error : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsSection extends StatelessWidget {
  final OrderDetailLoaded state;
  final VoidCallback onAdd;

  const _PaymentsSection({required this.state, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final detail = state.detail;
    final canPay =
        detail.balance > 0 &&
        detail.statusCode != WorkOrderStatusCodes.cancelled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.payments_outlined, size: 20, color: scheme.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.paymentsSection,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (canPay)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addPayment),
              ),
          ],
        ),
        if (detail.payments.isEmpty)
          Text(
            '—',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          )
        else
          for (final payment in detail.payments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: scheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [
                        // Wire code ('cash') -> localized label.
                        switch (PaymentMethod.fromValue(payment.method)) {
                          PaymentMethod.cash => l10n.methodCash,
                          PaymentMethod.transfer => l10n.methodTransfer,
                          PaymentMethod.card => l10n.methodCard,
                          PaymentMethod.other => l10n.methodOther,
                          null => payment.method,
                        },
                        ?payment.reference,
                      ].join(' • '),
                      style: textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '\$${payment.amount.toStringAsFixed(2)}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  final WorkOrderDetail detail;

  const _HistorySection({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, size: 20, color: scheme.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.historySection,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final entry in detail.statusHistory)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, size: 8, color: scheme.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.statusName,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        [
                          entry.createdBy,
                          if (entry.createdAt != null)
                            entry.createdAt!.toLocal().toString().substring(
                              0,
                              16,
                            ),
                          if (entry.comment != null) entry.comment!,
                        ].join(' • '),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
