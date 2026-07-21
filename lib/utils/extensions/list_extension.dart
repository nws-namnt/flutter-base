import 'dart:math' as math;

/// Aggregation helpers (median, sum) for [List] of [num].
extension NumListExtension<T extends num> on List<T> {
  /// Returns the median of this list.
  ///
  /// Returns `0.0` for an empty list. Sorts a copy of this list (the
  /// original order is preserved) and returns the middle element, or the
  /// average of the two middle elements when the length is even.
  ///
  /// Usage: use for quick stats on a numeric list (e.g. response times,
  /// scores) without pulling in a separate math/stats package.
  ///
  /// Example:
  /// ```dart
  /// [1, 2, 3].medianList;    // 2.0
  /// [1, 2, 3, 4].medianList; // 2.5
  /// <int>[].medianList;      // 0.0
  /// ```
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
  ///
  /// Usage: use for a quick total instead of a manual `fold(0, ...)` loop.
  /// Check `isNotEmpty` first (or use [fold] directly) when the list may be
  /// empty and you want a `0` fallback instead of an exception.
  ///
  /// Example:
  /// ```dart
  /// [1, 2, 3].sumList; // 6
  /// ```
  ///
  /// Note: does not throw on non-empty lists — `[].sumList` is the only
  /// error case, and it's a [StateError], not a null/type error.
  T get sumList => reduce((a, b) => a + b as T);
}

/// Miscellaneous [List] helpers: keying by a derived value ([toMap]) and
/// position-wise combining with another list ([merge]).
extension ListExtension<T> on List<T> {
  /// Builds a [Map] keyed by each element of this list, with values derived
  /// by calling [f] on that element.
  ///
  /// Usage: use to turn a list into a lookup table in one expression,
  /// instead of a manual `for` loop building up a `Map`.
  ///
  /// Example:
  /// ```dart
  /// ['a', 'bb', 'ccc'].toMap((s) => s.length);
  /// // {'a': 1, 'bb': 2, 'ccc': 3}
  /// ```
  ///
  /// Note: if two elements are `==` to each other, the later one's derived
  /// value overwrites the earlier one's in the resulting [Map] — the same
  /// behavior as inserting both into a `Map` by hand.
  Map<T, E> toMap<E>(E Function(T) f) => {
    for (final item in this) item: f(item)
  };

  /// Combines this list with [mergeList] position by position, preferring
  /// [mergeList]'s value at each index unless it is `null` — in which case
  /// this list's value is kept.
  ///
  /// Usage: use to apply a set of partial overrides onto a base list, e.g.
  /// patching a fixed-size settings list where `null` in the override
  /// means "leave this slot unchanged".
  ///
  /// Example:
  /// ```dart
  /// [1, 2, 3].merge([null, 20, null]); // [1, 20, 3]
  /// [1, 2].merge([10, 20, 30]);        // [10, 20, 30]
  /// ```
  ///
  /// Note: if [T] is itself nullable (e.g. `List<String?>`), a genuine
  /// `null` value in [mergeList] can't be distinguished from "no override at
  /// this index" — it silently falls back to this list's value instead of
  /// applying the intended `null`. The result length is the longer of the
  /// two lists; if [mergeList] is `null`, this list is returned unchanged,
  /// and if this list is empty, [mergeList] is returned unchanged.
  List<T> merge(List<T>? mergeList) {
    if (mergeList == null) return this;
    if (isEmpty) return mergeList;

    return List.generate(math.max(length, mergeList.length), (index) {
      if (index < length) {
        final currentValue = this[index];
        final otherValue = index < mergeList.length ? mergeList[index] : null;
        return otherValue ?? currentValue;
      }

      return mergeList[index];
    });
  }
}

extension ListEqualityExtension<T extends Comparable> on List<T> {
  bool isEqualTo(List<T> other) {
    if (other.length != length) {
      return false;
    }
    for (var i = 0; i < length; i++) {
      if (other[i] != this[i]) {
        return false;
      }
    }
    return true;
  }

  List<T> sorted({bool descending = false}) => descending
      ? ([...this]..sort(descendingComparator))
      : ([...this]..sort(ascendingComparator));

  int ascendingComparator(T lhs, T rhs) => lhs.compareTo(rhs);

  int descendingComparator(T lhs, T rhs) => rhs.compareTo(lhs);
}