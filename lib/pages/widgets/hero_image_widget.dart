import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routers.dart';

/// Wraps [child] in a [Hero] and opens `ImagePreviewPage` (see
/// `Routers.imagePreview`) when tapped.
///
/// [child] can be any widget — `CachedImageWidget`, `Image.asset`,
/// `Image.memory`, `FadeInImage`, etc. [HeroImageWidget] has no opinion on
/// the image source; it only handles the Hero + tap-to-view mechanics.
class HeroImageWidget extends StatelessWidget {
  const HeroImageWidget({
    super.key,
    required this.heroTag,
    required this.child,
    this.preview,
    this.borderRadius,
    this.enabled = true,
    this.isEnableHero = true,
  });

  /// Unique [Hero] tag — must be unique per route (e.g. include an item id
  /// when the same image can appear more than once on screen).
  final String heroTag;

  /// Thumbnail widget rendered here and used as the [Hero] flight's
  /// starting point.
  final Widget child;

  /// Widget shown full screen in `ImagePreviewPage`. Defaults to [child]
  /// when null.
  ///
  /// Pass a separate widget when [child] is optimized for a small box
  /// (e.g. `CachedImageWidget` with `BoxFit.cover` + a capped
  /// `memCacheWidth`) — the full-screen view usually wants
  /// `BoxFit.contain` and no resolution cap. Hero flights render the
  /// *destination* widget throughout the animation, so [preview] looking
  /// different from [child] is expected, standard behavior.
  final Widget? preview;

  /// Corner radius applied to the thumbnail only — the full-screen viewer
  /// is never clipped.
  final BorderRadius? borderRadius;

  /// Set to `false` to disable tap-to-view and render a plain [Hero]
  /// wrapping [child], with no gesture handling.
  final bool enabled;

  /// Set to `false` to disable the [Hero] animation entirely while keeping
  /// the [child] visible.
  final bool isEnableHero;

  @override
  Widget build(BuildContext context) {
    final Widget hero = HeroMode(
      enabled: isEnableHero,
      child: Hero(tag: heroTag, child: child),
    );

    final Widget clipped = borderRadius != null
        ? ClipRRect(borderRadius: borderRadius!, child: hero)
        : hero;

    if (!enabled) return clipped;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.pushNamed(
        Routers.imagePreview.routerName,
        extra: {'heroTag': heroTag, 'child': preview ?? child},
      ),
      child: clipped,
    );
  }
}
