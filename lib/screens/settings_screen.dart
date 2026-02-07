import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<WordProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Word Generation Status
              _buildSectionHeader(context, "Word Database"),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            provider.isGenerating
                                ? Icons.sync
                                : Icons.check_circle,
                            color: provider.isGenerating
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.isGenerating
                                  ? "Generating word details... (${provider.generationProgress}%)"
                                  : "All ${provider.allWords.length} words loaded",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      if (provider.isGenerating) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: provider.generationProgress / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Word details are generated using AI and cached locally for instant access.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(context, "Data Management"),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("Reset All Progress"),
                subtitle: const Text("Clears all learned words and stats"),
                leading: const Icon(Icons.refresh, color: Colors.red),
                onTap: () => _showResetDialog(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withOpacity(0.2)),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionHeader(context, "About"),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Quran75",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Version 1.0.0",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Learn 500 high-frequency words that make up 75% of Qur'anic vocabulary.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Powered by Gemini AI",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: AppTheme.primaryColor,
        fontSize: 18,
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Progress?"),
        content: const Text(
          "This will permanently delete all your learned words and progress. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<WordProvider>().resetAll();
              Navigator.pop(context);
              Navigator.pop(context); // Go back home
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
