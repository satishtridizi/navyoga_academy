import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// MAIN BACKGROUND
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xffFCFBFB), Color(0xffFAF9FC)],
            ),
          ),
        ),

        /// TOP ORANGE CIRCLE
        Positioned(
          top: 60,
          left: 70,
          child: _circle(65, const Color(0xffF6A77A).withOpacity(0.18)),
        ),

        /// TOP PURPLE CIRCLE
        Positioned(
          top: 140,
          right: 90,
          child: _circle(48, const Color(0xffDCCFE3).withOpacity(0.15)),
        ),

        /// BOTTOM SMALL CIRCLE
        Positioned(
          bottom: 150,
          left: 120,
          child: _circle(40, const Color(0xffF2C6B8).withOpacity(0.12)),
        ),

        /// BOTTOM BIG CIRCLE
        Positioned(
          bottom: 100,
          right: 70,
          child: _circle(80, const Color(0xffF3C7C7).withOpacity(0.12)),
        ),

        /// YOGA ICONS
        _icon(Icons.self_improvement, 120, 200, 80),
        _icon(Icons.accessibility_new, 250, 260, 80),
        _icon(Icons.self_improvement, 70, 360, 50),
        _icon(Icons.sports_gymnastics, 290, 430, 55),
        _icon(Icons.self_improvement, 180, 390, 40),
        _icon(Icons.airline_seat_recline_normal, 250, 520, 50),
        _icon(Icons.sports_martial_arts, 120, 610, 70),

        /// SCREEN CONTENT
        child,
      ],
    );
  }

  /// CIRCLE
  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  /// ICON
  Widget _icon(IconData icon, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Icon(icon, size: size, color: Colors.black.withValues(alpha: 0.0)),
    );
  }
}
