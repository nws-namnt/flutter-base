/// Readable name access for [Enum] values.
extension EnumExtension on Enum {
  /// Returns the enum member's name without its type prefix.
  ///
  /// ```dart
  /// ContentSensitivity.sensitive.value; // 'sensitive'
  /// ```
  String get value => toString().split('.').last;
}