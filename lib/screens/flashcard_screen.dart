import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../widgets/flashcard.dart';
import '../theme/app_theme.dart';
import 'test_screen.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _showDetail = false;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.5);
  }

  void _handleCardTap() {
    setState(() {
      _showDetail = true;
    });
  }

  Future<void> _handleNext(WordProvider provider) async {
    // Mark current word as learned
    final currentWord = provider.todaysWords[_currentIndex];
    await provider.markWordAsLearned(currentWord.id);

    if (_currentIndex < provider.todaysWords.length - 1) {
      setState(() {
        _currentIndex++;
        _showDetail = false;
      });
    } else {
      // Completed daily session
      if (mounted) _showCompletionDialog(provider.todaysWords);
    }
  }

  void _showCompletionDialog(List<Word> sessionWords) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          "MashaAllah!",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "You have completed today's lesson. To extend your streak, complete the quiz!",
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to Home
            },
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              // Mark lesson completed before starting test
              context.read<WordProvider>().markLessonCompleted();

              Navigator.of(context).pop(); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TestScreen(testWords: sessionWords, testType: "Daily"),
                ),
              );
            },
            child: const Text("Start Quiz"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordProvider>(
      builder: (context, provider, child) {
        final words = provider.todaysWords;

        if (words.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Daily Session")),
            body: Center(
              child: Text(
                "All caught up for today! Come back tomorrow.",
                style: GoogleFonts.outfit(fontSize: 18),
              ),
            ),
          );
        }

        final currentWord = words[_currentIndex];
        final progress = (_currentIndex + 1) / words.length;

        return Scaffold(
          appBar: _showDetail
              ? null
              : AppBar(
                  title: Text("Word ${_currentIndex + 1} of ${words.length}"),
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
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showDetail
                ? _buildDetailView(context, currentWord, provider, words.length)
                : _buildCardView(context, currentWord),
          ),
        );
      },
    );
  }

  Widget _buildCardView(BuildContext context, Word word) {
    return Container(
      key: const ValueKey('card_view'),
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Flashcard(word: word, onTap: _handleCardTap),
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    Word word,
    WordProvider provider,
    int totalWords,
  ) {
    return Scaffold(
      key: const ValueKey('detail_view'),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _showDetail = false),
        ),
        title: Text(
          "Word Details",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic Header
                  Hero(
                    tag: 'arabic_${word.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        word.arabic,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Primary Meaning
                  Text(
                    word.normalMeaning,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quranic Meaning Section
                  _buildSectionTitle(context, "Qur'anic Context"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Text(
                      word.quranicMeaning,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Verse Section
                  _buildSectionTitle(context, "Example Verse"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          word.exampleVerse,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            height: 1.8,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          word.verseTranslation,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "(${word.verseReference})",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Synonyms
                  if (word.synonyms.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, "Related Words"),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: word.synonyms
                          .map(
                            (s) => Chip(
                              label: Text(s, style: GoogleFonts.outfit()),
                              backgroundColor: Colors.grey[100],
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 100), // Bottom padding for button
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // TTS Button (Disabled look but present)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Disabled as requested "shouldn't work just for now"
                    },
                    icon: Icon(
                      Icons.volume_up_rounded,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Next Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleNext(provider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentIndex < totalWords - 1
                          ? "Next Word"
                          : "Finish Lesson",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Center(
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}
