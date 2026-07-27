import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

/// Animated splash shown while the session is restored
/// (minimum display time enforced in AuthCubit.checkSession).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _loop;

  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _logoScale = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );
    _textFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(_textFade);
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.tertiary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Slow-spinning gear behind the logo.
                    RotationTransition(
                      turns: _loop,
                      child: Icon(
                        Icons.settings_outlined,
                        size: 170,
                        color: scheme.onPrimary.withValues(alpha: 0.15),
                      ),
                    ),
                    // Logo pops in, then gently pulses with the loop.
                    ScaleTransition(
                      scale: _logoScale,
                      child: AnimatedBuilder(
                        animation: _loop,
                        builder: (context, child) {
                          final pulse =
                              1 + 0.04 * math.sin(_loop.value * 2 * math.pi);
                          return Transform.scale(scale: pulse, child: child);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 104,
                            height: 104,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text(
                        l10n.appTitle,
                        style: textTheme.headlineMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.loginSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
