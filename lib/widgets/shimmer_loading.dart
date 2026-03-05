import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.height = 80,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFFFE0B2),
      highlightColor: const Color(0xFFFFF3E0),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// A shimmer placeholder for a list item (icon + two lines of text)
  static Widget listItem({int count = 5}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFFFE0B2),
      highlightColor: const Color(0xFFFFF3E0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(count, (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 120, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  /// A shimmer placeholder for a card (e.g. lecture card with thumbnail)
  static Widget card({int count = 3}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFFFE0B2),
      highlightColor: const Color(0xFFFFF3E0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(count, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 16, width: 200, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, width: 120, color: Colors.white),
              ],
            ),
          )),
        ),
      ),
    );
  }

  /// A shimmer placeholder for a grid (e.g. chapter grid)
  static Widget grid({int count = 6, int crossAxisCount = 2}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFFFE0B2),
      highlightColor: const Color(0xFFFFF3E0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: count,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
