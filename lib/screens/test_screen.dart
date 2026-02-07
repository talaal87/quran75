import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../theme/app_theme.dart';

class TestScreen extends StatefulWidget {
  final List<Word> testWords;
  final String testType; // Daily, Weekly, Monthly

  const TestScreen({
    super.key,
    required this.testWords,
    required this.testType,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _isAnswered = false;
  late List<TestQuestion> _questions;
  final Random _random = Random();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    final provider = context.read<WordProvider>();
    final allWords = provider.allWords;

    _questions = widget.testWords.map((word) {
      // Get plausible wrong answers from other words
      final wrongOptions = _getPlausibleWrongAnswers(word, allWords);

      final options = [word.normalMeaning, ...wrongOptions];
      options.shuffle(_random);

      return TestQuestion(
        word: word,
        question: word.arabic,
        options: options,
        correctIndex: options.indexOf(word.normalMeaning),
      );
    }).toList();
  }

  List<String> _getPlausibleWrongAnswers(
    Word correctWord,
    List<Word> allWords,
  ) {
    // Filter out words similar to correct word
    final candidates = allWords
        .where(
          (w) =>
              w.id != correctWord.id &&
              w.normalMeaning != correctWord.normalMeaning &&
              w.normalMeaning.isNotEmpty &&
              !w.normalMeaning.contains('...'),
        )
        .toList();

    // Shuffle and take 3
    candidates.shuffle(_random);

    final wrongAnswers = candidates
        .take(3)
        .map((w) => w.normalMeaning)
        .toList();

    // If we don't have enough, add generic wrong answers
    final fallbacks = [
      'To forgive',
      'To guide',
      'Peace',
      'Book',
      'Prophet',
      'Angel',
      'Light',
      'Truth',
      'Mercy',
      'Knowledge',
    ];

    while (wrongAnswers.length < 3) {
      final fallback = fallbacks[_random.nextInt(fallbacks.length)];
      if (!wrongAnswers.contains(fallback) &&
          fallback != correctWord.normalMeaning) {
        wrongAnswers.add(fallback);
      }
    }

    return wrongAnswers.take(3).toList();
  }

  void _handleOptionSelect(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = index;
      _isAnswered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      } else {
        // Mark word as weak if answered incorrectly
        context.read<WordProvider>().markWordAsWeak(
          _questions[_currentIndex].word.id,
        );
      }
    });

    // Auto proceed after short delay if correct, or wait for manual next if wrong?
    // User prefers manual control usually, or automatic. Let's keep manual "Next" button for clarity.
  }

  void _handleNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswered = false;
      });
    } else {
      _finishTest();
    }
  }

  Future<void> _finishTest() async {
    final passed = (_score / _questions.length) >= 0.6; // 60% pass rate
    await context.read<WordProvider>().markTestCompleted(passed: passed);

    setState(() {
      _isCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildResultScreen();
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.testType} Test",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${_currentIndex + 1}/${_questions.length}",
              style: GoogleFonts.outfit(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Arabic Word Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'arabic_test_${question.word.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        question.question,
                        style: GoogleFonts.amiri(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select the correct meaning",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Options
            ...List.generate(question.options.length, (index) {
              return _buildOptionTile(index, question);
            }),

            const SizedBox(height: 24),

            if (_isAnswered)
              ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? "Next Question"
                      : "See Results",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(int index, TestQuestion question) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.withOpacity(0.2);
    Color textColor = AppTheme.textPrimary;
    IconData? icon;

    if (_isAnswered) {
      if (index == question.correctIndex) {
        bgColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
      } else if (index == _selectedOption) {
        bgColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
      }
    } else if (index == _selectedOption) {
      bgColor = AppTheme.primaryColor.withOpacity(0.1);
      borderColor = AppTheme.primaryColor;
    }

    return GestureDetector(
      onTap: () => _handleOptionSelect(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question.options[index],
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (icon != null)
              Icon(
                icon,
                color: index == question.correctIndex
                    ? Colors.green
                    : Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / _questions.length * 100).round();
    final passed = percentage >= 60;

    return Scaffold(
      backgroundColor: passed ? AppTheme.primaryColor : Colors.orange,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti or bg decoration could go here
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        passed
                            ? Icons.emoji_events_rounded
                            : Icons.replay_rounded,
                        size: 64,
                        color: passed ? AppTheme.primaryColor : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      passed ? "Lesson Complete!" : "Nice Try!",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You scored $_score out of ${_questions.length}",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Stats Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "$percentage%",
                            style: GoogleFonts.outfit(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Accuracy",
                            style: GoogleFonts.outfit(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // The "Cross Button" to close/claim
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close test screen
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: passed ? AppTheme.primaryColor : Colors.orange,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestQuestion {
  final Word word;
  final String question;
  final List<String> options;
  final int correctIndex;

  TestQuestion({
    required this.word,
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}
