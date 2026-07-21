import 'package:flutter/material.dart';

abstract final class ResponsiveLayout {
  static const double maxContentWidth = 640;

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 390) return 16;
    if (width < 430) return 20;
    return 24;
  }

  static double compactGap(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 750 ? 16 : 24;

  static double heroSize(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return (size.shortestSide * .43).clamp(140, 190);
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = ResponsiveLayout.maxContentWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.pagePadding(context),
              ),
          child: child,
        ),
      ),
    );
  }
}
