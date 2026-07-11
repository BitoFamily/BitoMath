import 'package:flutter/material.dart';

/// Plays a gentle left-right shake once whenever [trigger] changes value —
/// used for wrong-PIN entry and wrong-answer feedback instead of a harsh
/// red flash. Owns its own [AnimationController], so callers don't need a
/// `TickerProvider` of their own.
class WiggleAnimation extends StatefulWidget {
  final Widget child;
  final Object trigger;
  final double distance;
  final Duration duration;

  const WiggleAnimation({
    super.key,
    required this.child,
    required this.trigger,
    this.distance = 8,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<WiggleAnimation> createState() => _WiggleAnimationState();
}

class _WiggleAnimationState extends State<WiggleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(covariant WiggleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final offset = Offset(
          widget.distance * _anim.value * (_ctrl.value < 0.5 ? 1 : -1),
          0,
        );
        return Transform.translate(offset: offset, child: child);
      },
      child: widget.child,
    );
  }
}
