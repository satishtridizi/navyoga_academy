import 'package:flutter/material.dart';

class AnimatedItem extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedItem({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)), // slide up
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
