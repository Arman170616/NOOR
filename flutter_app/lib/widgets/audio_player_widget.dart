import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../config/theme.dart';
import '../services/audio_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final String label;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.label = '',
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService();
  bool _isThisPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isThisPlaying = _audioService.currentUrl == widget.audioUrl &&
              state.playing;
          _isLoading = _audioService.currentUrl == widget.audioUrl &&
              state.processingState == ProcessingState.loading;
        });
      }
    });
  }

  Future<void> _toggle() async {
    setState(() => _isLoading = true);
    try {
      await _audioService.togglePlayPause(widget.audioUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play audio')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _toggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isThisPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isThisPlaying ? 'Playing recitation...' : 'Listen to recitation',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                if (widget.label.isNotEmpty)
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textLight,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.headphones,
            color: AppTheme.textLight,
            size: 16,
          ),
        ],
      ),
    );
  }
}
