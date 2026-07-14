/// Fallback-value helper for nullable primitives.
extension OrDefaultExtension<T> on T? {
  /// Returns this value, or a built-in zero-value default for [T] when this
  /// is `null` (`0`, `0.0`, `''`, `{}`, or `[]`).
  ///
  /// ```dart
  /// (null as int?).orDefault; // 0
  /// 'a'.orDefault;            // 'a'
  /// ```
  T get orDefault {
    final value = this;
    if (value == null) {
      return {
        int: 0,
        double: 0.0,
        String: '',
        Map: {},
        List: [],
      }[T] as T;
    } else {
      return value;
    }
  }
}

/// Wraps any value into a [Future], optionally after a delay.
extension FutureExtension<T> on T {
  /// Returns `this` as a completed [Future], or as a [Future] that resolves
  /// after [duration] when provided.
  ///
  /// ```dart
  /// 42.futureBuilder();                        // resolves immediately
  /// 42.futureBuilder(Duration(seconds: 1));     // resolves after 1s
  /// ```
  Future<T> futureBuilder([Duration? duration]) => duration != null
      ? Future.delayed(duration, () => this)
      : Future.value(this);
}