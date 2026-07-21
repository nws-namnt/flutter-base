import 'package:flutter/material.dart';

/// Maps a [TextAlign] to the [WrapAlignment] used to lay out animated segments.
extension TextAlignWrap on TextAlign {
  WrapAlignment get wrapAlignment => this == TextAlign.center
      ? WrapAlignment.center
      : this == TextAlign.end
          ? WrapAlignment.end
          : WrapAlignment.start;
}
