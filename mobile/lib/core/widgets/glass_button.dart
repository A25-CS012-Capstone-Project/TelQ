import 'package:flutter/material.dart';


enum GlassButtonVariant {
  filled,
  outline,
  text,
}

class GlassButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final Color color;
  final GlassButtonVariant variant;
  final double? width;
  final double height;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.label,
    this.loading = false,
    required this.onPressed,
    this.color = const Color(0xFFF5821F),
    this.variant = GlassButtonVariant.filled,
    this.width,
    this.height = 52,
    this.icon,
  });


  const GlassButton.filled({
    super.key,
    required this.label,
    this.loading = false,
    required this.onPressed,
    this.color = const Color(0xFFF5821F),
    this.width,
    this.height = 52,
    this.icon,
  }) : variant = GlassButtonVariant.filled;


  const GlassButton.outline({
    super.key,
    required this.label,
    this.loading = false,
    required this.onPressed,
    this.color = const Color(0xFFF5821F),
    this.width,
    this.height = 44,
    this.icon,
  }) : variant = GlassButtonVariant.outline;


  const GlassButton.text({
    super.key,
    required this.label,
    this.loading = false,
    required this.onPressed,
    this.color = const Color(0xFFF5821F),
    this.width,
    this.height = 40,
    this.icon,
  }) : variant = GlassButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final button = _buildButton();
    
    return width != null
        ? SizedBox(width: width, height: height, child: button)
        : SizedBox(height: height, child: button);
  }

  Widget _buildButton() {
    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: variant == GlassButtonVariant.filled ? Colors.white : color,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: variant == GlassButtonVariant.filled ? Colors.white : color,
                ),
              ),
            ],
          );

    switch (variant) {
      case GlassButtonVariant.filled:
        return FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            overlayColor: Colors.white24,
            surfaceTintColor: Colors.transparent,
            minimumSize: Size.fromHeight(height),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
          ),
          onPressed: loading ? null : onPressed,
          child: child,
        );
      case GlassButtonVariant.outline:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 2),
            overlayColor: color.withValues(alpha: 0.1),
            minimumSize: Size.fromHeight(height),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.white,
          ),
          onPressed: loading ? null : onPressed,
          child: child,
        );
      case GlassButtonVariant.text:
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: color,
            overlayColor: color.withValues(alpha: 0.1),
            minimumSize: Size.fromHeight(height),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: loading ? null : onPressed,
          child: child,
        );
    }
  }
}
