class Word {
  final int id;
  final String arabic;
  final String normalMeaning;
  final String quranicMeaning; // Contextual
  final String exampleVerse;
  final String verseTranslation;
  final String verseReference; // e.g. "2:255"
  final int frequency;
  final List<String> synonyms; // Explanation only
  final String? synonymExplanation; // Difference between synonyms

  // Progress tracking
  bool isLearned;
  DateTime? learnedAt;
  int wrongCount; // For weak words tracking

  Word({
    required this.id,
    required this.arabic,
    required this.normalMeaning,
    required this.quranicMeaning,
    required this.exampleVerse,
    required this.verseTranslation,
    required this.verseReference,
    required this.frequency,
    this.synonyms = const [],
    this.synonymExplanation,
    this.isLearned = false,
    this.learnedAt,
    this.wrongCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'normalMeaning': normalMeaning,
      'quranicMeaning': quranicMeaning,
      'exampleVerse': exampleVerse,
      'verseTranslation': verseTranslation,
      'verseReference': verseReference,
      'frequency': frequency,
      'synonyms': synonyms,
      'synonymExplanation': synonymExplanation,
      'isLearned': isLearned,
      'learnedAt': learnedAt?.toIso8601String(),
      'wrongCount': wrongCount,
    };
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      arabic: json['arabic'],
      normalMeaning: json['normalMeaning'],
      quranicMeaning: json['quranicMeaning'],
      exampleVerse: json['exampleVerse'],
      verseTranslation: json['verseTranslation'] ?? '',
      verseReference: json['verseReference'],
      frequency: json['frequency'],
      synonyms: List<String>.from(json['synonyms'] ?? []),
      synonymExplanation: json['synonymExplanation'],
      isLearned: json['isLearned'] ?? false,
      learnedAt: json['learnedAt'] != null
          ? DateTime.parse(json['learnedAt'])
          : null,
      wrongCount: json['wrongCount'] ?? 0,
    );
  }
}
