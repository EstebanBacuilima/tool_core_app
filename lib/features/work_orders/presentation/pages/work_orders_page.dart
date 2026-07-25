import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../domain/entities/work_order_status_codes.dart';
import '../../domain/entities/work_order_summary.dart';
import '../cubit/work_orders_cubit.dart';
import '../cubit/work_orders_state.dart';

class WorkOrdersPage extends StatelessWidget {
  const WorkOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WorkOrdersCubit>()..load(),
      child: const _WorkOrdersView(),
    );
  }
}

class _WorkOrdersView extends StatefulWidget {
  const _WorkOrdersView();

  @override
  State<_WorkOrdersView> createState() => _WorkOrdersViewState();
}

class _WorkOrdersViewState extends State<_WorkOrdersView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) context.read<WorkOrdersCubit>().setSearch(query);
    });
  }

  Future<void> _openWizard(BuildContext context) async {
    final createdCode = await context.push<String>(AppRoutes.workOrderNew);
    if (createdCode != null && context.mounted) {
      context.read<WorkOrdersCubit>().load();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(AppLocalizations.of(context).orderCreated),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuWorkOrders)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWizard(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.orderNew),
      ),
      body: BlocBuilder<WorkOrdersCubit, WorkOrdersState>(
        builder: (context, state) {
          return switch (state) {
            WorkOrdersInitial() || WorkOrdersLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            WorkOrdersFailure(:final code) => _ErrorView(code: code),
            WorkOrdersLoaded() => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.searchOrders,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(l10n.allStatuses),
                          selected: state.selectedStatusCode == null,
                          onSelected: (_) =>
                              context.read<WorkOrdersCubit>().setStatus(null),
                        ),
                      ),
                      for (final status in state.statuses)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status.name),
                            selected: state.selectedStatusCode == status.code,
                            onSelected: (_) => context
                                .read<WorkOrdersCubit>()
                                .setStatus(status.code),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _OrderList(state: state)),
              ],
            ),
          };
        },
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final WorkOrdersLoaded state;

  const _OrderList({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.orders.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      final filtered =
          state.search.isNotEmpty || state.selectedStatusCode != null;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered ? Icons.search_off : Icons.assignment_outlined,
              size: 64,
              color: scheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              filtered ? l10n.noResults : l10n.ordersEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<WorkOrdersCubit>().load(),
      // Infinite scroll: request the next page near the bottom.
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            context.read<WorkOrdersCubit>().loadMore();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
          itemCount: state.orders.length + (state.loadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index >= state.orders.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              );
            }
            final order = state.orders[index];
            return _OrderTile(
              order: order,
              onTap: () async {
                await context.push(AppRoutes.workOrderDetail(order.code));
                // Status/totals may have changed in the detail.
                if (context.mounted) {
                  context.read<WorkOrdersCubit>().load();
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final WorkOrderSummary order;
  final VoidCallback onTap;

  const _OrderTile({required this.order, required this.onTap});

  /// Workflow color per status, always from the scheme.
  Color _statusColor(ColorScheme scheme) => switch (order.statusCode) {
    WorkOrderStatusCodes.reception => scheme.primary,
    WorkOrderStatusCodes.inspection ||
    WorkOrderStatusCodes.inRepair => scheme.secondary,
    WorkOrderStatusCodes.quotation ||
    WorkOrderStatusCodes.completed => scheme.tertiary,
    WorkOrderStatusCodes.cancelled => scheme.error,
    _ => scheme.onSurface,
  };

  String _paymentLabel(AppLocalizations l10n) => switch (order.paymentStatus) {
    'paid' => l10n.paymentPaid,
    'partial' => l10n.paymentPartial,
    _ => l10n.paymentPending,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(scheme);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      order.statusName,
                      style: textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ),
                  Icon(
                    Icons.directions_car_outlined,
                    size: 16,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(order.vehiclePlate, style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${l10n.totalLabel}: \$${order.total.toStringAsFixed(2)}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (order.balance > 0)
                    Text(
                      '${l10n.balanceLabel}: '
                      '\$${order.balance.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _paymentLabel(l10n),
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String code;

  const _ErrorView({required this.code});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 64, color: scheme.error),
          const SizedBox(height: 12),
          Text(
            localizeErrorCode(l10n, code),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.read<WorkOrdersCubit>().load(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
