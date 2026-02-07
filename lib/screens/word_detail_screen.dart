import 'package:flutter/material.dart';
import '../models/word.dart';
import '../theme/app_theme.dart';

class WordDetailScreen extends StatelessWidget {
  final Word word;

  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                word.arabic,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 72,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildInfoCard(context, "Normal Meaning", word.normalMeaning),
            const SizedBox(height: 16),
            _buildInfoCard(context, "Qur'anic Meaning", word.quranicMeaning),
            const SizedBox(height: 16),

            _buildSectionHeader(context, "Example Verse"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    word.exampleVerse,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Amiri',
                      height: 1.8,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    word.verseTranslation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "(${word.verseReference})",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader(context, "Linguistic Details"),
            const SizedBox(height: 8),
            ListTile(
              title: const Text("Frequency in Qur'an"),
              trailing: Text(
                "${word.frequency} times",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            if (word.synonyms.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader(context, "Synonyms & Differences"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: word.synonyms
                          .map((s) => Chip(label: Text(s)))
                          .toList(),
                    ),
                    if (word.synonymExplanation != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        word.synonymExplanation!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textSecondary,
        letterSpacing: 1.1,
      ),
    );
  }
}
