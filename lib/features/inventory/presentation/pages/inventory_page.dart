import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/error_localizer.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../cubit/inventory_cubit.dart';
import '../cubit/inventory_state.dart';
import '../widgets/product_form_sheet.dart';
import '../widgets/product_unit_labels.dart';
import '../widgets/stock_movement_sheet.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InventoryCubit>()..load(),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Server-side search, debounced so we don't hit the API per keystroke.
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) context.read<InventoryCubit>().setSearch(query);
    });
  }

  Future<void> _openProductForm(
    BuildContext context, {
    required List<ProductCategory> categories,
    Product? product,
  }) async {
    final saved = await showProductFormSheet(
      context,
      categories: categories,
      product: product,
    );
    if (saved == true && context.mounted) {
      context.read<InventoryCubit>().load();
      _showSnack(context, AppLocalizations.of(context).productSaved);
    }
  }

  Future<void> _openMovement(BuildContext context, Product product) async {
    final saved = await showStockMovementSheet(context, product);
    if (saved == true && context.mounted) {
      context.read<InventoryCubit>().load();
      _showSnack(context, AppLocalizations.of(context).movementSaved);
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuInventory)),
      floatingActionButton: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) => switch (state) {
          // The form needs the categories: only offer it once loaded.
          InventoryLoaded(:final categories) => FloatingActionButton.extended(
            onPressed: () => _openProductForm(context, categories: categories),
            icon: const Icon(Icons.add),
            label: Text(l10n.productNew),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          return switch (state) {
            InventoryInitial() || InventoryLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            InventoryFailure(:final code) => _ErrorView(code: code),
            InventoryLoaded() => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.searchProducts,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                // Hidden while the keyboard is open: in landscape the
                // fixed search + chips would not leave room for the list.
                if (MediaQuery.of(context).viewInsets.bottom == 0)
                  _CategoryChips(state: state),
                Expanded(
                  child: _ProductList(
                    state: state,
                    onEdit: (product) => _openProductForm(
                      context,
                      categories: state.categories,
                      product: product,
                    ),
                    onMovement: (product) => _openMovement(context, product),
                  ),
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}

/// Horizontal filter: "all" + every category (children indented by the
/// backend order).
class _CategoryChips extends StatelessWidget {
  final InventoryLoaded state;

  const _CategoryChips({required this.state});

  List<ProductCategory> _flatten(List<ProductCategory> categories) => [
    for (final c in categories) ...[c, ..._flatten(c.children)],
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _flatten(state.categories);

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(l10n.allCategories),
              selected: state.selectedCategoryCode == null,
              onSelected: (_) =>
                  context.read<InventoryCubit>().setCategory(null),
            ),
          ),
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.name),
                selected: state.selectedCategoryCode == category.code,
                onSelected: (_) =>
                    context.read<InventoryCubit>().setCategory(category.code),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final InventoryLoaded state;
  final void Function(Product product) onEdit;
  final void Function(Product product) onMovement;

  const _ProductList({
    required this.state,
    required this.onEdit,
    required this.onMovement,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.products.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      final filtered =
          state.search.isNotEmpty || state.selectedCategoryCode != null;
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filtered ? Icons.search_off : Icons.inventory_2_outlined,
                size: 64,
                color: scheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                filtered ? l10n.noResults : l10n.inventoryEmpty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<InventoryCubit>().load(),
      // Infinite scroll: request the next page near the bottom.
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            context.read<InventoryCubit>().loadMore();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
          itemCount: state.products.length + (state.loadingMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index >= state.products.length) {
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
            final product = state.products[index];
            return _ProductTile(
              product: product,
              onTap: () => onEdit(product),
              onMovement: () => onMovement(product),
            );
          },
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onMovement;

  const _ProductTile({
    required this.product,
    required this.onTap,
    required this.onMovement,
  });

  String _formatStock(double stock) =>
      stock % 1 == 0 ? stock.toStringAsFixed(0) : stock.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final stock = product.stock ?? 0;
    final stockColor = stock > 0 ? scheme.tertiary : scheme.error;
    final unitLabel = localizeProductUnitValue(l10n, product.unit);
    final subtitle = [
      product.categoryName,
      if (product.brand != null && product.brand!.isNotEmpty) product.brand!,
    ].join(' • ');

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
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.settings_suggest_outlined,
                  size: 24,
                  color: scheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!product.isActive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.inactiveLabel,
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${product.salePriceWithTax.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        color: stockColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${l10n.stockLabel}: ${_formatStock(stock)}'
                        '${unitLabel != null ? ' $unitLabel' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: stockColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.stockMovement,
                onPressed: onMovement,
                icon: Icon(Icons.swap_vert, color: scheme.secondary),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              onPressed: () => context.read<InventoryCubit>().load(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
