import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import '../models/chat_message_model.dart';
import '../models/ayah_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.kAccessToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString(AppConstants.kAccessToken);
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        return handler.next(error);
      },
    ));
    _initialized = true;
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString(AppConstants.kRefreshToken);
      if (refresh == null) return false;

      final resp = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh/',
        data: {'refresh': refresh},
      );
      if (resp.statusCode == 200) {
        await prefs.setString(AppConstants.kAccessToken, resp.data['access']);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ───── AUTH ─────
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    await init();
    final resp = await _dio.post('/auth/google/', data: {'id_token': idToken});
    return resp.data as Map<String, dynamic>;
  }

  Future<void> logout(String refreshToken) async {
    await init();
    await _dio.post('/auth/logout/', data: {'refresh': refreshToken});
  }

  Future<UserModel> getProfile() async {
    await init();
    final resp = await _dio.get('/auth/profile/');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  // ───── CHAT ─────
  Future<List<ChatSession>> getSessions() async {
    await init();
    final resp = await _dio.get('/chat/sessions/');
    return (resp.data as List)
        .map((s) => ChatSession.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> sendMessage(String message, {String? sessionId}) async {
    await init();
    final data = <String, dynamic>{'message': message};
    if (sessionId != null) data['session_id'] = sessionId;
    final resp = await _dio.post('/chat/message/', data: data);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSessionDetail(String sessionId) async {
    await init();
    final resp = await _dio.get('/chat/sessions/$sessionId/');
    return resp.data as Map<String, dynamic>;
  }

  Future<void> deleteSession(String sessionId) async {
    await init();
    await _dio.delete('/chat/sessions/$sessionId/');
  }

  // ───── QURAN ─────
  Future<List<FavoriteAyah>> getFavorites() async {
    await init();
    final resp = await _dio.get('/quran/favorites/');
    return (resp.data as List)
        .map((f) => FavoriteAyah.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<FavoriteAyah?> addFavorite(QuranSuggestion suggestion, {String emotion = ''}) async {
    await init();
    final resp = await _dio.post('/quran/favorites/add/', data: {
      'surah_number': suggestion.surahNumber,
      'ayah_number': suggestion.ayahNumber,
      'number_in_quran': suggestion.numberInQuran,
      'surah_name': suggestion.surahName,
      'surah_name_arabic': suggestion.surahNameArabic,
      'arabic_text': suggestion.arabicText,
      'translation': suggestion.translation,
      'audio_url': suggestion.audioUrl,
      'emotion_context': emotion,
    });
    if (resp.statusCode == 201) {
      return FavoriteAyah.fromJson(resp.data as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> removeFavorite(String favoriteId) async {
    await init();
    await _dio.delete('/quran/favorites/$favoriteId/');
  }

  Future<Map<String, dynamic>> getAyahDetail(int surah, int ayah) async {
    await init();
    final resp = await _dio.get('/quran/ayah/$surah/$ayah/');
    return resp.data as Map<String, dynamic>;
  }
}
