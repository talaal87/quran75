import '../models/word.dart';

final List<Word> kInitialWords = [
  Word(
    id: 1,
    arabic: "الله",
    normalMeaning: "The One True God",
    quranicMeaning: "The Supreme Deity, Creator and Sustainer of all existence",
    exampleVerse: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
    verseTranslation:
        "In the name of Allah, the Most Gracious, the Most Merciful",
    verseReference: "1:1",
    frequency: 2699,
    synonyms: ["الإله (Al-Ilah)", "الرب (Ar-Rabb)"],
    synonymExplanation:
        "Allah is the unique name of God. 'Ilah' means any deity, while 'Rabb' emphasizes Lordship/Sustainer.",
  ),
  Word(
    id: 2,
    arabic: "الرَّحْمَٰن",
    normalMeaning: "The Most Gracious",
    quranicMeaning:
        "The Entirely Merciful, whose mercy encompasses all creation",
    exampleVerse: "الرَّحْمَٰنُ عَلَى الْعَرْشِ اسْتَوَىٰ",
    verseTranslation:
        "The Most Merciful [who is] above the Throne established.",
    verseReference: "20:5",
    frequency: 57,
    synonyms: ["الرحيم (Ar-Raheem)"],
    synonymExplanation:
        "Ar-Rahman is mercy for all creation in this world. Ar-Raheem is specific mercy for believers, especially in the Hereafter.",
  ),
  Word(
    id: 3,
    arabic: "الرَّحِيم",
    normalMeaning: "The Most Merciful",
    quranicMeaning: "The Especially Merciful, constantly bestowing mercy",
    exampleVerse: "وَكَانَ بِالْمُؤْمِنِينَ رَحِيمًا",
    verseTranslation: "And ever is He, to the believers, Merciful.",
    verseReference: "33:43",
    frequency: 114,
    synonyms: ["الرحمن (Ar-Rahman)"],
    synonymExplanation: "See Ar-Rahman explanation.",
  ),
  Word(
    id: 4,
    arabic: "يَوْم",
    normalMeaning: "Day",
    quranicMeaning: "A period of time, often referring to the Day of Judgment",
    exampleVerse: "مَالِكِ يَوْمِ الدِّينِ",
    verseTranslation: "Sovereign of the Day of Recompense.",
    verseReference: "1:4",
    frequency: 393,
    synonyms: ["حين (Hin)", "أمد (Amad)"],
    synonymExplanation:
        "Yawm is a specific day or period. Hin is a general time. Amad is a duration or span of time.",
  ),
  Word(
    id: 5,
    arabic: "الدِّين",
    normalMeaning: "Religion / Judgment",
    quranicMeaning:
        "The system of life prescribed by Allah; also Recompense/Judgment",
    exampleVerse: "مَالِكِ يَوْمِ الدِّينِ",
    verseTranslation: "Sovereign of the Day of Recompense.",
    verseReference: "1:4",
    frequency: 92,
    synonyms: ["ملة (Millah)", "شريعة (Shari'ah)"],
    synonymExplanation:
        "Deen is the complete way of life/judgment. Millah is a specific creed/faith community. Shari'ah is the law.",
  ),
  Word(
    id: 6,
    arabic: "إِيَّاكَ",
    normalMeaning: "You alone",
    quranicMeaning: "You (emphatic) - implying exclusivity 'Only You'",
    exampleVerse: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
    verseTranslation: "It is You we worship and You we ask for help.",
    verseReference: "1:5",
    frequency: 25, // Approx usage as object pronoun
    synonyms: [],
    synonymExplanation: "Grammatical particle emphasizing exclusivity.",
  ),
  Word(
    id: 7,
    arabic: "نَعْبُدُ",
    normalMeaning: "We worship",
    quranicMeaning: "To submit, serve, and worship with humility",
    exampleVerse: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
    verseTranslation: "It is You we worship...",
    verseReference: "1:5",
    frequency: 15, // frequency of this form approximately
    synonyms: ["خضع (Khada'a)", "أطاع (Ata'a)"],
    synonymExplanation:
        "'Ibadah (worship) includes all forms of submission and love. Khada'a is physical submission. Ata'a is obedience.",
  ),
];
