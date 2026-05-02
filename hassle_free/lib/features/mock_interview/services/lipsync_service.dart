import '../models/avatar_state.dart';

/// Generates approximate phoneme frames from TTS text for lip-sync animation.
/// In production, replace with actual Rhubarb lip-sync output from your backend.
class LipSyncService {

  /// Maps a text string to approximate phoneme frames.
  /// Each frame has a time offset (seconds) and a mouth shape code.
  List<LipSyncFrame> generateFrames(String text) {
    final words = text.split(RegExp(r'\s+'));
    final frames = <LipSyncFrame>[];
    double timeOffset = 0.0;

    for (final word in words) {
      final syllables = _countSyllables(word);
      final wordDuration = syllables * 0.18; // ~180ms per syllable

      for (int i = 0; i < syllables; i++) {
        frames.add(LipSyncFrame(
          time: timeOffset + (i * 0.18),
          phoneme: _syllableToPhoneme(word, i),
        ));
      }

      frames.add(LipSyncFrame(time: timeOffset + wordDuration, phoneme: 'X'));
      timeOffset += wordDuration + 0.08; // small gap between words
    }

    frames.add(LipSyncFrame(time: timeOffset + 0.2, phoneme: 'X')); // final close
    return frames;
  }

  int _countSyllables(String word) {
    if (word.length <= 2) return 1;
    final vowelMatches = RegExp(r'[aeiouAEIOU]').allMatches(word);
    return vowelMatches.isEmpty ? 1 : vowelMatches.length;
  }

  String _syllableToPhoneme(String word, int syllableIndex) {
    // Simple mapping — in production use Rhubarb output from backend
    final phonemePool = ['A', 'B', 'C', 'D', 'E', 'F'];
    return phonemePool[word.hashCode.abs() % phonemePool.length];
  }

  /// Get the current phoneme for a given time offset.
  String getPhonemeAt(List<LipSyncFrame> frames, double currentTime) {
    LipSyncFrame? current;
    for (final frame in frames) {
      if (frame.time <= currentTime) {
        current = frame;
      } else {
        break;
      }
    }
    return current?.phoneme ?? 'X';
  }
}
