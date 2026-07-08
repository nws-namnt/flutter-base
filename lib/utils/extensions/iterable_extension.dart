import 'dart:collection' show UnmodifiableListView;

/// Null-safety and immutability helpers for nullable [Iterable]s.
extension IterableExtension<T> on Iterable<T>? {
  /// `true` when this iterable is non-null and has at least one element.
  bool get isValidated => this != null  && this!.isNotEmpty;

  /// An [UnmodifiableListView] wrapping this iterable, or an empty one when
  /// this is `null`.
  UnmodifiableListView get viewModel => UnmodifiableListView(this ?? []);
}