import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';


class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  Function(String phoneme)? onPhoneme; // hook for lip-sync

  Future<void> init() async {
    if (_isInitialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5); // Standard 1x speed
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1); // Slightly higher pitch for a professional female voice
    
    // Prefer a clear voice — on Android/iOS, pick the best available
    final voices = await _tts.getVoices;
    if (voices != null) {
      final preferred = (voices as List).firstWhere(
        (v) => v['name'].toString().contains('en-US-Neural') ||
               v['name'].toString().contains('Samantha') ||
               v['name'].toString().contains('en-us'),
        orElse: () => null,
      );
      if (preferred != null) {
        await _tts.setVoice({'name': preferred['name'], 'locale': preferred['locale']});
      }
    }

    _tts.setCompletionHandler(() => onPhoneme?.call('X')); // Mouth closed when done
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    
    final completer = Completer<void>();
    _tts.setCompletionHandler(() {
      onPhoneme?.call('X');
      if (!completer.isCompleted) completer.complete();
    });
    
    _tts.setErrorHandler((msg) {
      if (!completer.isCompleted) completer.complete();
    });

    await _tts.speak(text);
    return completer.future;
  }


  Future<void> stop() async => _tts.stop();
  Future<void> pause() async => _tts.pause();
  void dispose() => _tts.stop();
}
