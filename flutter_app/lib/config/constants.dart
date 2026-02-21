class AppConstants {
  // API Base URL - change to your server IP/domain
  // static const String baseUrl = 'http://10.0.2.2:8001/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8001/api'; // iOS simulator
  static const String baseUrl = 'https://2c3b58e461e813d6-85-154-148-204.serveousercontent.com/api'; // Tunnel URL
  // static const String baseUrl = 'https://your-domain.com/api'; // Production

  // Google Sign-In
  static const String googleAndroidClientId =
      '140560791771-eurpjb2c26s8vjbuqqvj2uf1knu69b3t.apps.googleusercontent.com';
  static const String googleWebClientId =
      '140560791771-9hk2f6j6o93aq2ci4oj87pe9ch9bglr0.apps.googleusercontent.com';

  // Al-Quran Cloud
  static const String quranAudioBase =
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy';

  // App info
  static const String appName = 'Noor';
  static const String appNameArabic = 'نور';
  static const String appTagline = 'Let the Quran guide your heart';

  // Storage keys
  static const String kAccessToken = 'access_token';
  static const String kRefreshToken = 'refresh_token';
  static const String kUserData = 'user_data';

  // Quick emotion prompts (Map format with emoji/label/message)
  static const List<Map<String, String>> emotionPrompts = [
    {'emoji': '😔', 'label': 'Sad', 'message': 'I am feeling really sad today'},
    {'emoji': '😟', 'label': 'Anxious', 'message': 'I feel anxious and worried'},
    {'emoji': '😤', 'label': 'Stressed', 'message': 'I am overwhelmed with stress'},
    {'emoji': '😶', 'label': 'Empty', 'message': 'I feel empty and lost inside'},
    {'emoji': '😰', 'label': 'Fearful', 'message': 'I am experiencing a lot of fear'},
    {'emoji': '😞', 'label': 'Hopeless', 'message': 'I feel hopeless about everything'},
    {'emoji': '😠', 'label': 'Angry', 'message': 'I am feeling very angry and upset'},
    {'emoji': '😊', 'label': 'Grateful', 'message': 'I feel grateful and want to thank Allah'},
  ];

  // Quick emotion prompts as plain strings (used in HomeScreen chips)
  static List<String> get quickEmotionPrompts =>
      emotionPrompts.map((p) => '${p['emoji']} ${p['label']}').toList();
}
