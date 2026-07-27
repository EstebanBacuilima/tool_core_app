import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../../../core/widgets/staggered_reveal.dart';
import '../models/home_menu_item.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_menu_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  bool _entranceStarted = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entranceStarted) return;
    _entranceStarted = true;
    if (MediaQuery.of(context).disableAnimations) {
      _entranceController.value = 1.0;
    } else {
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _onItemTap(BuildContext context, HomeMenuItem item) {
    if (item.route != null) {
      // push (not go) so the user can navigate back to home.
      context.push(item.route!);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).comingSoon)),
      );
  }

  Interval _cardInterval(int index) {
    final start = (0.15 + index * 0.12).clamp(0.0, 0.5);
    return Interval(start, (start + 0.5).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final items = buildHomeMenuItems(l10n);
    // Tiles rotate through the palette so the grid feels alive.
    final tints = [scheme.primary];

    return Scaffold(
      appBar: HomeAppBar(
        height: 64 + 24 * MediaQuery.textScalerOf(context).scale(14) / 14,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: StaggeredReveal(
              parent: _entranceController,
              interval: const Interval(0.0, 0.45),
              child: Text(
                l10n.homeMenuTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // Tile height follows the system text scale: a fixed aspect
                // ratio overflows with 2-line labels + the coming-soon chip.
                mainAxisExtent:
                    112 + 44 * MediaQuery.textScalerOf(context).scale(14) / 14,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return StaggeredReveal(
                  parent: _entranceController,
                  interval: _cardInterval(index),
                  child: HomeMenuCard(
                    item: item,
                    tint: tints[index % tints.length],
                    onTap: () => _onItemTap(context, item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
