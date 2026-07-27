import 'package:flutter/material.dart';
import 'package:tool_core_app/l10n/app_localizations.dart';
import '../models/home_menu_item.dart';

class HomeMenuCard extends StatefulWidget {
  final HomeMenuItem item;
  final VoidCallback onTap;
  final Color? tint;

  const HomeMenuCard({
    super.key,
    required this.item,
    required this.onTap,
    this.tint,
  });

  @override
  State<HomeMenuCard> createState() => _HomeMenuCardState();
}

class _HomeMenuCardState extends State<HomeMenuCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final available = widget.item.route != null;
    final tint = widget.tint ?? scheme.primary;

    final iconBackground = available
        ? tint.withValues(alpha: 0.14)
        : scheme.onSurface.withValues(alpha: 0.08);
    final iconColor = available
        ? tint
        : scheme.onSurface.withValues(alpha: 0.45);

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: Duration(
        milliseconds: MediaQuery.of(context).disableAnimations ? 0 : 120,
      ),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.item.icon,
                          size: 28,
                          color: iconColor,
                        ),
                      ),
                      const Spacer(),
                      if (available)
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 18,
                          color: scheme.onSurface.withValues(alpha: 0.35),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: available
                          ? null
                          : scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  if (!available) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.comingSoon,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
