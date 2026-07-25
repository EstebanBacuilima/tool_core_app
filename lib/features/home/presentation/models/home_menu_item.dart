import 'package:flutter/material.dart';
import 'package:tool_core_app/l10n/app_localizations.dart';
import '../../../../app/router/app_router.dart';

class HomeMenuItem {
  final IconData icon;
  final String label;

  final String? route;

  const HomeMenuItem({required this.icon, required this.label, this.route});
}

/// Init menu list
List<HomeMenuItem> buildHomeMenuItems(AppLocalizations l10n) {
  return [
    HomeMenuItem(
      icon: Icons.handyman_outlined,
      label: l10n.menuServices,
      route: AppRoutes.services,
    ),
    HomeMenuItem(
      icon: Icons.inventory_2_outlined,
      label: l10n.menuInventory,
      route: AppRoutes.inventory,
    ),
    HomeMenuItem(
      icon: Icons.assignment_outlined,
      label: l10n.menuWorkOrders,
      route: AppRoutes.workOrders,
    ),
  ];
}
