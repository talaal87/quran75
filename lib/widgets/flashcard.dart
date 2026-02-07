import 'package:flutter/material.dart';
import '../models/word.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Flashcard extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;

  const Flashcard({super.key, required this.word, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: AppTheme.surfaceColor,
        child: Container(
          width: double.infinity,
          height: 400,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tap to Reveal",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Hero(
                tag: 'arabic_${word.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    word.arabic,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.touch_app, color: Colors.grey, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
