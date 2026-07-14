import 'dart:collection' show UnmodifiableListView;

/// Null-safety and immutability helpers for nullable [Iterable]s.
extension IterableExtension<T> on Iterable<T>? {
  /// `true` when this iterable is non-null and has at least one element.
  ///
  /// ```dart
  /// <int>[].isValidated; // false
  /// [1, 2].isValidated;  // true
  /// ```
  bool get isValidated => this != null && this!.isNotEmpty;

  /// An [UnmodifiableListView] wrapping this iterable, or an empty one when
  /// this is `null`.
  ///
  /// ```dart
  /// nullableList.viewModel; // safe read-only view, never null
  /// ```
  UnmodifiableListView get viewModel => UnmodifiableListView(this ?? []);
}

/// Set-like operators (`+`, `-`, `&`) for [Iterable].
///
/// All operators are lazy: no elements are evaluated until the resulting
/// [Iterable] is iterated (e.g. via `toList()` or a `for`-loop).
extension IterableOperationExtension<E> on Iterable<E> {
  /// Returns the elements of this iterable that are not present in [other].
  ///
  /// [other] is converted to a [Set] first so lookups run in O(1), keeping
  /// the overall cost at O(n + m) instead of O(n * m).
  ///
  /// ```dart
  /// [1, 2, 3] - [2]; // (1, 3)
  /// ```
  Iterable<E> operator - (Iterable<E> other) {
    final otherSet = other.toSet();
    return where((e) => !otherSet.contains(e));
  }

  /// Returns this iterable followed by the single element [other].
  ///
  /// ```dart
  /// [1, 2] + 3; // (1, 2, 3)
  /// ```
  Iterable<E> operator +(E other) => followedBy([other]);

  /// Returns this iterable followed by all elements of [other].
  ///
  /// ```dart
  /// [1, 2] & [3, 4]; // (1, 2, 3, 4)
  /// ```
  Iterable<E> operator &(Iterable<E> other) => followedBy(other);

  /// Returns only the elements of this iterable that are [int].
  ///
  /// ```dart
  /// [1, 2.0, 3].listIntType; // (1, 3)
  /// ```
  Iterable<int> get listIntType => whereType<int>();

  /// Returns only the elements of this iterable that are [double].
  ///
  /// ```dart
  /// [1, 2.0, 3].listDoubleType; // (2.0)
  /// ```
  Iterable<double> get listDoubleType => whereType<double>();
}