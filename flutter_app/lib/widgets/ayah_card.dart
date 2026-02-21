import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/ayah_model.dart';
import '../providers/chat_provider.dart';
import '../screens/ayah_detail_screen.dart';
import 'audio_player_widget.dart';

class AyahCard extends StatelessWidget {
  final QuranSuggestion suggestion;
  final String emotion;

  const AyahCard({super.key, required this.suggestion, this.emotion = ''});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final isFav = chatProvider.isFavorite(
            suggestion.surahNumber, suggestion.ayahNumber);
        return Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppTheme.accentGold.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AyahDetailScreen(
                    suggestion: suggestion,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${suggestion.surahName} ${suggestion.surahNumber}:${suggestion.ayahNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Favorite button
                        GestureDetector(
                          onTap: () async {
                            await chatProvider.toggleFavorite(
                                suggestion, emotion);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFav
                                        ? 'Removed from favorites'
                                        : 'Added to favorites ✨',
                                  ),
                                  backgroundColor: isFav
                                      ? Colors.grey
                                      : AppTheme.primaryGreen,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Icon(
                            isFav ? Icons.bookmark : Icons.bookmark_border,
                            color: isFav
                                ? AppTheme.accentGold
                                : AppTheme.textLight,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Arabic text
                    if (suggestion.arabicText.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.cream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          suggestion.arabicText,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            color: AppTheme.primaryGreen,
                            height: 2.0,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Translation
                    if (suggestion.translation.isNotEmpty)
                      Text(
                        '"${suggestion.translation}"',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Explanation
                    Text(
                      suggestion.explanation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        height: 1.4,
                      ),
                    ),
                    // Audio player
                    if (suggestion.audioUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      AudioPlayerWidget(
                          audioUrl: suggestion.audioUrl,
                          label:
                              '${suggestion.surahName} ${suggestion.surahNumber}:${suggestion.ayahNumber}'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
