/// Merge (`+`) and key-based subtraction (`-`) operators for [Map].
extension MapExtension<K, V> on Map<K, V> {
  /// Returns a new [Map] containing all entries of this map merged with
  /// [other]. Entries in [other] overwrite entries with the same key.
  ///
  /// ```dart
  /// {'a': 1, 'b': 2} + {'b': 20, 'c': 3}; // {'a': 1, 'b': 20, 'c': 3}
  /// ```
  Map<K, V> operator + (Map<K, V> other) => {...this}..addAll(other);

  /// Returns a new [Map] with all entries removed whose key exists in
  /// [other]. Values in [other] are not considered.
  ///
  /// ```dart
  /// {'a': 1, 'b': 2} - {'b': 0}; // {'a': 1}
  /// ```
  Map<K, V> operator - (Map<K, V> other) =>
      {...this}..removeWhere((k, _) => other.containsKey(k));

  /// Maps each entry with [f], keeping only the non-null results.
  ///
  /// ```dart
  /// {'a': 1, 'b': 2}.compactMap((e) => e.value.isEven ? e.key : null); // ('b')
  /// ```
  Iterable<E> compactMap<E>(E? Function(MapEntry<K, V>) f) sync* {
    for (final entry in entries) {
      final extracted = f(entry);
      if (extracted != null) yield extracted;
    }
  }
}