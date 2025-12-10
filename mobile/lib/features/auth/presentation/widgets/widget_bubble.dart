import 'package:flutter/material.dart';

class Bubble extends StatefulWidget {
  final double size;
  final Alignment alignment;
  final double travel;
  final Duration duration;
  final Color? color;
  final double opacity;

  const Bubble({
    super.key,
    required this.size,
    required this.alignment,
    this.travel = 12,
    this.duration = const Duration(seconds: 3),
    this.color,
    this.opacity = 0.9,
  });

  @override
  State<Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -widget.travel, end: widget.travel)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));


    _rotateAnimation = Tween<double>(begin: -0.03, end: 0.03)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? const Color(0xFFF5821F);

    return IgnorePointer(
      child: Align(
        alignment: widget.alignment,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_floatAnimation.value * 0.3, _floatAnimation.value),
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: RadialGradient(
                colors: [
                  baseColor.withValues(alpha: widget.opacity),
                  baseColor.withValues(alpha: widget.opacity * 0.85),
                  baseColor.withValues(alpha: widget.opacity * 0.6),
                  baseColor.withValues(alpha: widget.opacity * 0.3),
                  baseColor.withValues(alpha: 0),
                ],
                stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
                center: const Alignment(-0.2, -0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.4),
                  blurRadius: widget.size * 0.25,
                  spreadRadius: widget.size * 0.02,
                ),
              ],
            ),
         
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _BubbleHighlightPainter(
                highlightColor: Colors.white.withValues(alpha: 0.15),
                glowColor: baseColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _BubbleHighlightPainter extends CustomPainter {
  final Color highlightColor;
  final Color glowColor;

  _BubbleHighlightPainter({
    required this.highlightColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    final highlightRadius = size.width * 0.1;
    final highlightCenter = Offset(size.width * 0.32, size.height * 0.28);
    canvas.drawCircle(highlightCenter, highlightRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class BubblePresets {
  static const Color orange = Color(0xFFF5821F);
  static const Color orangeLight = Color(0xFFFFA600);
  static const Color orangeDark = Color(0xFFE65100);
  static const Color orangeDeep = Color(0xFFD84315);
  static const Color coral = Color(0xFFFF7043);
  static const Color amber = Color(0xFFFFB300);

  
  static List<Widget> standardSet() {
    return [

      const Bubble(
        size: 200,
        alignment: Alignment(-1.2, -1.1),
        duration: Duration(seconds: 4),
        color: orange,
        opacity: 0.95,
      ),
      const Bubble(
        size: 180,
        alignment: Alignment(1.2, -0.9),
        duration: Duration(milliseconds: 3600),
        color: orangeDeep,
        opacity: 0.9,
      ),
      const Bubble(
        size: 170,
        alignment: Alignment(-1.15, 1.05),
        duration: Duration(milliseconds: 3800),
        color: coral,
        opacity: 0.85,
      ),
      const Bubble(
        size: 190,
        alignment: Alignment(1.15, 1.15),
        duration: Duration(seconds: 4),
        color: orangeLight,
        opacity: 0.88,
      ),


      const Bubble(
        size: 130,
        alignment: Alignment(-0.95, -0.4),
        duration: Duration(milliseconds: 3300),
        travel: 10,
        color: amber,
        opacity: 0.75,
      ),
      const Bubble(
        size: 120,
        alignment: Alignment(1.0, 0.3),
        duration: Duration(milliseconds: 3500),
        travel: 11,
        color: orangeDark,
        opacity: 0.7,
      ),


      const Bubble(
        size: 100,
        alignment: Alignment(-0.85, 0.5),
        duration: Duration(milliseconds: 2900),
        travel: 9,
        color: coral,
        opacity: 0.65,
      ),
      const Bubble(
        size: 95,
        alignment: Alignment(0.9, -0.45),
        duration: Duration(milliseconds: 3100),
        travel: 8,
        color: orange,
        opacity: 0.6,
      ),
      const Bubble(
        size: 85,
        alignment: Alignment(0.0, -0.85),
        duration: Duration(milliseconds: 2800),
        travel: 7,
        color: orangeLight,
        opacity: 0.55,
      ),

      
      const Bubble(
        size: 70,
        alignment: Alignment(-0.5, -0.65),
        duration: Duration(milliseconds: 2600),
        travel: 6,
        color: orangeDeep,
        opacity: 0.6,
      ),
      const Bubble(
        size: 65,
        alignment: Alignment(0.55, -0.3),
        duration: Duration(milliseconds: 2700),
        travel: 6,
        color: amber,
        opacity: 0.55,
      ),
      const Bubble(
        size: 60,
        alignment: Alignment(0.4, 0.75),
        duration: Duration(milliseconds: 2500),
        travel: 5,
        color: coral,
        opacity: 0.5,
      ),


      const Bubble(
        size: 50,
        alignment: Alignment(-0.6, 0.8),
        duration: Duration(milliseconds: 2400),
        travel: 5,
        color: orangeLight,
        opacity: 0.55,
      ),
      const Bubble(
        size: 45,
        alignment: Alignment(0.7, 0.5),
        duration: Duration(milliseconds: 2300),
        travel: 4,
        color: orange,
        opacity: 0.5,
      ),
      const Bubble(
        size: 40,
        alignment: Alignment(-0.3, 0.4),
        duration: Duration(milliseconds: 2200),
        travel: 4,
        color: orangeDark,
        opacity: 0.45,
      ),
    ];
  }


  static List<Widget> minimalSet() {
    return [
      const Bubble(
        size: 160,
        alignment: Alignment(-1.15, -1.05),
        color: orange,
        opacity: 0.85,
      ),
      const Bubble(
        size: 140,
        alignment: Alignment(1.1, 1.05),
        color: orangeLight,
        opacity: 0.8,
      ),
      const Bubble(
        size: 80,
        alignment: Alignment(0.95, -0.85),
        travel: 8,
        color: coral,
        opacity: 0.6,
      ),
      const Bubble(
        size: 60,
        alignment: Alignment(-0.9, 0.7),
        travel: 6,
        color: amber,
        opacity: 0.5,
      ),
    ];
  }
}
