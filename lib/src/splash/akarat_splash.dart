// import 'package:flutter/material.dart';
//
// class AkaratSplash extends StatefulWidget {
//   final Widget child;
//   const AkaratSplash({super.key, required this.child});
//
//   @override
//   State<AkaratSplash> createState() => _AkaratSplashState();
// }
//
// class _AkaratSplashState extends State<AkaratSplash>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   late final AnimationController _controller;
//   late final Animation<double> _scale;
//   late final Animation<double> _opacity;
//   DateTime? _pausedAt;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     );
//
//     _scale = Tween<double>(begin: 0.85, end: 1.0)
//         .chain(CurveTween(curve: Curves.easeOutBack))
//         .animate(_controller);
//
//     _opacity = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
//     );
//
//     _playInitial();
//   }
//
//   Future<void> _playInitial() async {
//     await Future.delayed(const Duration(milliseconds: 120));
//     if (!mounted) return;
//     await _controller.forward();
//     await Future.delayed(const Duration(milliseconds: 200));
//     if (!mounted) return;
//     setState(() {}); // reveal the app
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       _pausedAt = DateTime.now();
//     } else if (state == AppLifecycleState.resumed) {
//       if (_pausedAt != null &&
//           DateTime.now().difference(_pausedAt!) > const Duration(seconds: 20)) {
//         _showResumeOverlay();
//       }
//     }
//   }
//
//   void _showResumeOverlay() {
//     final overlay = Overlay.of(context);
//     if (overlay == null) return;
//     final entry = OverlayEntry(builder: (_) => const _ResumePop());
//     overlay.insert(entry);
//     Future.delayed(const Duration(milliseconds: 900), () => entry.remove());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // After the animation completes, show the real app.
//     if (_controller.status == AnimationStatus.completed) {
//       return widget.child;
//     }
//
//     // While animating, show icon pop.
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: FadeTransition(
//           opacity: _opacity,
//           child: ScaleTransition(
//             scale: _scale,
//             child: Image.asset(
//               'assets/images/app-icon_new.png',
//               width: 112,
//               height: 112,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
// class _ResumePop extends StatefulWidget {
//   const _ResumePop();
//
//   @override
//   State<_ResumePop> createState() => _ResumePopState();
// }
//
// class _ResumePopState extends State<_ResumePop>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _c;
//   late final Animation<double> _scale;
//   late final Animation<double> _opacity;
//
//   @override
//   void initState() {
//     super.initState();
//     _c = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _scale = Tween<double>(begin: 0.9, end: 1.0)
//         .chain(CurveTween(curve: Curves.easeOutBack))
//         .animate(_c);
//     _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
//     _c.forward();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       child: Center(
//         child: FadeTransition(
//           opacity: _opacity,
//           child: ScaleTransition(
//             scale: _scale,
//             child: Image.asset(
//               'assets/images/app-icon_new.png',
//               width: 96,
//               height: 96,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }
// }
