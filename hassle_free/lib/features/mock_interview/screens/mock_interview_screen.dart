import 'package:flutter/material.dart';
import '../models/interview_question.dart';

import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../viewmodels/mock_interview_viewmodel.dart';
import '../models/interview_session.dart';
import '../widgets/avatar_3d_widget.dart';
import '../widgets/waveform_recorder.dart';
import '../widgets/score_indicator.dart';
import '../models/avatar_state.dart';
import 'interview_results_screen.dart';

class MockInterviewScreen extends StatefulWidget {
  final String userId;
  final String jobRole;
  final List<String> skills; // Pulled from user's parsed resume
  final VoidCallback? onExit;

  const MockInterviewScreen({
    super.key,
    required this.userId,
    required this.jobRole,
    required this.skills,
    this.onExit,
  });


  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  bool _navigatedToResults = false;

  @override

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MockInterviewViewModel>().startSession(
        userId: widget.userId,
        jobRole: widget.jobRole,
        skills: widget.skills,
      );
    });
  }

  @override
  void dispose() {
    // Stop speech and listening when leaving the screen
    // We use a safe way to access the ViewModel during dispose
    try {
      Provider.of<MockInterviewViewModel>(context, listen: false).stopAll();
    } catch (e) {
      debugPrint('Error stopping AI on dispose: $e');
    }
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Consumer<MockInterviewViewModel>(
        builder: (context, vm, _) {
          // Navigate to results when completed
          if (vm.isCompleted &&
              vm.session?.status == InterviewStatus.completed &&
              !_navigatedToResults) {
            _navigatedToResults = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InterviewResultsScreen(
                    session: vm.session!,
                    onExit: widget.onExit,
                    onRestart: () {
                      setState(() => _navigatedToResults = false);
                      vm.startSession(
                        userId: widget.userId,
                        jobRole: widget.jobRole,
                        skills: widget.skills,
                      );
                    },
                  ),
                ),
              );
            });
          }

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(vm),
                Expanded(
                  child: vm.isLoading
                      ? _buildLoading()
                      : _buildInterviewBody(vm),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(MockInterviewViewModel vm) {
    final session = vm.session;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => _confirmExit(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Job role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.jobRole,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (session != null)
                  Text(
                    'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ),

          // Points
          if (session != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.4)),
              ),
              child: Text(
                '${session.totalPoints} pts',
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF4F46E5)),
          const Gap(20),
          const Text(
            'Preparing your interview questions\nusing AI & RAG system...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  // ─── Interview Body ────────────────────────────────────────────────────────
  Widget _buildInterviewBody(MockInterviewViewModel vm) {
    if (vm.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                vm.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.startSession(
                  userId: widget.userId,
                  jobRole: widget.jobRole,
                  skills: widget.skills,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(

      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(vm),
          const Gap(12),

          // 3D Avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Selector<MockInterviewViewModel, (AvatarState, ValueNotifier<String>)>(
              selector: (_, vm) => (vm.avatarState, vm.phonemeNotifier),
              builder: (context, data, _) {
                return Avatar3DWidget(
                  avatarState: data.$1,
                  phonemeNotifier: data.$2,
                );
              },
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          ),
          const Gap(20),

          // Avatar's current text (subtitle)
          if (vm.avatarState.currentText.isNotEmpty)
            _buildSubtitle(vm.avatarState.currentText),

          const Gap(12),

          // Current question card
          if (vm.currentQuestion != null) ...[
            _buildQuestionCard(vm.currentQuestion!),
            const Gap(12),
          ],

          // Score result
          if (vm.lastResult != null && vm.session?.status != InterviewStatus.userAnswering) ...[
            ScoreIndicator(result: vm.lastResult!).animate().slideY(


              begin: 0.2,
              duration: 500.ms,
              curve: Curves.easeOut,
            ),
            const Gap(8),
          ],

          // Voice recorder
          if (vm.session?.status == InterviewStatus.userAnswering) ...[
            WaveformRecorder(
              isListening: vm.isListening,
              transcript: vm.partialTranscript.isNotEmpty
                  ? vm.partialTranscript
                  : vm.finalTranscript,
              onStop: () => vm.stopListening(),
              onSkip: () => vm.skipQuestion(),
              onRetry: () => vm.retryListening(),
            ).animate().fadeIn(duration: 400.ms),
            const Gap(8),
          ],

          // Evaluating spinner
          if (vm.isEvaluating)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Color(0xFF4F46E5),
                      strokeWidth: 2,
                    ),
                  ),
                  Gap(12),
                  Text('Evaluating your answer...', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),

          const Gap(20),
        ],
      ),
    );
  }

  // ─── Progress Bar ─────────────────────────────────────────────────────────
  Widget _buildProgressBar(MockInterviewViewModel vm) {
    final progress = vm.session?.progressPercent ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation(Color(0xFF4F46E5)),
        ),
      ),
    );
  }

  // ─── Subtitle ─────────────────────────────────────────────────────────────
  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ─── Question Card ────────────────────────────────────────────────────────
  Widget _buildQuestionCard(InterviewQuestion q) {
    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4F46E5).withValues(alpha: 0.15),
              const Color(0xFF1E293B),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SkillBadge(skill: q.skill),
                const Spacer(),
                _DifficultyBadge(difficulty: q.difficulty),
              ],
            ),
            const Gap(12),
            Text(
              q.questionText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const Gap(8),
            Text(
              'Category: ${q.category}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Exit Interview?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your progress will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              if (widget.onExit != null) {
                widget.onExit!();
              } else {
                Navigator.pop(context); // Fallback to pop screen
              }
            },
            child: const Text('Exit', style: TextStyle(color: Colors.redAccent)),
          ),

        ],
      ),
    );
  }
}

class _SkillBadge extends StatelessWidget {
  final String skill;
  const _SkillBadge({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(skill, style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  Color get _color => switch (difficulty) {
    'advanced' => const Color(0xFFFF6B6B),
    'intermediate' => const Color(0xFFFFD700),
    _ => const Color(0xFF00C896),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty[0].toUpperCase() + difficulty.substring(1),
        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
