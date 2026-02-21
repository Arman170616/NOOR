import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/ayah_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/audio_player_widget.dart';

class AyahDetailScreen extends StatefulWidget {
  final QuranSuggestion suggestion;
  const AyahDetailScreen({super.key, required this.suggestion});

  @override
  State<AyahDetailScreen> createState() => _AyahDetailScreenState();
}

class _AyahDetailScreenState extends State<AyahDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    final isFav =
        context.watch<ChatProvider>().isFavorite(s.surahNumber, s.ayahNumber);

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.bookmark : Icons.bookmark_border,
                  color: isFav ? AppTheme.accentGold : Colors.white,
                ),
                onPressed: () {
                  context.read<ChatProvider>().toggleFavorite(s, '');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav ? 'Removed from saved ayahs' : 'Ayah saved!',
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined),
                onPressed: () => _copyAyah(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.surahName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Surah ${s.surahNumber} • Ayah ${s.ayahNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Arabic Text Card
                      _ArabicCard(arabicText: s.arabicText),

                      const SizedBox(height: 16),

                      // Audio Player
                      _AudioSection(suggestion: s),

                      const SizedBox(height: 16),

                      // Translation Card
                      _InfoCard(
                        icon: Icons.translate,
                        title: 'Translation',
                        content: s.translation,
                        contentStyle: const TextStyle(
                          fontSize: 16,
                          height: 1.7,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Explanation Card
                      _InfoCard(
                        icon: Icons.auto_stories,
                        title: 'Reflection',
                        content: s.explanation,
                        contentStyle: TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Surah Info Badge
                      _SurahInfoBadge(suggestion: s),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyAyah(BuildContext context) {
    final s = widget.suggestion;
    final text =
        '${s.arabicText}\n\n${s.translation}\n\n— ${s.surahName} ${s.surahNumber}:${s.ayahNumber}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ayah copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}

// ─── Arabic Card ─────────────────────────────────────────────────────────────

class _ArabicCard extends StatelessWidget {
  final String arabicText;
  const _ArabicCard({required this.arabicText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            arabicText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              height: 2.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 60,
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'بِسْمِ اللَّهِ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              color: AppTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Audio Section ────────────────────────────────────────────────────────────

class _AudioSection extends StatelessWidget {
  final QuranSuggestion suggestion;
  const _AudioSection({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    if (suggestion.audioUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.music_note,
                  color: AppTheme.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recitation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const Spacer(),
              Text(
                'Sheikh Al-Afasy',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AudioPlayerWidget(audioUrl: suggestion.audioUrl),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final TextStyle? contentStyle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    this.contentStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: contentStyle ??
                const TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: Color(0xFF2D2D2D),
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Surah Info Badge ─────────────────────────────────────────────────────────

class _SurahInfoBadge extends StatelessWidget {
  final QuranSuggestion suggestion;
  const _SurahInfoBadge({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BadgeItem(
            label: 'Surah',
            value: suggestion.surahNumber.toString(),
          ),
          Container(width: 1, height: 36, color: AppTheme.primaryGreen.withOpacity(0.15)),
          _BadgeItem(
            label: 'Ayah',
            value: suggestion.ayahNumber.toString(),
          ),
          Container(width: 1, height: 36, color: AppTheme.primaryGreen.withOpacity(0.15)),
          _BadgeItem(
            label: 'Name',
            value: suggestion.surahName,
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String label;
  final String value;
  const _BadgeItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
