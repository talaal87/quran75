import 'package:quran75/data/raw_words.dart';
import 'package:quran75/data/pregenerated_words.dart';

void main() {
  final pregenArabic = kPreGeneratedWords.map((w) => w.arabic).toSet();
  final missing = kRawArabicWords
      .where((w) => !pregenArabic.contains(w))
      .toList();

  print('Missing words: ${missing.length}');

  for (var m in missing.take(20)) {
    print('Missing: "$m" (Length: ${m.length})');
    final match = kPreGeneratedWords
        .where((w) => w.arabic.contains(m) || m.contains(w.arabic))
        .firstOrNull;
    if (match != null) {
      print(
        '  Potential match in pregen: "${match.arabic}" (Length: ${match.arabic.length})',
      );
    }
  }
}
