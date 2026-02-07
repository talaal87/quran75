import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/word.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAVtqkVTRvjSozGKGACDuqeHDaI3bOCYVI';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  /// Generate detailed word information for a batch of Arabic words
  Future<List<Word>> generateWordDetails(
    List<String> arabicWords,
    int startId,
  ) async {
    final List<Word> words = [];

    // Process in batches of 10 to avoid token limits
    const batchSize = 10;
    for (int i = 0; i < arabicWords.length; i += batchSize) {
      final batch = arabicWords.skip(i).take(batchSize).toList();
      final batchWords = await _generateBatch(batch, startId + i);
      words.addAll(batchWords);

      // Small delay between batches to avoid rate limiting
      if (i + batchSize < arabicWords.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    return words;
  }

  Future<List<Word>> _generateBatch(
    List<String> arabicWords,
    int startId,
  ) async {
    final prompt =
        '''
You are an expert in Qur'anic Arabic and Urdu. Generate detailed learning information in URDU for these Arabic words.

Words: ${arabicWords.join(', ')}

For EACH word, provide a JSON object with EXACTLY these fields:
- arabic: the original Arabic word exactly as given
- normalMeaning: simple Urdu meaning (ایک سے تین الفاظ) - e.g. "یہ (مذکر)" or "بے حد رحم والا"
- quranicMeaning: deeper Qur'anic/theological meaning in URDU (ایک جملہ)
- exampleVerse: a short Arabic verse segment containing or related to this word (3-8 words)
- verseTranslation: URDU translation of the verse segment (اردو ترجمہ)
- verseReference: Surah name and verse number (e.g., "Al-Baqarah 2:1") in English
- frequency: estimated frequency in Quran (number between 1-3000)
- synonyms: list of 0-3 related Arabic words (can be empty array)
- synonymExplanation: brief explanation in URDU of differences between synonyms (null if no synonyms)

Return ONLY a valid JSON array with no extra text. Everything except 'arabic' and 'verseReference' should be in URDU.
''';

    try {
      final content = [Content.text(prompt)];
      GenerateContentResponse response;

      try {
        response = await _model.generateContent(content);
      } catch (e) {
        if (e.toString().contains('not found') ||
            e.toString().contains('v1beta')) {
          // Fallback to gemini-1.5-pro if flash fails with this specific error
          print('Switching to gemini-1.5-pro due to error: $e');
          final proModel = GenerativeModel(
            model: 'gemini-1.5-pro',
            apiKey: _apiKey,
          );
          response = await proModel.generateContent(content);
        } else {
          rethrow;
        }
      }
      final text = response.text ?? '';

      // Extract JSON from response (may have markdown code blocks)
      String jsonText = text;
      if (text.contains('```json')) {
        jsonText = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        jsonText = text.split('```')[1].split('```')[0].trim();
      }

      final List<dynamic> wordDataList = jsonDecode(jsonText);

      final List<Word> words = [];
      for (int i = 0; i < wordDataList.length; i++) {
        final data = wordDataList[i] as Map<String, dynamic>;
        words.add(
          Word(
            id: startId + i,
            arabic: data['arabic'] ?? arabicWords[i],
            normalMeaning: data['normalMeaning'] ?? 'Unknown',
            quranicMeaning: data['quranicMeaning'] ?? '',
            exampleVerse: data['exampleVerse'] ?? '',
            verseTranslation: data['verseTranslation'] ?? '',
            verseReference: data['verseReference'] ?? '',
            frequency: (data['frequency'] as num?)?.toInt() ?? 1,
            synonyms:
                (data['synonyms'] as List<dynamic>?)?.cast<String>() ?? [],
            synonymExplanation: data['synonymExplanation'] as String?,
          ),
        );
      }
      return words;
    } catch (e) {
      // Fallback: create basic words with just the Arabic
      print('Gemini error: $e');
      return arabicWords
          .asMap()
          .entries
          .map(
            (entry) => Word(
              id: startId + entry.key,
              arabic: entry.value,
              normalMeaning: 'Meaning pending',
              quranicMeaning: 'Details will be generated',
              exampleVerse: '',
              verseTranslation: '',
              verseReference: '',
              frequency: 1,
              synonyms: [],
              synonymExplanation: null,
            ),
          )
          .toList();
    }
  }

  /// Generate a single word's details (for on-demand generation)
  Future<Word?> generateSingleWordDetail(String arabicWord, int id) async {
    final words = await _generateBatch([arabicWord], id);
    return words.isNotEmpty ? words.first : null;
  }

  /// Generate test questions for a set of words
  Future<List<Map<String, dynamic>>> generateTestQuestions(
    List<Word> words,
  ) async {
    final wordList = words
        .map((w) => '${w.arabic} (${w.normalMeaning})')
        .join(', ');

    final prompt =
        '''
Generate multiple choice test questions in URDU for these Qur'anic Arabic words:
$wordList

For each word, create a question with:
1. The Arabic word as the question stem
2. The correct URDU meaning
3. Three plausible but incorrect URDU options

Return as JSON array:
[{"arabic":"الله","question":"لفظ 'الله' کا صحیح معنی کیا ہے؟","correctAnswer":"اللہ / معبودِ برحق","wrongAnswers":["رسول","فرشتہ","کتاب"]}]

Return ONLY valid JSON, no extra text. Everything except the 'arabic' field should be in URDU.
''';

    try {
      final content = [Content.text(prompt)];
      GenerateContentResponse response;

      try {
        response = await _model.generateContent(content);
      } catch (e) {
        if (e.toString().contains('not found') ||
            e.toString().contains('v1beta')) {
          print('Switching to gemini-1.5-pro for tests due to error: $e');
          final proModel = GenerativeModel(
            model: 'gemini-1.5-pro',
            apiKey: _apiKey,
          );
          response = await proModel.generateContent(content);
        } else {
          rethrow;
        }
      }

      final text = response.text ?? '[]';

      String jsonText = text;
      if (text.contains('```json')) {
        jsonText = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        jsonText = text.split('```')[1].split('```')[0].trim();
      }

      return (jsonDecode(jsonText) as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error generating test questions: $e');
      return [];
    }
  }
}
