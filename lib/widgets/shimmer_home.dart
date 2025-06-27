import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        const SizedBox(height: 16),

        // Search Bar Placeholder
        ShimmerBox(height: 50, borderRadius: BorderRadius.circular(12)),

        const SizedBox(height: 20),

        // Filter icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (_) {
            return Column(
              children: [
                ShimmerBox(height: 50, width: 50, shape: BoxShape.circle),
                const SizedBox(height: 8),
                ShimmerBox(height: 12, width: 40, borderRadius: BorderRadius.circular(4)),
              ],
            );
          }),
        ),

        const SizedBox(height: 20),

        // Map Box
        ShimmerBox(height: 180, borderRadius: BorderRadius.circular(8)),

        const SizedBox(height: 20),

        // Cards
        ...List.generate(2, (_) => const ParkingSlotShimmer()),
      ],
    );
  }
}

class ParkingSlotShimmer extends StatelessWidget {
  const ParkingSlotShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
      ),
      child: Row(
        children: [
          ShimmerBox(height: 80, width: 80, borderRadius: BorderRadius.circular(8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 16, width: double.infinity),
                const SizedBox(height: 8),
                ShimmerBox(height: 12, width: 100),
                const SizedBox(height: 4),
                ShimmerBox(height: 12, width: 80),
                const SizedBox(height: 4),
                ShimmerBox(height: 12, width: 60),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ShimmerBox(height: 36, width: 60, borderRadius: BorderRadius.circular(8)),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : borderRadius,
        ),
      ),
    );
  }
}
