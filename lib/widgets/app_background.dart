import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// BACKGROUND
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffF8F8FA), Color(0xffF5F3F8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        /// FLOATING CIRCLES
        _circle(40, 80, 60, Colors.orange.withOpacity(0.12)),
        _circle(280, 140, 50, Colors.purple.withOpacity(0.08)),
        _circle(90, 650, 40, Colors.orange.withOpacity(0.08)),
        _circle(260, 700, 80, Colors.red.withOpacity(0.08)),

        /// YOGA ICONS
        _icon(Icons.self_improvement, 70, 180, 90),
        _icon(Icons.accessibility_new, 230, 260, 80),
        _icon(Icons.spa, 140, 330, 50),
        _icon(Icons.fitness_center, 260, 420, 70),
        _icon(Icons.airline_seat_legroom_normal, 110, 520, 80),

        /// SCREEN CONTENT
        child,
      ],
    );
  }

  Widget _circle(double left, double top, double size, Color color) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _icon(IconData icon, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,

      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.96, end: 1),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,

        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },

        child: Opacity(
          opacity: 0.025,
          child: Icon(icon, size: size, color: Colors.black),
        ),
      ),
    );
  }
}
