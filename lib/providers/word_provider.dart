import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../models/progress.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';
import '../data/pregenerated_words.dart';
import '../data/raw_words.dart';

class WordProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final GeminiService _gemini = GeminiService();

  List<Word> _allWords = [];
  List<Word> _todaysWords = [];
  List<Word> _sessionWords = []; // Words from current lesson session
  UserProgress _progress = UserProgress();
  bool _isLoading = true;
  bool _isGenerating = false;
  int _generationProgress = 0;

  List<Word> get allWords => _allWords;
  List<Word> get todaysWords => _todaysWords;
  List<Word> get sessionWords => _sessionWords;
  UserProgress get progress => _progress;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  int get generationProgress => _generationProgress;

  List<Word> get learnedWords => _allWords.where((w) => w.isLearned).toList();

  /// Check if user can start today's lesson
  bool get canStartLesson => !_progress.isLessonCompletedToday;

  /// Check if today is complete (lesson + test done)
  bool get isTodayComplete => _progress.isTodayComplete;

  /// Get remaining words count
  int get remainingWords => _allWords.where((w) => !w.isLearned).length;

  /// Get completion percentage
  double get completionPercent => (_progress.wordsLearned / 500.0) * 100;

  WordProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    // Load cached words first
    _allWords = await _storage.loadWords();

    // Load progress
    final progressJson = await _storage.loadString('user_progress');
    if (progressJson != null) {
      try {
        _progress = UserProgress.fromJson(jsonDecode(progressJson));
      } catch (e) {
        _progress = UserProgress();
      }
    }

    // If no cached words, use pre-generated data
    if (_allWords.isEmpty) {
      _allWords = _initializeAllWords();
      await _storage.saveWords(_allWords);
    }

    // Reset daily flags if new day
    _checkAndResetDailyProgress();

    _prepareDailySession();
    _isLoading = false;
    notifyListeners();

    // Check if we need to generate more words in background
    final incompleteWords = _allWords
        .where(
          (w) => w.quranicMeaning.isEmpty || w.quranicMeaning.contains('...'),
        )
        .toList();

    if (incompleteWords.isNotEmpty) {
      _generateMissingWordsInBackground(incompleteWords);
    }
  }

  /// Check if it's a new day and reset daily progress flags
  void _checkAndResetDailyProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_progress.lastLessonDate != null) {
      final lastLesson = DateTime(
        _progress.lastLessonDate!.year,
        _progress.lastLessonDate!.month,
        _progress.lastLessonDate!.day,
      );

      if (lastLesson != today) {
        // New day - reset today's word count
        _progress.todayWordsLearned = 0;
      }
    }
  }

  /// Initialize all words using pre-generated data + placeholders for rest
  List<Word> _initializeAllWords() {
    final List<Word> words = [];

    // Map pre-generated words by their Arabic text for quick lookup
    final Map<String, Word> pregenMap = {
      for (var w in kPreGeneratedWords) w.arabic: w,
    };

    for (int i = 0; i < kRawArabicWords.length; i++) {
      final arabic = kRawArabicWords[i];
      if (pregenMap.containsKey(arabic)) {
        final pregen = pregenMap[arabic]!;
        // Use the pregen data but ENSURE the ID matches the raw index
        words.add(
          Word(
            id: i,
            arabic: pregen.arabic,
            normalMeaning: pregen.normalMeaning,
            quranicMeaning: pregen.quranicMeaning,
            exampleVerse: pregen.exampleVerse,
            verseTranslation: pregen.verseTranslation,
            verseReference: pregen.verseReference,
            frequency: pregen.frequency,
            synonyms: pregen.synonyms,
            synonymExplanation: pregen.synonymExplanation,
          ),
        );
      } else {
        words.add(
          Word(
            id: i,
            arabic: arabic,
            normalMeaning: _getQuickMeaning(arabic),
            quranicMeaning: '',
            exampleVerse: '',
            verseTranslation: '',
            verseReference: '',
            frequency: 1,
            synonyms: [],
            synonymExplanation: null,
          ),
        );
      }
    }

    return words;
  }

  /// Quick lookup table for common words (Urdu meanings)
  String _getQuickMeaning(String arabic) {
    const quickMeanings = {
      'لَنْ': 'کبھی نہیں (مستقبل)',
      'لَمْ': 'نہیں (ماضی)',
      'مَا': 'کیا/نہیں',
      'لَيْسَ': 'نہیں ہے',
      'بَلَیٰ': 'ہاں بے شک',
      'غَيْر': 'کے سوا',
      'دُونَ': 'بغیر/سوا',
      'نَعَمْ': 'ہاں',
      'ہُ': 'اس کو (لاحقہ)',
      'هُمْ': 'ان کو (لاحقہ)',
      'كُمْ': 'تم سب کو (لاحقہ)',
      'نَا': 'ہم کو (لاحقہ)',
      'فَوْقَ': 'اوپر',
      'تَحْتَ': 'نیچے',
      'خَلْف': 'پیچھے',
      'أَمَامَ': 'سامنے',
      'وَرَاءَ': 'پیچھے',
      'يَمِين': 'دائیں',
      'شِمَال': 'بائیں',
      'بَيْنَ': 'درمیان',
      'حَوْلَ': 'ارد گرد',
      'حَيْثُ': 'جہاں',
      'ثُمَّ': 'پھر',
      'مَنْ': 'کون',
      'أَيْنَ': 'کہاں',
      'كَيْفَ': 'کیسے',
      'كَمْ': 'کتنے',
      'هَلْ': 'کیا؟',
      'مَاذَا': 'کیا',
      'قَبْلَ': 'پہلے',
      'بَعْدَ': 'بعد',
      'إِذَا': 'جب',
      'فَ': 'پس/تو',
      'بَلْ': 'بلکہ',
      'عِندَ': 'پاس',
      'بِ': 'کے ساتھ',
      'عَنْ': 'سے/کی طرف سے',
      'فِي': 'میں',
      'لِ': 'کے لیے',
      'مِنْ': 'سے',
      'إِلَى': 'کی طرف',
      'حَتَّى': 'یہاں تک کہ',
      'عَلَى': 'پر',
      'مَعَ': 'کے ساتھ',
      'وَ': 'اور',
      'قَدْ': 'بے شک/پہلے ہی',
      'سَوْفَ': 'گا (مستقبل)',
      'أَمْ': 'یا',
      'أَوْ': 'یا',
      'بَعْض': 'کچھ',
      'كُلّ': 'ہر/سب',
      'إِنَّ': 'بے شک',
      'أَنَّ': 'کہ',
      'لَكِنَّ': 'لیکن',
      'لَعَلَّ': 'شاید',
      'لَوْ': 'اگر',
    };
    return quickMeanings[arabic] ?? 'Word';
  }

  /// Generate missing word details using Gemini AI in background
  Future<void> _generateMissingWordsInBackground(
    List<Word> incompleteWords,
  ) async {
    if (_isGenerating) return;

    _isGenerating = true;
    notifyListeners();

    const batchSize = 10;
    int processed = 0;

    for (int i = 0; i < incompleteWords.length; i += batchSize) {
      try {
        final batch = incompleteWords.skip(i).take(batchSize).toList();
        final arabicWords = batch.map((w) => w.arabic).toList();
        final startId = batch.first.id;

        final generatedWords = await _gemini.generateWordDetails(
          arabicWords,
          startId,
        );

        // Merge generated data
        for (final newWord in generatedWords) {
          final existingIndex = _allWords.indexWhere(
            (w) => w.arabic == newWord.arabic,
          );
          if (existingIndex != -1) {
            final existing = _allWords[existingIndex];
            _allWords[existingIndex] = Word(
              id: existing.id,
              arabic: newWord.arabic,
              normalMeaning: newWord.normalMeaning.isNotEmpty
                  ? newWord.normalMeaning
                  : existing.normalMeaning,
              quranicMeaning: newWord.quranicMeaning,
              exampleVerse: newWord.exampleVerse,
              verseTranslation: newWord.verseTranslation,
              verseReference: newWord.verseReference,
              frequency: newWord.frequency,
              synonyms: newWord.synonyms,
              synonymExplanation: newWord.synonymExplanation,
              isLearned: existing.isLearned,
              learnedAt: existing.learnedAt,
              wrongCount: existing.wrongCount,
            );
          }
        }

        processed += batch.length;
        _generationProgress = (processed / incompleteWords.length * 100)
            .round();

        await _storage.saveWords(_allWords);
        notifyListeners();

        // Rate limiting delay
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('Background generation error: $e');
      }
    }

    _isGenerating = false;
    _generationProgress = 100;
    await _storage.saveWords(_allWords);
    notifyListeners();
  }

  /// Get complete word details, generating if needed
  Future<Word> getWordDetails(int wordId) async {
    final index = _allWords.indexWhere((w) => w.id == wordId);
    if (index == -1) return _allWords.first;

    final word = _allWords[index];

    // If word has complete details, return it
    if (word.quranicMeaning.isNotEmpty &&
        !word.quranicMeaning.contains('...')) {
      return word;
    }

    // Generate details on demand
    final newWord = await _gemini.generateSingleWordDetail(
      word.arabic,
      word.id,
    );
    if (newWord != null) {
      _allWords[index] = Word(
        id: word.id,
        arabic: newWord.arabic,
        normalMeaning: newWord.normalMeaning.isNotEmpty
            ? newWord.normalMeaning
            : word.normalMeaning,
        quranicMeaning: newWord.quranicMeaning,
        exampleVerse: newWord.exampleVerse,
        verseTranslation: newWord.verseTranslation,
        verseReference: newWord.verseReference,
        frequency: newWord.frequency,
        synonyms: newWord.synonyms,
        synonymExplanation: newWord.synonymExplanation,
        isLearned: word.isLearned,
        learnedAt: word.learnedAt,
        wrongCount: word.wrongCount,
      );
      await _storage.saveWords(_allWords);
      notifyListeners();
      return _allWords[index];
    }

    return word;
  }

  void _prepareDailySession() {
    // If lesson already completed today, empty the session
    if (_progress.isLessonCompletedToday) {
      _todaysWords = [];
      return;
    }

    final unlearned = _allWords.where((w) => !w.isLearned).toList();
    _todaysWords = unlearned.take(5).toList();
    _sessionWords = List.from(_todaysWords);
  }

  Future<void> markWordAsLearned(int wordId) async {
    final index = _allWords.indexWhere((w) => w.id == wordId);
    if (index != -1) {
      _allWords[index].isLearned = true;
      _allWords[index].learnedAt = DateTime.now();
      _progress.wordsLearned = _allWords.where((w) => w.isLearned).length;
      _progress.todayWordsLearned++;

      _updateProgressStats();
      await _saveData();
      notifyListeners();
    }
  }

  /// Mark today's lesson as completed
  Future<void> markLessonCompleted() async {
    _progress.lastLessonDate = DateTime.now();
    await _saveData();
    notifyListeners();
  }

  /// Mark today's test as completed and update streak
  Future<void> markTestCompleted({required bool passed}) async {
    _progress.lastTestDate = DateTime.now();
    _progress.totalTestsTaken++;
    if (passed) {
      _progress.totalTestsPassed++;
    }

    // Update streak only when both lesson AND test are done
    _updateStreakOnTestComplete();

    await _saveData();
    _prepareDailySession(); // Refresh today's words
    notifyListeners();
  }

  /// Update streak when test is completed
  void _updateStreakOnTestComplete() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_progress.lastStudyDate == null) {
      _progress.dailyStreak = 1;
      _progress.lastStudyDate = today;
    } else {
      final lastDate = _progress.lastStudyDate!;
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final yesterday = today.subtract(const Duration(days: 1));

      if (lastDay == today) {
        // Already counted today
      } else if (lastDay == yesterday) {
        _progress.dailyStreak++;
        _progress.lastStudyDate = today;
      } else {
        // Streak broken - reset
        _progress.dailyStreak = 1;
        _progress.lastStudyDate = today;
      }
    }
  }

  Future<void> markWordAsWeak(int wordId) async {
    final index = _allWords.indexWhere((w) => w.id == wordId);
    if (index != -1) {
      _allWords[index].wrongCount++;
      if (!_progress.weakWordIds.contains(wordId)) {
        _progress.weakWordIds.add(wordId);
      }
      await _saveData();
      notifyListeners();
    }
  }

  void _updateProgressStats() {
    double percentage = (_progress.wordsLearned / 500.0) * 75.0;
    if (percentage > 75.0) percentage = 75.0;
    _progress.quranCoverage = percentage;
  }

  Future<void> _saveData() async {
    await _storage.saveWords(_allWords);
    await _storage.saveString('user_progress', jsonEncode(_progress.toJson()));
  }

  Future<void> resetAll() async {
    await _storage.clearAll();
    _allWords = _initializeAllWords();
    _progress = UserProgress();
    await _storage.saveWords(_allWords);
    _prepareDailySession();
    notifyListeners();
  }
}
