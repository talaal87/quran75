import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../providers/word_provider.dart';
import '../theme/app_theme.dart';
import '../models/word.dart';
import 'word_detail_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "My Progress",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, child) {
          final progress = provider.progress;
          final learnedCount = progress.wordsLearned;
          final totalWords = 500;
          final remaining = totalWords - learnedCount;
          final percent = provider.progress.quranCoverage;

          final learned = provider.learnedWords;
          final weakWords =
              provider.allWords.where((w) => w.wrongCount > 0).toList()
                ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Main Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    context,
                    "${progress.wordsLearned}",
                    "Words Learned",
                    Icons.school,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    context,
                    "$remaining",
                    "Remaining",
                    Icons.hourglass_empty,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    "${progress.dailyStreak}",
                    "Day Streak",
                    Icons.local_fire_department,
                    Colors.redAccent,
                  ),
                  _buildStatCard(
                    context,
                    "${progress.totalTestsPassed}",
                    "Tests Passed",
                    Icons.quiz,
                    Colors.blueAccent,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Quran Coverage Bar
              Text(
                "Quran Coverage Goal",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${percent.toStringAsFixed(1)}%",
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          "Target: 75%",
                          style: GoogleFonts.outfit(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearPercentIndicator(
                      lineHeight: 12.0,
                      percent: percent / 75.0, // Scale to target
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      progressColor: AppTheme.primaryColor,
                      barRadius: const Radius.circular(6),
                      animation: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "You are mastering the 500 words that make up ~75% of the Holy Quran.",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              if (weakWords.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildSectionTitle(context, "Weak Words"),
                const SizedBox(height: 8),
                Text(
                  "Focus on these words in your next review.",
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...weakWords
                    .take(3)
                    .map((w) => _buildWeakWordTile(context, w))
                    .toList(),
              ],

              const SizedBox(height: 32),
              _buildSectionTitle(context, "Recently Learned"),
              const SizedBox(height: 16),
              if (learned.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      "Start your journey today!",
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...learned.reversed
                    .take(5)
                    .map((w) => _buildRecentWordTile(context, w))
                    .toList(),

              const SizedBox(height: 48), // Bottom padding
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildWeakWordTile(BuildContext context, Word word) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordDetailScreen(word: word),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Text(
            "${word.wrongCount}",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        title: Text(
          word.arabic,
          style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(word.normalMeaning, style: GoogleFonts.outfit()),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildRecentWordTile(BuildContext context, Word word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordDetailScreen(word: word),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            word.arabic[0], // First char approx
            style: GoogleFonts.amiri(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          word.arabic,
          style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(word.normalMeaning, style: GoogleFonts.outfit()),
        trailing: const Icon(
          Icons.check_circle_rounded,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
    );
  }
}
