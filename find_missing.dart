import 'package:quran75/data/raw_words.dart';
import 'package:quran75/data/pregenerated_words.dart';

void main() {
  final pregenArabic = kPreGeneratedWords.map((w) => w.arabic).toSet();
  final missing = kRawArabicWords
      .where((w) => !pregenArabic.contains(w))
      .toList();

  print('Total raw words: ${kRawArabicWords.length}');
  print('Pregenerated words: ${kPreGeneratedWords.length}');
  print('Missing words: ${missing.length}');
  print('First 10 missing words: ${missing.take(10).toList()}');
}
