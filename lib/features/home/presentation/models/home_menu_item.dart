import 'package:flutter/material.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

class HomeMenuItem {
  final IconData icon;
  final String label;

  final String? route;

  const HomeMenuItem({required this.icon, required this.label, this.route});
}

/// Init menu list
List<HomeMenuItem> buildHomeMenuItems(AppLocalizations l10n) {
  return [
    HomeMenuItem(icon: Icons.handyman_outlined, label: l10n.menuServices),
    HomeMenuItem(icon: Icons.inventory_2_outlined, label: l10n.menuInventory),
    HomeMenuItem(
      icon: Icons.settings_suggest_outlined,
      label: l10n.menuSpareParts,
    ),
    HomeMenuItem(icon: Icons.assignment_outlined, label: l10n.menuWorkOrders),
  ];
}
