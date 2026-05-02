import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gap/gap.dart';
import '../models/interview_session.dart';
import '../models/interview_result.dart';

class InterviewResultsScreen extends StatelessWidget {
  final InterviewSession session;
  final VoidCallback? onExit;
  final VoidCallback? onRestart;

  const InterviewResultsScreen({
    super.key,
    required this.session,
    this.onExit,
    this.onRestart,
  });


  Color get _overallColor {
    final s = session.overallScore;
    if (s >= 0.75) return const Color(0xFF00C896);
    if (s >= 0.55) return const Color(0xFFFFD700);
    return const Color(0xFFFF6B6B);
  }

  String get _overallGrade {
    final s = session.overallScore;
    if (s >= 0.85) return 'Excellent';
    if (s >= 0.70) return 'Good';
    if (s >= 0.55) return 'Average';
    return 'Needs Practice';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Gap(20),

              // ── Overall score ring ────────────────────────────────────────
              CircularPercentIndicator(
                radius: 80,
                lineWidth: 12,
                percent: session.overallScore,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(session.overallScore * 100).round()}%',
                      style: TextStyle(
                        color: _overallColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _overallGrade,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                progressColor: _overallColor,
                backgroundColor: Colors.white10,
                circularStrokeCap: CircularStrokeCap.round,
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

              const Gap(20),

              const Text(
                'Interview Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(6),
              Text(
                '${session.jobRole} • ${session.totalQuestions} Questions • ${session.totalPoints} Points',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),

              const Gap(28),

              // ── Stats row ─────────────────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                    label: 'Passed',
                    value: session.results.where((r) => r.passed).length.toString(),
                    color: const Color(0xFF00C896),
                  ),
                  const Gap(12),
                  _StatCard(
                    label: 'Needs Work',
                    value: session.results.where((r) => !r.passed).length.toString(),
                    color: const Color(0xFFFF6B6B),
                  ),
                  const Gap(12),
                  _StatCard(
                    label: 'Total Points',
                    value: '${session.totalPoints}',
                    color: const Color(0xFF4F46E5),
                  ),
                ],
              ),

              const Gap(28),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Question Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const Gap(12),

              // ── Per-question results ──────────────────────────────────────
              ...session.results.asMap().entries.map((entry) {
                final i = entry.key;
                final result = entry.value;
                return _QuestionReviewCard(index: i, result: result)
                    .animate(delay: (100 * i).ms)
                    .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut);
              }),

              const Gap(28),

              // ── Action buttons ────────────────────────────────────────────
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (onExit != null) {
                          Navigator.of(context).pop(); // Go back to session screen (which will then trigger onExit if needed)
                          onExit!();
                        } else {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        }
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Back to Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ),


              const Gap(12),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onRestart != null) onRestart!();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Practice Again'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F46E5),
                        side: const BorderSide(color: Color(0xFF4F46E5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ),


              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const Gap(4),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _QuestionReviewCard extends StatefulWidget {
  final int index;
  final InterviewResult result;
  const _QuestionReviewCard({required this.index, required this.result});

  @override
  State<_QuestionReviewCard> createState() => _QuestionReviewCardState();
}

class _QuestionReviewCardState extends State<_QuestionReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.result.passed ? const Color(0xFF00C896) : const Color(0xFFFF6B6B);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(
                      '${widget.index + 1}',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      widget.result.questionText,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '${(widget.result.score * 100).round()}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const Gap(4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const Divider(color: Colors.white12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Your Answer:'),
                    Text(widget.result.userAnswer, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
                    const Gap(10),
                    const _Label('Ideal Answer:'),
                    Text(widget.result.idealAnswer, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
                    const Gap(10),
                    const _Label('Feedback:'),
                    Text(widget.result.feedback, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
