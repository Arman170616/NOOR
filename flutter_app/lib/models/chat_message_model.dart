import 'ayah_model.dart';

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final String emotion;
  final List<QuranSuggestion> quranSuggestions;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.emotion = '',
    this.quranSuggestions = const [],
    this.createdAt,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get hasSuggestions => quranSuggestions.isNotEmpty;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final suggestions = (json['quran_suggestions'] as List? ?? [])
        .map((s) => QuranSuggestion.fromJson(s as Map<String, dynamic>))
        .toList();

    return ChatMessage(
      id: json['id'] ?? '',
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      emotion: json['emotion'] ?? '',
      quranSuggestions: suggestions,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final Map<String, dynamic>? lastMessage;
  final int messageCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    this.lastMessage,
    this.messageCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? '',
      title: json['title'] ?? 'New Conversation',
      lastMessage: json['last_message'],
      messageCount: json['message_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  String get displayTitle => title.isEmpty ? 'New Conversation' : title;
}
