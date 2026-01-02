import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NShimmer extends StatelessWidget {
  const NShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color1,
    this.color2,
  });
  final double? width, height;
  final double? borderRadius;
  final Color? color1, color2;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: color1 ?? Colors.grey.shade400,
      highlightColor: color2 ?? Colors.grey.shade200,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
          color: Colors.white,
        ),
      ),
    );
  }
}
