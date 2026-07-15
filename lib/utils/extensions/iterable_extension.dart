import 'dart:collection' show UnmodifiableListView;

/// Null-safety and immutability helpers for nullable [Iterable]s.
extension NullableIterableExtension<T> on Iterable<T>? {
  /// `true` when this iterable is non-null and has at least one element.
  ///
  /// Usage: use as a single null-and-empty check instead of writing
  /// `list != null && list.isNotEmpty` at every call site.
  ///
  /// Example:
  /// ```dart
  /// <int>[].isValidated; // false
  /// [1, 2].isValidated;  // true
  /// ```
  bool get isValidated => this != null && this!.isNotEmpty;

  /// An [UnmodifiableListView] wrapping this iterable, or an empty one when
  /// this is `null`.
  ///
  /// Usage: use when exposing an internal, mutable list through a public
  /// getter, so callers can read it but never mutate it directly — and
  /// without having to null-check the source list first.
  ///
  /// Example:
  /// ```dart
  /// nullableList.viewModel; // safe read-only view, never null
  /// ```
  ///
  /// Note: this wraps the *current* elements; it does not deep-copy them,
  /// and it does not observe later mutations of the original nullable list
  /// (a new [viewModel] must be read again to see later changes).
  UnmodifiableListView get viewModel => UnmodifiableListView(this ?? []);
}

/// Set-like operators (`+`, `-`, `&`) for [Iterable].
///
/// All operators are lazy: no elements are evaluated until the resulting
/// [Iterable] is iterated (e.g. via `toList()` or a `for`-loop).
extension IterableExtension<E> on Iterable<E> {
  /// Returns the elements of this iterable that are not present in [other].
  ///
  /// [other] is converted to a [Set] first so lookups run in O(1), keeping
  /// the overall cost at O(n + m) instead of O(n * m).
  ///
  /// Usage: use for a readable "subtract" instead of
  /// `where((e) => !other.contains(e))` inline.
  ///
  /// Example:
  /// ```dart
  /// [1, 2, 3] - [2]; // (1, 3)
  /// ```
  ///
  /// Note: lazy — wrap in `.toList()` if you need to iterate it more than
  /// once or need a concrete [List].
  Iterable<E> operator - (Iterable<E> other) {
    final otherSet = other.toSet();
    return where((e) => !otherSet.contains(e));
  }

  /// Returns this iterable followed by the single element [other].
  ///
  /// Usage: use to append one extra element without wrapping it in a
  /// literal list yourself.
  ///
  /// Example:
  /// ```dart
  /// [1, 2] + 3; // (1, 2, 3)
  /// ```
  Iterable<E> operator +(E other) => followedBy([other]);

  /// Returns this iterable followed by all elements of [other].
  ///
  /// Usage: use as a readable alias for [Iterable.followedBy] when
  /// concatenating two iterables.
  ///
  /// Example:
  /// ```dart
  /// [1, 2] & [3, 4]; // (1, 2, 3, 4)
  /// ```
  Iterable<E> operator &(Iterable<E> other) => followedBy(other);

  /// Returns only the elements of this iterable that are [int].
  ///
  /// Usage: use on a mixed-type numeric iterable to pull out just the
  /// [int] values, e.g. after JSON decoding a heterogeneous `List<num>`.
  ///
  /// Example:
  /// ```dart
  /// [1, 2.0, 3].listIntType; // (1, 3)
  /// ```
  Iterable<int> get listIntType => whereType<int>();

  /// Returns only the elements of this iterable that are [double].
  ///
  /// Usage: use on a mixed-type numeric iterable to pull out just the
  /// [double] values, e.g. after JSON decoding a heterogeneous `List<num>`.
  ///
  /// Example:
  /// ```dart
  /// [1, 2.0, 3].listDoubleType; // (2.0)
  /// ```
  Iterable<double> get listDoubleType => whereType<double>();

  /// Returns a new, sorted [List] built from this iterable's elements.
  ///
  /// Usage: use instead of `[...iterable]..sort()` when you want a single
  /// expression; pass [compare] for a custom order, or omit it to use [E]'s
  /// natural order (requires [E] to be [Comparable]).
  ///
  /// Example:
  /// ```dart
  /// [3, 1, 2].sorted();                       // [1, 2, 3]
  /// ['bb', 'a', 'ccc'].sorted(
  ///   (a, b) => a.length.compareTo(b.length),
  /// ); // ['a', 'bb', 'ccc']
  /// ```
  ///
  /// Note: unlike the other members of this extension, this returns a
  /// concrete, eagerly-sorted [List] rather than a lazy [Iterable] — the
  /// original iterable is left unmodified.
  Iterable<E> sorted([Comparator<E>? compare]) {
    List<E> list = List.of(this);
    list.sort(compare);
    return list;
  }
}
