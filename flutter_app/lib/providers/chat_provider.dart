import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../models/ayah_model.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<ChatSession> _sessions = [];
  List<ChatMessage> _messages = [];
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  List<FavoriteAyah> _favorites = [];

  List<ChatSession> get sessions => _sessions;
  List<ChatMessage> get messages => _messages;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  List<FavoriteAyah> get favorites => _favorites;

  bool isFavorite(int surah, int ayah) =>
      _favorites.any((f) => f.surahNumber == surah && f.ayahNumber == ayah);

  Future<void> loadSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sessions = await _api.getSessions();
    } catch (e) {
      _error = 'Failed to load conversations';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSessionMessages(String sessionId) async {
    _isLoading = true;
    _currentSessionId = sessionId;
    _messages = [];
    notifyListeners();
    try {
      final data = await _api.getSessionDetail(sessionId);
      _messages = (data['messages'] as List? ?? [])
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Failed to load messages';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendMessage(String text) async {
    if (text.trim().isEmpty) return false;
    _isSending = true;
    _error = null;
    notifyListeners();

    // Optimistic user message
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    _messages.add(ChatMessage(id: tempId, role: 'user', content: text));
    notifyListeners();

    try {
      final data = await _api.sendMessage(text, sessionId: _currentSessionId);

      // Remove optimistic message
      _messages.removeWhere((m) => m.id == tempId);

      final userMsg = ChatMessage.fromJson(
          data['user_message'] as Map<String, dynamic>);
      final assistantMsg = ChatMessage.fromJson(
          data['assistant_message'] as Map<String, dynamic>);

      _messages.add(userMsg);
      _messages.add(assistantMsg);
      _currentSessionId = data['session_id'] as String;

      _isSending = false;
      notifyListeners();

      // Refresh sessions list
      loadSessions();
      return true;
    } catch (e) {
      _messages.removeWhere((m) => m.id == tempId);
      _error = 'Failed to send message. Please try again.';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  void startNewChat() {
    _currentSessionId = null;
    _messages = [];
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _api.deleteSession(sessionId);
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_currentSessionId == sessionId) startNewChat();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete conversation';
      notifyListeners();
    }
  }

  // ─── Favorites ───
  Future<void> loadFavorites() async {
    try {
      _favorites = await _api.getFavorites();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> toggleFavorite(QuranSuggestion suggestion, String emotion) async {
    final existing = _favorites.firstWhere(
      (f) => f.surahNumber == suggestion.surahNumber &&
             f.ayahNumber == suggestion.ayahNumber,
      orElse: () => FavoriteAyah(
        id: '', surahNumber: 0, ayahNumber: 0, numberInQuran: 0,
        surahName: '', surahNameArabic: '', arabicText: '',
        translation: '', audioUrl: '', emotionContext: '', note: '',
      ),
    );

    if (existing.id.isNotEmpty) {
      // Remove
      await _api.removeFavorite(existing.id);
      _favorites.removeWhere((f) => f.id == existing.id);
      notifyListeners();
      return false;
    } else {
      // Add
      final fav = await _api.addFavorite(suggestion, emotion: emotion);
      if (fav != null) _favorites.add(fav);
      notifyListeners();
      return true;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
