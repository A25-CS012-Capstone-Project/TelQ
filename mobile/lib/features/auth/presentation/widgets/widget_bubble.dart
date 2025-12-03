import 'package:flutter/material.dart';


class Bubble extends StatefulWidget {
  final double size;
  final Alignment alignment;
  final double travel; 
  final Duration duration;

  const Bubble({
    super.key,
    required this.size,
    required this.alignment,
    this.travel = 12,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _offsetAnim = Tween<double>(begin: -widget.travel, end: widget.travel)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: AnimatedBuilder(
        animation: _offsetAnim,
        child: Image.asset('assets/images/bubble_profile.png', width: widget.size),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _offsetAnim.value),
            child: child,
          );
        },
      ),
    );
  }
}
