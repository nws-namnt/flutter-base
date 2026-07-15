import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import '../../firebase/dev/firebase_options.dart' as firebase_dev show DefaultFirebaseOptions;
import '../../firebase/prod/firebase_options.dart' as firebase_prod show DefaultFirebaseOptions;
import '../../firebase/uat/firebase_options.dart' as firebase_uat show DefaultFirebaseOptions;

const _snakeCaseSeparator = '_';
const _paramCaseSeparator = '-';
const _spaceSeparator = ' ';

final _upperAlphaRegex = RegExp(r'[_-\sA-Z]');

final _symbolSet = {_snakeCaseSeparator, _paramCaseSeparator, _spaceSeparator};

/// String helpers used during app startup to resolve the active flavor.
///
/// Applied to `PackageInfo.packageName` in `main()`.
extension NullableStringExtension on String? {
  /// `true` when this string is non-null and non-empty.
  ///
  /// Usage: use as a single null-and-empty check instead of writing
  /// `value != null && value.isNotEmpty` at every call site — e.g. deciding
  /// whether an optional `semanticsLabel`/`tooltip` should be applied (see
  /// `ActionWidget`'s `_Wrap`).
  ///
  /// Example:
  /// ```dart
  /// (null as String?).isValidate; // false
  /// ''.isValidate;                // false
  /// 'hi'.isValidate;              // true
  /// ```
  bool get isValidate => this != null && this!.isNotEmpty;

  /// Derives the active flavor from the bundle ID / package name suffix.
  ///
  /// - Ends with `.dev` → `'dev'`
  /// - Ends with `.uat` → `'uat'`
  /// - Otherwise → `'prod'`
  ///
  /// Usage: call on `PackageInfo.packageName` during app startup, before
  /// [Firebase.initializeApp], to pick the right per-flavor config.
  ///
  /// Example:
  /// ```dart
  /// 'com.example.app.dev'.flavor;  // 'dev'
  /// 'com.example.app.uat'.flavor;  // 'uat'
  /// 'com.example.app'.flavor;      // 'prod'
  /// null.flavor;                   // 'dev'
  /// ```
  ///
  /// Note: a `null` receiver defaults to `'dev'`, not `'prod'` — this
  /// favors safe local development over accidentally targeting production
  /// when the package name can't be read yet.
  String get flavor {
    if (this == null) return 'dev';
    if (this!.endsWith('.dev')) return 'dev';
    if (this!.endsWith('.uat')) return 'uat';
    return 'prod';
  }

  /// Returns the [FirebaseOptions] that match this string's [flavor].
  ///
  /// Used in `main()` to call `Firebase.initializeApp(options: flavor.firebaseOptions)`.
  ///
  /// Usage: call on `PackageInfo.packageName` right where
  /// [Firebase.initializeApp] is invoked, so the correct
  /// `firebase_options.dart` (dev/uat/prod) is selected automatically.
  ///
  /// Example:
  /// ```dart
  /// await Firebase.initializeApp(
  ///   options: packageInfo.packageName.firebaseOptions,
  /// );
  /// ```
  FirebaseOptions get firebaseOptions => switch (flavor) {
    'dev' => firebase_dev.DefaultFirebaseOptions.currentPlatform,
    'uat' => firebase_uat.DefaultFirebaseOptions.currentPlatform,
    _ => firebase_prod.DefaultFirebaseOptions.currentPlatform,
  };
}

