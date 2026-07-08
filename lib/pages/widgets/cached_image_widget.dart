import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// A drop-in wrapper around [CachedNetworkImage] that exposes every
/// constructor parameter of the `cached_network_image` package (v3.4.1).
///
/// Use this instead of [CachedNetworkImage] directly so every network image
/// in the app shares the same themed loading/error fallback by default,
/// while every caching, sizing, and transition option remains overridable
/// per call site.
///
/// If neither [placeholder] nor [progressIndicatorBuilder] is set, a themed
/// spinner is shown while loading. If [errorWidget] is not set, a themed
/// broken-image icon is shown on failure.
class CachedImageWidget extends StatelessWidget {
  /// Creates a [CachedImageWidget].
  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    // Image source
    this.httpHeaders,
    this.cacheKey,
    this.scale = 1.0,
    // Loading & error builders
    this.imageBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.errorListener,
    // Fade transition
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeInCurve = Curves.easeIn,
    this.placeholderFadeInDuration,
    // Layout & painting
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.color,
    this.colorBlendMode,
    this.filterQuality = FilterQuality.low,
    // Caching
    this.cacheManager,
    this.useOldImageOnUrlChange = false,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    // Web
    this.imageRenderMethodForWeb = ImageRenderMethodForWeb.HtmlImage,
  }) : assert(
         placeholder == null || progressIndicatorBuilder == null,
         'CachedImageWidget: only one of placeholder or progressIndicatorBuilder can be set — '
         'see CachedNetworkImage.placeholder.',
       );

  // Image source
  /// The target image to load and cache. See [CachedNetworkImage.imageUrl].
  final String imageUrl;

  /// Optional HTTP headers sent with the image request. See
  /// [CachedNetworkImage.httpHeaders].
  final Map<String, String>? httpHeaders;

  /// Overrides the cache key used for [imageUrl] (defaults to the URL
  /// itself). See [CachedNetworkImage.cacheKey].
  final String? cacheKey;

  /// Scale applied to the resolved [ImageProvider]. Defaults to `1.0`. See
  /// the `scale` parameter of [CachedNetworkImage].
  final double scale;

  // Loading & error builders
  /// Builder that replaces the default rendering once the [ImageProvider]
  /// finishes loading [imageUrl]. See [CachedNetworkImage.imageBuilder].
  final ImageWidgetBuilder? imageBuilder;

  /// Widget shown while [imageUrl] is loading. Mutually exclusive with
  /// [progressIndicatorBuilder] — see the class-level assert. Falls back to
  /// a themed spinner when both are null. See
  /// [CachedNetworkImage.placeholder].
  final PlaceholderWidgetBuilder? placeholder;

  /// Widget shown while [imageUrl] is loading, with download progress.
  /// Mutually exclusive with [placeholder] — see the class-level assert.
  /// See [CachedNetworkImage.progressIndicatorBuilder].
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  /// Widget shown when [imageUrl] fails to load. Falls back to a themed
  /// broken-image icon when null. See [CachedNetworkImage.errorWidget].
  final LoadingErrorWidgetBuilder? errorWidget;

  /// Called when [imageUrl] fails to load. See
  /// [CachedNetworkImage.errorListener].
  final ValueChanged<Object>? errorListener;

  // Fade transition
  /// Fade-out duration for the placeholder/progress UI as the image
  /// appears. Defaults to `1000ms`. See
  /// [CachedNetworkImage.fadeOutDuration].
  final Duration? fadeOutDuration;

  /// Fade-out curve, paired with [fadeOutDuration]. Defaults to
  /// [Curves.easeOut]. See [CachedNetworkImage.fadeOutCurve].
  final Curve fadeOutCurve;

  /// Fade-in duration for [imageUrl] once loaded. Defaults to `500ms`. See
  /// [CachedNetworkImage.fadeInDuration].
  final Duration fadeInDuration;

  /// Fade-in curve, paired with [fadeInDuration]. Defaults to
  /// [Curves.easeIn]. See [CachedNetworkImage.fadeInCurve].
  final Curve fadeInCurve;

  /// Fade-in duration for [placeholder] itself. See
  /// [CachedNetworkImage.placeholderFadeInDuration].
  final Duration? placeholderFadeInDuration;

  // Layout & painting
  /// Forces the rendered image to this width. See
  /// [CachedNetworkImage.width].
  final double? width;

  /// Forces the rendered image to this height. See
  /// [CachedNetworkImage.height].
  final double? height;

  /// How to inscribe the image into [width]/[height]. See
  /// [CachedNetworkImage.fit].
  final BoxFit? fit;

  /// Alignment of the image within its bounds. Defaults to
  /// [Alignment.center]. See [CachedNetworkImage.alignment].
  final Alignment alignment;

  /// How to paint bounds not covered by the image. Defaults to
  /// [ImageRepeat.noRepeat]. See [CachedNetworkImage.repeat].
  final ImageRepeat repeat;

  /// Whether to paint in the ambient [Directionality]. Defaults to `false`.
  /// See [CachedNetworkImage.matchTextDirection].
  final bool matchTextDirection;

  /// Tint blended with every pixel via [colorBlendMode]. See
  /// [CachedNetworkImage.color].
  final Color? color;

  /// Blend mode used to combine [color] with the image. See
  /// [CachedNetworkImage.colorBlendMode].
  final BlendMode? colorBlendMode;

  /// Interpolation quality for scaling. Defaults to [FilterQuality.low].
  /// See [CachedNetworkImage.filterQuality].
  final FilterQuality filterQuality;

  // Caching
  /// Custom cache manager, replacing the package default
  /// ([DefaultCacheManager]). See [CachedNetworkImage.cacheManager].
  final BaseCacheManager? cacheManager;

  /// Animates from the previous image to the new one when [imageUrl]
  /// changes, instead of showing the placeholder again. Defaults to
  /// `false`. See [CachedNetworkImage.useOldImageOnUrlChange].
  final bool useOldImageOnUrlChange;

  /// Resizes the decoded image in memory to this width via [ResizeImage].
  /// See [CachedNetworkImage.memCacheWidth].
  final int? memCacheWidth;

  /// Resizes the decoded image in memory to this height via [ResizeImage].
  /// See [CachedNetworkImage.memCacheHeight].
  final int? memCacheHeight;

  /// Resizes the image before it is written to the disk cache. See
  /// [CachedNetworkImage.maxWidthDiskCache].
  final int? maxWidthDiskCache;

  /// Resizes the image before it is written to the disk cache. See
  /// [CachedNetworkImage.maxHeightDiskCache].
  final int? maxHeightDiskCache;

  // Web
  /// How the image is rendered on Flutter Web. Defaults to
  /// [ImageRenderMethodForWeb.HtmlImage]. See
  /// [CachedNetworkImage.imageRenderMethodForWeb].
  final ImageRenderMethodForWeb imageRenderMethodForWeb;

  /// Whether the caller supplied their own loading UI — if so, it is
  /// forwarded as-is instead of falling back to [_DefaultPlaceholder].
  bool get _hasCustomLoadingUi => placeholder != null || progressIndicatorBuilder != null;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: httpHeaders,
      cacheKey: cacheKey,
      scale: scale,
      imageBuilder: imageBuilder,
      placeholder: _hasCustomLoadingUi
          ? placeholder
          : (_, _) => _DefaultPlaceholder(color: colors.primary),
      progressIndicatorBuilder: progressIndicatorBuilder,
      errorWidget: errorWidget ?? (_, _, _) => _DefaultError(color: colors.error),
      errorListener: errorListener,
      fadeOutDuration: fadeOutDuration,
      fadeOutCurve: fadeOutCurve,
      fadeInDuration: fadeInDuration,
      fadeInCurve: fadeInCurve,
      placeholderFadeInDuration: placeholderFadeInDuration,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      cacheManager: cacheManager,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
      imageRenderMethodForWeb: imageRenderMethodForWeb,
    );
  }
}

/// Themed spinner shown by [CachedImageWidget] when the caller supplies
/// neither [CachedImageWidget.placeholder] nor
/// [CachedImageWidget.progressIndicatorBuilder].
class _DefaultPlaceholder extends StatelessWidget {
  const _DefaultPlaceholder({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      ),
    );
  }
}

/// Themed broken-image icon shown by [CachedImageWidget] when
/// [CachedImageWidget.errorWidget] is not supplied.
class _DefaultError extends StatelessWidget {
  const _DefaultError({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(Icons.broken_image_outlined, color: color));
  }
}
