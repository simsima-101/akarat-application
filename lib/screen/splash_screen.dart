import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Match brand red if needed
  static const Color akaratRed = Color(0xFFE01E26);

  late final Animation<double> _scale;        // icon zoom
  late final Animation<double> _fade;         // icon opacity 0 -> 1
  late final Animation<double> _saturation;   // icon color 0 (gray) -> 1 (full)
  late final Animation<Color?> _bgColor;      // bg white -> red
  late final Animation<double> _outline;      // white outline strength

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    // Fade is very clear now: starts at 0 and rises for ~70% of the timeline
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.70, curve: Curves.easeInOut),
    );

    // Desaturated -> full color over roughly the same window
    _saturation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.80, curve: Curves.easeInOutCubic),
    );

    // Gentle zoom
    _scale = Tween<double>(begin: 0.90, end: 1.18).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    // Background turns red later so fade is visible first
    _bgColor = ColorTween(begin: Colors.white, end: akaratRed).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 1.00, curve: Curves.easeInOutCubic),
      ),
    );

    // White outline blooms in after the fade has started
    _outline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.95, curve: Curves.easeInOut),
    );

    // Precache the icon so the very first frame can start at opacity 0 smoothly
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(const AssetImage('assets/images/app_icon.png'), context);
      if (mounted) _controller.forward();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Home()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build a saturation ColorFilter matrix (0 = grayscale, 1 = full color)
  ColorFilter _saturationFilter(double s) {
    // Luma coefficients
    const r = 0.2126;
    const g = 0.7152;
    const b = 0.0722;

    final inv = 1 - s;
    final rInv = inv * r;
    final gInv = inv * g;
    final bInv = inv * b;

    return ColorFilter.matrix(<double>[
      rInv + s, gInv,     bInv,     0, 0,
      rInv,     gInv + s, bInv,     0, 0,
      rInv,     gInv,     bInv + s, 0, 0,
      0,        0,        0,        1, 0,
    ]);
  }

  // Tinted copy that follows PNG shape (used for outline/glow)
  Widget _tintedIcon({
    required double size,
    required Color color,
    double opacity = 1,
    double blur = 0,
    double extraScale = 1.0,
  }) {
    Widget img = Image.asset(
      'assets/images/app_icon.png',
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcATop,
      filterQuality: FilterQuality.high,
    );

    if (blur > 0) {
      img = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: img,
      );
    }

    return Opacity(
      opacity: opacity,
      child: Transform.scale(scale: extraScale, child: img),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double baseSize = 120;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Outline tuning tied to _outline value
        final glowScale    = 1.0 + 0.14 * _outline.value;
        final strokeScale  = 1.0 + 0.08 * _outline.value;
        final glowOpacity  = 0.38 * _outline.value;
        final strokeOpacity= 1.00 * _outline.value;
        final glowBlur     = 18.0 * _outline.value;

        return Container(
          color: _bgColor.value,
          alignment: Alignment.center,
          child: Transform.scale(
            scale: _scale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft white glow (PNG shape)
                _tintedIcon(
                  size: baseSize,
                  color: Colors.white,
                  opacity: glowOpacity,
                  blur: glowBlur,
                  extraScale: glowScale,
                ),

                // Crisp white "stroke" (PNG shape)
                _tintedIcon(
                  size: baseSize,
                  color: Colors.white,
                  opacity: strokeOpacity,
                  extraScale: strokeScale,
                ),

                // Actual icon: FADE + SATURATION animated together
                FadeTransition(
                  opacity: _fade,
                  child: ColorFiltered(
                    colorFilter: _saturationFilter(_saturation.value),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: baseSize,
                      height: baseSize,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
