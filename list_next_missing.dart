import 'package:quran75/data/raw_words.dart';
import 'package:quran75/data/pregenerated_words.dart';

void main() {
  final pregenArabic = kPreGeneratedWords.map((w) => w.arabic).toSet();
  final missing = kRawArabicWords
      .where((w) => !pregenArabic.contains(w))
      .toList();

  print('Missing words: ${missing.length}');
  for (int i = 0; i < missing.length; i++) {
    print('"$i": "${missing[i]}",');
  }
}