extension StringExtension on String {
  /// Splits the string into a list of words, using either explicit
  /// separators (space, `_`, `-`) or a lowercase-to-uppercase transition as
  /// the word boundary.
  ///
  /// Usage: this is the shared building block behind every case-conversion
  /// getter below ([camelCase], [pascalCase], [snakeCase], [paramCase],
  /// [constantCase], [titleCase], [sentenceCase]) — call it directly only
  /// if you need the raw word list itself.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.words;   // ['hello', 'world']
  /// 'helloWorld'.words;    // ['hello', 'World']
  /// 'hello_world'.words;   // ['hello', 'world']
  /// 'HELLO_WORLD'.words;   // ['HELLO', 'WORLD']
  /// ```
  ///
  /// Note: when the whole string is already all-uppercase (`isAllCaps`),
  /// uppercase letters no longer count as word boundaries — otherwise
  /// `'HELLO_WORLD'` would be split letter by letter instead of into two
  /// words.
  List<String> get words {
    final sb = StringBuffer();
    final words = <String>[];
    final isAllCaps = toUpperCase() == this;

    for (int i = 0; i < length; i++) {
      final char = this[i];
      final nextChar = i + 1 == length ? null : this[i + 1];

      if (_symbolSet.contains(char)) {
        continue;
      }

      sb.write(char);

      final isEndOfWord =
          nextChar == null ||
              (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
              _symbolSet.contains(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }

  /// Checks if the string is in all uppercase.
  ///
  /// Usage: use for a quick uppercase check, e.g. validating a constant-case
  /// identifier before further processing.
  ///
  /// Example:
  /// ```dart
  /// 'HELLO'.isUpperCase; // true
  /// 'Hello'.isUpperCase; // false
  /// ```
  ///
  /// Note: an empty string is considered uppercase (`''.isUpperCase` is
  /// `true`), since `''.toUpperCase() == ''`.
  bool get isUpperCase => toUpperCase() == this;

  /// Checks if the string is in all lowercase.
  ///
  /// Usage: use for a quick lowercase check, e.g. validating a slug/param
  /// before further processing.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.isLowerCase; // true
  /// 'Hello'.isLowerCase; // false
  /// ```
  ///
  /// Note: an empty string is considered lowercase (`''.isLowerCase` is
  /// `true`), since `''.toLowerCase() == ''`.
  bool get isLowerCase => toLowerCase() == this;

  /// Converts the string to camel case (`helloWorld`).
  ///
  /// Usage: use for variable/parameter names generated from user input or
  /// external data, e.g. turning a display label into a Dart-friendly
  /// identifier.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.camelCase; // 'helloWorld'
  /// 'Hello-World'.camelCase; // 'helloWorld'
  /// ```
  String get camelCase {
    final wordList = words.map((word) => word.capitalize).toList();
    if (wordList.isNotEmpty) {
      wordList[0] = wordList.first.toLowerCase();
    }

    return wordList.join();
  }

  /// Converts the string to pascal case (`HelloWorld`).
  ///
  /// Usage: use for generating class/type names from user input or
  /// external data.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.pascalCase; // 'HelloWorld'
  /// ```
  String get pascalCase => words.map((word) => word.capitalize).join();

  /// Capitalizes the first letter of the string and lowercases the rest.
  ///
  /// Usage: use for display strings where only the first letter should be
  /// uppercase, or as the building block other case getters use per word.
  ///
  /// Example:
  /// ```dart
  /// 'hELLO'.capitalize; // 'Hello'
  /// ''.capitalize;      // ''
  /// ```
  ///
  /// Note: unlike a plain "uppercase the first character" helper, this
  /// also *lowercases* every character after the first — `'HELLO'` becomes
  /// `'Hello'`, not `'HELLO'`.
  String get capitalize {
    if (isEmpty) return this;
    final firstRune = runes.first;
    final restRunes = runes.skip(1);

    return String.fromCharCode(firstRune).toUpperCase() +
        restRunes.map((rune) => String.fromCharCode(rune).toLowerCase()).join();
  }

  /// Converts the string to constant case (`HELLO_WORLD`).
  ///
  /// Usage: use for generating `static const` field names from user input
  /// or external data.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.constantCase; // 'HELLO_WORLD'
  /// ```
  String get constantCase => words.uppercase.join(_snakeCaseSeparator);

  /// Converts the string to snake case (`hello_world`).
  ///
  /// Usage: use for generating file/variable names or JSON keys from user
  /// input or external data.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.snakeCase; // 'hello_world'
  /// ```
  String get snakeCase => words.lowercase.join(_snakeCaseSeparator);

  /// Converts the string to param case (`hello-world`).
  ///
  /// Usage: use for generating URL slugs / route path segments from user
  /// input or external data.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.paramCase; // 'hello-world'
  /// ```
  String get paramCase => words.lowercase.join(_paramCaseSeparator);

  /// Converts the string to title case (`Hello World`).
  ///
  /// Usage: use for display strings where every word should start with a
  /// capital letter, e.g. section headings built from a category name.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.titleCase; // 'Hello World'
  /// ```
  String get titleCase =>
      words.map((word) => word.capitalize).join(_spaceSeparator);

  /// Converts the string to sentence case (`Hello world`).
  ///
  /// Usage: use for display strings where only the first word should be
  /// capitalized, e.g. rendering a snake_case/constant enum name as
  /// readable prose.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.sentenceCase; // 'Hello world'
  /// ```
  ///
  /// Note: unlike [titleCase], only the *first* word is run through
  /// [capitalize] — the remaining words keep whatever casing [words]
  /// produced for them, they are not forced to lowercase.
  String get sentenceCase {
    final wordList = [...words];
    if (wordList.isEmpty) return this;

    wordList[0] = wordList.first.capitalize;

    return wordList.join(_spaceSeparator);
  }
}

/// Bulk case-conversion helpers for a [List] of [String], used to lowercase
/// or uppercase every element before joining (see [StringExtension.snakeCase]
/// / [StringExtension.constantCase], which both call these on [words]).
extension ListStringExt on List<String> {
  /// Converts all strings in the list to lowercase.
  ///
  /// Usage: use before joining a word list into a lower-cased identifier,
  /// e.g. `words.lowercase.join('_')` for [StringExtension.snakeCase].
  ///
  /// Example:
  /// ```dart
  /// ['Hello', 'WORLD'].lowercase; // ['hello', 'world']
  /// ```
  List<String> get lowercase => map((e) => e.toLowerCase()).toList();

  /// Converts all strings in the list to uppercase.
  ///
  /// Usage: use before joining a word list into an upper-cased identifier,
  /// e.g. `words.uppercase.join('_')` for [StringExtension.constantCase].
  ///
  /// Example:
  /// ```dart
  /// ['Hello', 'world'].uppercase; // ['HELLO', 'WORLD']
  /// ```
  List<String> get uppercase => map((e) => e.toUpperCase()).toList();
}
