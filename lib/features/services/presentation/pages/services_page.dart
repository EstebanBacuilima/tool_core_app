import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../domain/entities/service.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';
import '../widgets/service_form_sheet.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ServicesCubit>()..load(),
      child: const _ServicesView(),
    );
  }
}

class _ServicesView extends StatelessWidget {
  const _ServicesView();

  Future<void> _openForm(BuildContext context, {Service? service}) async {
    final saved = await showServiceFormSheet(context, service: service);
    if (saved == true && context.mounted) {
      context.read<ServicesCubit>().load();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(AppLocalizations.of(context).serviceSaved),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuServices)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.serviceNew),
      ),
      body: BlocConsumer<ServicesCubit, ServicesState>(
        listenWhen: (previous, current) =>
            previous is ServicesLoaded &&
            previous.togglingCode != null &&
            current is ServicesLoaded &&
            current.togglingCode == null,
        listener: (context, state) {
          final loaded = state as ServicesLoaded;
          final String message;
          if (loaded.errorCode != null) {
            message = localizeErrorCode(l10n, loaded.errorCode!);
          } else {
            final toggled = context.read<ServicesCubit>().lastToggled;
            message = toggled?.isActive ?? true
                ? l10n.serviceActivated
                : l10n.serviceDeactivated;
          }
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(message),
              ),
            );
        },
        builder: (context, state) {
          return switch (state) {
            ServicesInitial() || ServicesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ServicesFailure(:final code) => _ErrorView(code: code),
            ServicesLoaded(:final services, :final togglingCode) =>
              services.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      onRefresh: () => context.read<ServicesCubit>().load(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        itemCount: services.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return _ServiceTile(
                            service: service,
                            toggling: togglingCode == service.code,
                            onToggle: togglingCode == null
                                ? (value) => context
                                      .read<ServicesCubit>()
                                      .toggleActive(service, value)
                                : null,
                            onTap: () => _openForm(context, service: service),
                          );
                        },
                      ),
                    ),
          };
        },
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Service service;
  final bool toggling;
  final ValueChanged<bool>? onToggle;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.service,
    required this.toggling,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final statusColor = service.isActive ? Colors.lightGreen : scheme.error;

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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.handyman_outlined, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (service.description != null &&
                        service.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        service.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${service.priceWithTax.toStringAsFixed(2)}',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      service.isActive ? l10n.activeLabel : l10n.inactiveLabel,
                      style: textTheme.labelSmall?.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              if (toggling)
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                )
              else
                Switch(
                  value: service.isActive,
                  onChanged: onToggle,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.handyman_outlined,
            size: 64,
            color: scheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.servicesEmpty,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
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
            onPressed: () => context.read<ServicesCubit>().load(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
