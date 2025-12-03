import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

// Reusable CTA with LiquidGlass on supported platforms; falls back to a solid button on desktop/web.
class GlassButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final Color color;

  const GlassButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
    this.color = const Color(0xFFF5821F),
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: _supportsLiquid ? Colors.transparent : color,
        foregroundColor: Colors.white,
        overlayColor: Colors.white24,
        surfaceTintColor: Colors.transparent,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );

    if (!_supportsLiquid) return button;

    return SizedBox(
      height: 52,
      child: LiquidGlassView(
        backgroundWidget: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        children: [
          LiquidGlass(
            width: double.infinity,
            height: 52,
            magnification: 1,
            distortion: 0.18,
            distortionWidth: 40,
            blur: const LiquidGlassBlur(sigmaX: 2, sigmaY: 1),
            shape: RoundedRectangleShape(
              cornerRadius: 10,
              borderWidth: 2,
              borderSoftness: 5,
              lightIntensity: 1.2,
            ),
            position: const LiquidGlassAlignPosition(alignment: Alignment.center),
            child: Center(child: button),
          ),
        ],
      ),
    );
  }
}

bool get _supportsLiquid {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return false;
    default:
      return true;
  }
}
