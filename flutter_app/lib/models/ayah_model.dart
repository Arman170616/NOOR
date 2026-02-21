class QuranSuggestion {
  final int surahNumber;
  final String surahName;
  final String surahNameArabic;
  final int ayahNumber;
  final int numberInQuran;
  final String arabicText;
  final String translation;
  final String explanation;
  final String audioUrl;

  QuranSuggestion({
    required this.surahNumber,
    required this.surahName,
    required this.surahNameArabic,
    required this.ayahNumber,
    required this.numberInQuran,
    required this.arabicText,
    required this.translation,
    required this.explanation,
    required this.audioUrl,
  });

  factory QuranSuggestion.fromJson(Map<String, dynamic> json) {
    return QuranSuggestion(
      surahNumber: json['surah_number'] ?? 0,
      surahName: json['surah_name'] ?? '',
      surahNameArabic: json['surah_name_arabic'] ?? '',
      ayahNumber: json['ayah_number'] ?? 0,
      numberInQuran: json['number_in_quran'] ?? 0,
      arabicText: json['arabic_text'] ?? '',
      translation: json['translation'] ?? '',
      explanation: json['explanation'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'surah_number': surahNumber,
        'surah_name': surahName,
        'surah_name_arabic': surahNameArabic,
        'ayah_number': ayahNumber,
        'number_in_quran': numberInQuran,
        'arabic_text': arabicText,
        'translation': translation,
        'explanation': explanation,
        'audio_url': audioUrl,
      };

  String get reference => '${surahName} $surahNumber:$ayahNumber';
}

class FavoriteAyah {
  final String id;
  final int surahNumber;
  final int ayahNumber;
  final int numberInQuran;
  final String surahName;
  final String surahNameArabic;
  final String arabicText;
  final String translation;
  final String audioUrl;
  final String emotionContext;
  final String note;
  final DateTime? addedAt;

  FavoriteAyah({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.numberInQuran,
    required this.surahName,
    required this.surahNameArabic,
    required this.arabicText,
    required this.translation,
    required this.audioUrl,
    required this.emotionContext,
    required this.note,
    this.addedAt,
  });

  factory FavoriteAyah.fromJson(Map<String, dynamic> json) {
    return FavoriteAyah(
      id: json['id'] ?? '',
      surahNumber: json['surah_number'] ?? 0,
      ayahNumber: json['ayah_number'] ?? 0,
      numberInQuran: json['number_in_quran'] ?? 0,
      surahName: json['surah_name'] ?? '',
      surahNameArabic: json['surah_name_arabic'] ?? '',
      arabicText: json['arabic_text'] ?? '',
      translation: json['translation'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      emotionContext: json['emotion_context'] ?? '',
      note: json['note'] ?? '',
      addedAt: json['added_at'] != null
          ? DateTime.tryParse(json['added_at'])
          : null,
    );
  }

  QuranSuggestion toSuggestion() => QuranSuggestion(
        surahNumber: surahNumber,
        surahName: surahName,
        surahNameArabic: surahNameArabic,
        ayahNumber: ayahNumber,
        numberInQuran: numberInQuran,
        arabicText: arabicText,
        translation: translation,
        explanation: emotionContext,
        audioUrl: audioUrl,
      );
}
