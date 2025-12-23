import 'package:flutter/material.dart';

class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _animations = List.generate(4, (index) {
      final start = index * 0.2;
      final end = start + 0.4;

      return Tween<double>(begin: 0.3, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(Animation<double> anim, int index) {
    const cuetColors = [Colors.white, Colors.white, Colors.white, Colors.white];

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        double bounce = (anim.value < 0.5 ? anim.value : 1 - anim.value) * 6;

        return Transform.translate(
          offset: Offset(0, -bounce),
          child: Opacity(
            opacity: anim.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: cuetColors[index],
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) => _dot(_animations[i], i)),
    );
  }
}
