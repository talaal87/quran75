class UserProgress {
  int wordsLearned;
  double quranCoverage; // percentage 0-100
  int dailyStreak;
  DateTime? lastStudyDate;
  List<int> weakWordIds;

  // New fields for proper streak and test tracking
  bool todayLessonCompleted;
  bool todayTestCompleted;
  DateTime? lastLessonDate;
  DateTime? lastTestDate;
  int totalTestsTaken;
  int totalTestsPassed;
  int todayWordsLearned;

  UserProgress({
    this.wordsLearned = 0,
    this.quranCoverage = 0.0,
    this.dailyStreak = 0,
    this.lastStudyDate,
    this.weakWordIds = const [],
    this.todayLessonCompleted = false,
    this.todayTestCompleted = false,
    this.lastLessonDate,
    this.lastTestDate,
    this.totalTestsTaken = 0,
    this.totalTestsPassed = 0,
    this.todayWordsLearned = 0,
  });

  /// Check if today's lesson is already completed
  bool get isLessonCompletedToday {
    if (lastLessonDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lessonDay = DateTime(
      lastLessonDate!.year,
      lastLessonDate!.month,
      lastLessonDate!.day,
    );
    return lessonDay == today;
  }

  /// Check if today's test is already completed
  bool get isTestCompletedToday {
    if (lastTestDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final testDay = DateTime(
      lastTestDate!.year,
      lastTestDate!.month,
      lastTestDate!.day,
    );
    return testDay == today;
  }

  /// Check if today's streak is fully earned (lesson + test)
  bool get isTodayComplete => isLessonCompletedToday && isTestCompletedToday;

  Map<String, dynamic> toJson() {
    return {
      'wordsLearned': wordsLearned,
      'quranCoverage': quranCoverage,
      'dailyStreak': dailyStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'weakWordIds': weakWordIds,
      'todayLessonCompleted': todayLessonCompleted,
      'todayTestCompleted': todayTestCompleted,
      'lastLessonDate': lastLessonDate?.toIso8601String(),
      'lastTestDate': lastTestDate?.toIso8601String(),
      'totalTestsTaken': totalTestsTaken,
      'totalTestsPassed': totalTestsPassed,
      'todayWordsLearned': todayWordsLearned,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      wordsLearned: json['wordsLearned'] ?? 0,
      quranCoverage: (json['quranCoverage'] ?? 0.0).toDouble(),
      dailyStreak: json['dailyStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'])
          : null,
      weakWordIds: List<int>.from(json['weakWordIds'] ?? []),
      todayLessonCompleted: json['todayLessonCompleted'] ?? false,
      todayTestCompleted: json['todayTestCompleted'] ?? false,
      lastLessonDate: json['lastLessonDate'] != null
          ? DateTime.parse(json['lastLessonDate'])
          : null,
      lastTestDate: json['lastTestDate'] != null
          ? DateTime.parse(json['lastTestDate'])
          : null,
      totalTestsTaken: json['totalTestsTaken'] ?? 0,
      totalTestsPassed: json['totalTestsPassed'] ?? 0,
      todayWordsLearned: json['todayWordsLearned'] ?? 0,
    );
  }
}
