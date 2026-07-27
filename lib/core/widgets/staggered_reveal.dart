import 'package:flutter/material.dart';

/// Fade + slide-up reveal for one section of a page. Several sections share a
/// single entrance controller; [interval] staggers them into a cascade.
///
/// The owner of the controller decides when to play it and is responsible for
/// honoring `MediaQuery.disableAnimations` (jump to 1.0 instead of forward).
class StaggeredReveal extends StatelessWidget {
  final Animation<double> parent;
  final Interval interval;
  final Widget child;

  const StaggeredReveal({
    super.key,
    required this.parent,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: parent, curve: interval);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
    );
  }
}
