import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tool_core_app/l10n/app_localizations.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(88);

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    final initials = _initials(user?.displayName);

    return Container(
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.onSecondary.withValues(alpha: 0.15),
                child: initials.isEmpty
                    ? Icon(Icons.person_outline, color: scheme.onSecondary)
                    : Text(
                        initials,
                        style: textTheme.titleMedium?.copyWith(
                          color: scheme.onSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.homeGreeting} 👋',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      user?.displayName ?? l10n.homeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(width: 8),
              // const _ThemeToggleButton(),
              const SizedBox(width: 8),
              _CircleAction(
                tooltip: l10n.logout,
                icon: Icons.logout,
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _CircleAction(
      tooltip: l10n.themeTooltip,
      icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      onPressed: () => context.read<ThemeCubit>().setMode(
        isDark ? ThemeMode.light : ThemeMode.dark,
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: scheme.onSecondary.withValues(alpha: 0.12),
        foregroundColor: scheme.onSecondary,
      ),
      icon: Icon(icon, size: 20),
    );
  }
}
