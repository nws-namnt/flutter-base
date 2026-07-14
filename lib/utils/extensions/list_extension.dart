/// Aggregation helpers (median, sum) for [List] of [num].
extension ListExtension<T extends num> on List<T> {
  /// Returns the median of this list.
  ///
  /// Returns `0.0` for an empty list. Sorts a copy of this list (the
  /// original order is preserved) and returns the middle element, or the
  /// average of the two middle elements when the length is even.
  double get medianList {
    final sorted = [...this]..sort();
    final middleIndex = length ~/ 2;

    return switch (length) {
      0 => 0.0,
      1 => first.toDouble(),
      _ => length.isEven
          ? (sorted[middleIndex] + sorted[middleIndex - 1]) / 2.0
          : sorted[middleIndex].toDouble(),
    };
  }

  /// Returns the sum of all elements in this list.
  ///
  /// Throws a [StateError] if this list is empty, since [reduce] requires
  /// at least one element.
  T get sumList => reduce((a, b) => a + b as T);
}

extension ListMapExtension<T> on List<T> {
  Map<T, E> toMap<E>(E Function(T) f) => {
    for (final item in this) item: f(item)
  };
}