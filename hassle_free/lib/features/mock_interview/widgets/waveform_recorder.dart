import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

/// Animated waveform that pulses while the user is speaking.
class WaveformRecorder extends StatefulWidget {
  final bool isListening;
  final String transcript;
  final VoidCallback onStop;
  final VoidCallback onSkip;
  final VoidCallback onRetry;

  const WaveformRecorder({
    super.key,
    required this.isListening,
    required this.transcript,
    required this.onStop,
    required this.onSkip,
    required this.onRetry,
  });

  @override
  State<WaveformRecorder> createState() => _WaveformRecorderState();
}

class _WaveformRecorderState extends State<WaveformRecorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isListening
              ? const Color(0xFF00C896).withValues(alpha: 0.6)
              : Colors.white12,
        ),
      ),
      child: Column(
        children: [
          // ── Waveform bars ────────────────────────────────────────────────
          // Always show when this widget is active to give user feedback
          ...[

            SizedBox(
              height: 56,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(30, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 4,
                        height: widget.isListening
                            ? 8.0 + (_rand.nextDouble() * 40)
                            : 6.0 + (sin(_waveController.value * 2 * pi + i) * 3),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: widget.isListening 
                              ? const Color(0xFF00C896)
                              : const Color(0xFF00C896).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 8),
            text(
              widget.isListening ? 'Listening... speak your answer' : 'Microphone stopped',
              style: TextStyle(
                color: widget.isListening ? Colors.white.withValues(alpha: 0.5) : Colors.orangeAccent,
                fontSize: 12,
              ),
            ),
            if (!widget.isListening) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Restart Microphone', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
              ),
            ],
          ],

          // ── Transcript ───────────────────────────────────────────────────
          if (widget.transcript.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.transcript,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Controls ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip button
              OutlinedButton.icon(
                onPressed: widget.onSkip,
                icon: const Icon(Icons.skip_next_rounded, size: 18),
                label: const Text('Skip'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4F46E5),
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),

              // Stop / Submit button
              ElevatedButton.icon(
                onPressed: widget.onStop,
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text('Submit Answer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for text to avoid lowercase 'text' vs 'Text' confusion if any
  Widget text(String data, {TextStyle? style}) => Text(data, style: style);
}
