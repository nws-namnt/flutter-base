import '../entities/entities.dart' show EffectEntity;

extension TextTransformation on String {
  List<EffectEntity> get splittedLetters => split('')
      .indexed
      .map((e) => EffectEntity(index: e.$1, text: e.$2))
      .toList(); // split each characters

  List<EffectEntity> get splittedWords {
    if (isEmpty) return [];

    // Split text keeping spaces with words
    final List<String> words = [];
    final RegExp pattern = RegExp(r'\S+\s*');

    for (final match in pattern.allMatches(this)) {
      words.add(match.group(0)!);
    }

    return words.indexed
        .map((e) => EffectEntity(index: e.$1, text: e.$2))
        .toList();
  }
}
