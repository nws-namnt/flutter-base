import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

/// Screen-metrics helpers built on [MediaQuery], for converting between
/// logical pixels, inches, and fractional (0-1) screen sizes.
extension DeviceExtension on BuildContext {
  /// Assumed pixel density used to convert pixels to inches — `150` on
  /// Android/iOS, `96` otherwise (approximate, not device-calibrated).
  double get pixelsPerInch => Platform.isAndroid || Platform.isIOS? 150 : 96;

  /// Returns same as MediaQuery.of(context)
  MediaQueryData get mq => MediaQuery.of(this);

  /// Returns if Orientation is landscape
  bool get isLandscape => mq.orientation == Orientation.landscape;

  /// Returns same as MediaQuery.of(context).size
  Size get sizePx => mq.size;

  /// Returns same as MediaQuery.of(context).size.width
  double get widthPx => sizePx.width;

  /// Returns same as MediaQuery.of(context).height
  double get heightPx => sizePx.height;

  /// Returns same as MediaQuery.of(context).
  double get aspect => sizePx.aspectRatio;

  /// Returns same as MediaQuery.of(context).devicePixelRatio
  double get density => mq.devicePixelRatio;

  /// Returns diagonal screen pixels
  double get diagonalPx {
    final Size s = sizePx;
    return sqrt((s.width * s.width) + (s.height * s.height));
  }

  /// Returns pixel size in Inches
  Size get sizeInches {
    final Size pxSize = sizePx;
    return Size(pxSize.width / pixelsPerInch, pxSize.height / pixelsPerInch);
  }

  /// Returns screen width in Inches
  double get widthInches => sizeInches.width;

  /// Returns screen height in Inches
  double get heightInches => sizeInches.height;

  /// Returns screen diagonal in Inches
  double get diagonalInches => diagonalPx / pixelsPerInch;

  /// Returns fraction (0-1) of screen width in pixels
  double widthPct(double fraction) => fraction * widthPx;

  /// Returns fraction (0-1) of screen height in pixels
  double heightPct(double fraction) => fraction * heightPx;

  /// `true` when the screen's shortest side is narrower than 720 logical
  /// pixels (covers phones and small ~7" tablets); `false` for larger
  /// (~10"+) tablets.
  bool get isSmallDevice {
    // final diagonalDp = sqrt(pow(widthPx, 2) + pow(heightPx, 2));
    // final diagonalInches = diagonalDp / 160;  // 160 dp == 1 inch
    // return diagonalInches <= 10.0 ? true : false;

    final dp = sizePx.shortestSide;
    if (dp < 600) { // Phone
      return true;
    } else if (dp < 720) {  // small tablet
      return true;  // ~7″
    } else {
      return false;  // ~10″+
    }
  }

  /// The user's current text scale factor (accessibility text size setting).
  // ignore: deprecated_member_use
  double get textScale => mq.textScaler.textScaleFactor;

  /// A font-size hint (in logical pixels) scaled proportionally to screen
  /// width, using a `1024`-wide design reference and a `10.0` base size.
  double get scaleText {
    const designWidth = 1024.0;
    const baseHintSize = 10.0;
    final scaleFactor = sizePx.width / designWidth;
    return baseHintSize * scaleFactor;
  }
}