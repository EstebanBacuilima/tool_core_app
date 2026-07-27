import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../core/di/injector.dart';
import '../core/theme/theme_cubit.dart';
import '../core/theme/theme_state.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import 'router/app_router.dart';

/// Root widget for the app
class ToolCoreApp extends StatefulWidget {
  const ToolCoreApp({super.key});

  @override
  State<ToolCoreApp> createState() => _ToolCoreAppState();
}

class _ToolCoreAppState extends State<ToolCoreApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(getIt<AuthCubit>());
    // Restore the session once at startup; the router redirects when done.
    getIt<AuthCubit>().checkSession();
    // Restore the saved light/dark preference.
    getIt<ThemeCubit>().loadSavedMode();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            routerConfig: _router,
            // Same brand seed in both modes; themeMode decides which one
            // is active (system follows the device).
            theme: themeState.brand.toLightTheme(),
            darkTheme: themeState.brand.toDarkTheme(),
            themeMode: themeState.mode,
            // Use device language by default
            locale: null,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
