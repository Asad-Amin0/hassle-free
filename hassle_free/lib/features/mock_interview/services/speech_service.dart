import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class SpeechService {
  final SpeechToText _stt = SpeechToText();
  bool _isAvailable = false;
  bool _isInitialized = false;

  Future<bool> init({bool force = false}) async {
    try {
      if (_isInitialized && !force) return _isAvailable;
      
      debugPrint('[SpeechService] Initializing (force=$force)...');
      
      if (!kIsWeb) {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          debugPrint('[SpeechService] Microphone permission denied');
          return false;
        }
      }

      _isAvailable = await _stt.initialize(
        onError: (e) => debugPrint('[SpeechService] Error: ${e.errorMsg} - ${e.permanent}'),
        onStatus: (s) {
          debugPrint('[SpeechService] Status: $s');
        },
      );
      
      _isInitialized = true;
      if (!_isAvailable) {
        debugPrint('[SpeechService] Speech recognition NOT available on this device');
      }
      return _isAvailable;
    } catch (e) {
      debugPrint('[SpeechService] Initialization exception: $e');
      return false;
    }
  }

  /// Returns true if listening started successfully.
  Future<bool> startListening({
    required Function(String partial) onPartial,
    required Function(String final_) onFinal,
    Duration listenFor = const Duration(seconds: 60),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_isAvailable) await init();
    if (!_isAvailable) return false;

    // Force cancel any previous session and wait for hardware release
    await _stt.cancel();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await _stt.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            if (result.finalResult) {
              onFinal(result.recognizedWords);
            } else {
              onPartial(result.recognizedWords);
            }
          }
        },
        listenFor: listenFor,
        pauseFor: pauseFor,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[SpeechService] Listen error: $e');
      return false;
    }
  }

  Future<void> stopListening() async => _stt.stop();
  Future<void> cancelListening() async => _stt.cancel();
  bool get isListening => _stt.isListening;
  void dispose() => _stt.cancel();
}
