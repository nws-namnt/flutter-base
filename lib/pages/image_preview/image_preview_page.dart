import 'package:flutter/material.dart';
import 'package:flutter_base/base.dart';

/// Full-screen, pinch-to-zoom viewer opened by [ImagePreviewPage]. Not
/// meant to be routed to independently — [heroTag] must match the
/// thumbnail that pushed it.
class ImagePreviewPage extends StatelessWidget {
  const ImagePreviewPage({super.key, required this.heroTag, required this.child});

  /// Must match the [Hero] tag of the thumbnail that opened this page.
  final String heroTag;

  /// Widget shown full screen — [HeroImageWidget.preview] if provided,
  /// otherwise [HeroImageWidget.child].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(minScale: 1, maxScale: 4, child: child),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.back,
              ),
            ),
          ),
        ],
      ),
    );
  }
}