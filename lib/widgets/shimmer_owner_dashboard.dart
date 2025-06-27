import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerOwnerDashboard extends StatelessWidget {
  const ShimmerOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 30,
              height: 30,
              color: Colors.grey,
            ),
          ),
        ),
        title: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 16,
            width: 150,
            color: Colors.grey,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(2, (_) => _buildShimmerCard()),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),

            _shimmerBox(width: 100, height: 16), // Lot title
            const SizedBox(height: 8),

            _shimmerBox(width: 80, height: 14), // Price
            const SizedBox(height: 6),

            _shimmerBox(width: 140, height: 14), // Security
            const SizedBox(height: 6),

            Row(
              children: [
                _shimmerCircle(size: 14),
                const SizedBox(width: 6),
                _shimmerBox(width: 40, height: 14), // Rating
              ],
            ),
            const SizedBox(height: 6),

            _shimmerBox(width: 120, height: 14), // Availability
            const SizedBox(height: 6),

            Row(
              children: [
                _shimmerCircle(size: 16),
                const SizedBox(width: 6),
                _shimmerBox(width: 60, height: 14), // Reviews
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _shimmerBox(width: 60, height: 30), // Edit
                const SizedBox(width: 12),
                _shimmerBox(width: 60, height: 30), // Delete
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
    );
  }

  Widget _shimmerCircle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
