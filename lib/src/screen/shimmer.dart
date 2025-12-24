import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const _ShimmerBody(),
      ),
    );
  }
}

class _ShimmerBody extends StatelessWidget {
  const _ShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // ⬅️ prevents vertical overflow
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder with fixed aspect (no overflow)
        const AspectRatio(
          aspectRatio: 16 / 10,
          child: _Box(radius: 12),
        ),

        const SizedBox(height: 12),

        // Title line
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: _Line(height: 14, width: double.infinity),
        ),

        const SizedBox(height: 8),

        // Subtitle line (half width)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _Line(
            height: 14,
            width: MediaQuery.sizeOf(context).width * 0.5,
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const _Line({
    required this.height,
    required this.width,
    this.radius = 6,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _Box(height: height, width: width, radius: radius);
  }
}

class _Box extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  const _Box({this.width, this.height, this.radius = 10, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
