/// Fallback-value helper for nullable primitives.
extension OrDefaultExtension<T> on T? {
  /// Returns this value, or a built-in zero-value default for [T] when this
  /// is `null` (`0`, `0.0`, `''`, `{}`, or `[]`).
  ///
  /// Usage: call directly on a nullable value to avoid writing a manual
  /// `?? 0` / `?? ''` fallback at every call site.
  ///
  /// Example:
  /// ```dart
  /// (null as int?).orDefault; // 0
  /// 'a'.orDefault;            // 'a'
  /// ```
  ///
  /// Note: only [int], [double], [String], [Map], and [List] have a defined
  /// default. Calling this on a `null` value of any other [T] throws at
  /// runtime, because the internal lookup map has no matching key for it.
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
  /// Usage: reach for this when an API expects a `Future<T>` but you only
  /// have a plain value on hand — e.g. providing a fake/delayed response in
  /// a mock repository, or simulating latency in a demo screen.
  ///
  /// Example:
  /// ```dart
  /// 42.futureBuilder();                        // resolves immediately
  /// 42.futureBuilder(Duration(seconds: 1));     // resolves after 1s
  /// ```
  ///
  /// Note: this extension applies to every type (`T` is unconstrained), so
  /// it's available on any value, including `null` itself.
  Future<T> futureBuilder([Duration? duration]) => duration != null
      ? Future.delayed(duration, () => this)
      : Future.value(this);
}

/// Fluent shorthand for building a [Duration] from an [int], e.g.
/// `5.seconds` instead of `Duration(seconds: 5)`.
extension DurationExtension on int {
  /// Usage: read as "this many days" wherever a [Duration] is expected.
  ///
  /// Example:
  /// ```dart
  /// 3.days; // Duration(days: 3)
  /// ```
  Duration get days => .new(days: this);

  /// Usage: read as "this many hours" wherever a [Duration] is expected.
  ///
  /// Example:
  /// ```dart
  /// 2.hours; // Duration(hours: 2)
  /// ```
  Duration get hours => .new(hours: this);

  /// Usage: read as "this many minutes" wherever a [Duration] is expected.
  ///
  /// Example:
  /// ```dart
  /// 30.minutes; // Duration(minutes: 30)
  /// ```
  Duration get minutes => .new(minutes: this);

  /// Usage: read as "this many seconds" wherever a [Duration] is expected.
  ///
  /// Example:
  /// ```dart
  /// 45.seconds; // Duration(seconds: 45)
  /// ```
  Duration get seconds => .new(seconds: this);

  /// Usage: read as "this many milliseconds" wherever a [Duration] is
  /// expected.
  ///
  /// Example:
  /// ```dart
  /// 500.milliseconds; // Duration(milliseconds: 500)
  /// ```
  Duration get milliseconds => .new(milliseconds: this);

  /// Usage: read as "this many microseconds" wherever a [Duration] is
  /// expected.
  ///
  /// Example:
  /// ```dart
  /// 100.microseconds; // Duration(microseconds: 100)
  /// ```
  Duration get microseconds => .new(microseconds: this);
}
