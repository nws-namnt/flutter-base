import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_base/utils/extensions/widget_extension.dart';

import '../../common/app_colors.dart';

/// A frosted-glass panel: a blurred, semi-transparent [Container] with a
/// gradient overlay, optionally wrapping [child].
class GlassWidget extends StatelessWidget {
  /// Creates a [GlassWidget].
  const GlassWidget({
    super.key,
    this.borderRadius = 20,
    this.width = double.infinity,
    this.height = double.infinity,
    this.blur = 2.0,
    this.frostColor = AppColors.whiteSmoke,
    this.child,
    this.isCenter = true,
  });

  /// Corner radius applied to the clipped panel. Defaults to `20`.
  final double borderRadius;

  /// Panel width. Defaults to [double.infinity].
  final double width;

  /// Panel height. Defaults to [double.infinity].
  final double height;

  /// Backdrop blur sigma (applied to both axes). Defaults to `2.0`.
  final double blur;

  /// Base color for the blur backdrop border and gradient overlay. Defaults
  /// to [AppColors.whiteSmoke].
  final Color frostColor;

  /// Optional content rendered on top of the frosted panel.
  final Widget? child;

  /// Whether [child] is centered within the panel. Defaults to `true`.
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            /// Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blur,
                sigmaY: blur,
              ),
              child: const SizedBox(),
            ),

            /// Gradient effect
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: frostColor.withValues(alpha: 0.2)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    frostColor.withValues(alpha: 0.4),
                    frostColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),

            /// Child if need
            if(child != null)...[
              isCenter ? child!.center : child!,
            ]
          ],
        ),
      ),
    );
  }
}
