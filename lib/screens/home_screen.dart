import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../providers/word_provider.dart';
import '../theme/app_theme.dart';
import 'flashcard_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<WordProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final progress = provider.progress;
            final isLessonDone = progress.isLessonCompletedToday;
            final isTestDone = progress.isTestCompletedToday;
            final isTodayComplete = isLessonDone && isTestDone;

            // Calculate today's progress for the linear indicator
            double todayPercent = 0.0;
            if (isTodayComplete) {
              todayPercent = 1.0;
            } else if (isLessonDone) {
              todayPercent = 0.5; // Lesson done, test pending
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header: Logo/Name at Top Left
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 32,
                          height: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Quran75',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Main Stats Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Current Streak",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: AppTheme.secondaryColor,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${progress.dailyStreak} Days",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            CircularPercentIndicator(
                              radius: 30.0,
                              lineWidth: 6.0,
                              percent:
                                  progress.quranCoverage /
                                  100, // Normalized 0-75% to 0-1.0 visually if needed, but logic uses real stats
                              center: Text(
                                "${progress.quranCoverage.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              progressColor: AppTheme.secondaryColor,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Today's Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's Goal",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  isTodayComplete
                                      ? "Completed"
                                      : (isLessonDone
                                            ? "Test Pending"
                                            : "0/2 Steps"),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearPercentIndicator(
                              padding: EdgeInsets.zero,
                              lineHeight: 8.0,
                              percent: todayPercent,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              progressColor: AppTheme.secondaryColor,
                              barRadius: const Radius.circular(4),
                              animation: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Today's Lesson Section
                  Text(
                    "Today's Lesson",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isLessonDone && !isTestDone
                                ? Colors.orange.withOpacity(0.1)
                                : (isTodayComplete
                                      ? Colors.green.withOpacity(0.1)
                                      : AppTheme.primaryColor.withOpacity(0.1)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isTodayComplete
                                ? Icons.check_circle_rounded
                                : (isLessonDone
                                      ? Icons.quiz_rounded
                                      : Icons.play_lesson_rounded),
                            size: 48,
                            color: isLessonDone && !isTestDone
                                ? Colors.orange
                                : (isTodayComplete
                                      ? Colors.green
                                      : AppTheme.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isTodayComplete
                              ? "Alhamdulillah! Day Complete"
                              : (isLessonDone
                                    ? "Time for a Quiz!"
                                    : "Learn New Words"),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isTodayComplete
                              ? "You've completed today's streak. Come back tomorrow!"
                              : (isLessonDone
                                    ? "Test your knowledge to keep your streak."
                                    : "You have 5 new words to learn today."),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isTodayComplete
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const FlashcardScreen(),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLessonDone && !isTestDone
                                  ? Colors.orange
                                  : AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              elevation: isTodayComplete ? 0 : 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.grey[500],
                            ),
                            child: Text(
                              isTodayComplete
                                  ? "Completed"
                                  : (isLessonDone
                                        ? "Take Quiz"
                                        : "Start Lesson"),
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
                  const SizedBox(height: 24),

                  // Progress Link
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProgressScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text(
                        "View Full Progress",
                        style: GoogleFonts.outfit(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
