import 'package:flutter/cupertino.dart';

/// Placeholder extension for future numeric helpers on [num].
extension NumExtension<T extends num> on T {

}

extension EdgeInsetsGeometryExtension on double {
  EdgeInsetsGeometry get padAll => EdgeInsets.all(this);

  EdgeInsetsGeometry get padX => EdgeInsets.symmetric(horizontal: this);
  EdgeInsetsGeometry get padY => EdgeInsets.symmetric(vertical: this);

  EdgeInsetsGeometry get padLeft => EdgeInsets.only(left: this);
  EdgeInsetsGeometry get padRight => EdgeInsets.only(right: this);
  EdgeInsetsGeometry get padTop => EdgeInsets.only(top: this);
  EdgeInsetsGeometry get padBottom => EdgeInsets.only(bottom: this);
}