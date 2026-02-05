// lib/screen/splash_screen.dart
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../core/utils/session_manager.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const Color akaratRed = Color(0xFFE01E26);

  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _saturation;
  late final Animation<Color?> _bgColor;
  late final Animation<double> _outline;

  @override
  void initState() {
    super.initState();

    // Start language initialization in background (non-blocking)
    // Future.microtask(_initializeLanguage);

    // === Your beautiful animation stays 100% intact ===
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.70, curve: Curves.easeInOut),
    );

    _saturation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.80, curve: Curves.easeInOutCubic),
    );

    _scale = Tween<double>(begin: 0.90, end: 1.18).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _bgColor = ColorTween(begin: Colors.white, end: akaratRed).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 1.00, curve: Curves.easeInOutCubic),
      ),
    );

    _outline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.95, curve: Curves.easeInOut),
    );

    // Precache icon and start animation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(
          const AssetImage('assets/images/app_icon.png'), context);
      if (mounted) _controller.forward();
    });

    // === After animation → ALWAYS go to Home() ===
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _goToHome();
      }
    });
  }

  // /// Initialize language: clear old pref + force sync with device
  // Future<void> _initializeLanguage() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final old = prefs.getString('language_code');
  //     print('OLD saved language_code = $old');
  //
  //     await prefs.remove('language_code');
  //     print('REMOVED language_code from prefs → now following device');
  //
  //     await LanguageController.instance.useDeviceLanguage();
  //     print('useDeviceLanguage completed');
  //
  //     LanguageController.instance.refreshFromDeviceIfNeeded();
  //     print('After refresh → current lang = ${LanguageController.instance.languageCode}');
  //   } catch (e) {
  //     print('Language init error: $e');
  //   }
  // }

  /// Always navigate to Home — this is the new behavior you wanted!
  Future<void> _goToHome() async {
    try {
      // Still restore session in background (for profile, favorites, etc.)
      await SessionManager().restore();

      if (!mounted) return;

      // Always go to Home — guest or logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } catch (e) {
      // Even if something fails → still go to Home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Home()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ColorFilter _saturationFilter(double s) {
    const r = 0.2126, g = 0.7152, b = 0.0722;
    final inv = 1 - s;
    return ColorFilter.matrix(<double>[
      r * inv + s,
      g * inv,
      b * inv,
      0,
      0,
      r * inv,
      g * inv + s,
      b * inv,
      0,
      0,
      r * inv,
      g * inv,
      b * inv + s,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

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
        final glowScale = 1.0 + 0.14 * _outline.value;
        final strokeScale = 1.0 + 0.08 * _outline.value;
        final glowOpacity = 0.38 * _outline.value;
        final strokeOpacity = 1.00 * _outline.value;
        final glowBlur = 18.0 * _outline.value;

        return Container(
          color: _bgColor.value,
          alignment: Alignment.center,
          child: Transform.scale(
            scale: _scale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _tintedIcon(
                  size: baseSize,
                  color: Colors.white,
                  opacity: glowOpacity,
                  blur: glowBlur,
                  extraScale: glowScale,
                ),
                _tintedIcon(
                  size: baseSize,
                  color: Colors.white,
                  opacity: strokeOpacity,
                  extraScale: strokeScale,
                ),
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
