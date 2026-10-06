import 'package:flutter/material.dart';
import 'package:flutter_mvvm_riverpod/features/common/ui/widgets/common_shimmer.dart';

import '/theme/app_colors.dart';

class ShimmerTrackerList extends StatelessWidget {
  const ShimmerTrackerList({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 4,
      ),
      itemCount: 10, // Show 6 shimmer items while loading
      itemBuilder: (context, index) {
        return CommonShimmer(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.mono0,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
