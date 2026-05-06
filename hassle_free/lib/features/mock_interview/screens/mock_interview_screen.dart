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
  final bool isDarkMode;
  final String? jobId;
  final VoidCallback? onExit;

  const MockInterviewScreen({
    super.key,
    required this.userId,
    required this.jobRole,
    required this.skills,
    this.isDarkMode = true,
    this.jobId,
    this.onExit,
  });


  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  bool _navigatedToResults = false;

  Color get _bgColor => widget.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get _textColor => widget.isDarkMode ? Colors.white : Colors.black87;
  Color get _cardBorder => widget.isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300;
  Color get _mutedText => widget.isDarkMode ? Colors.white70 : Colors.black54;

  @override

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Manual start required
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
      backgroundColor: _bgColor,
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
                        jobId: widget.jobId,
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
                      : (vm.session == null ? _buildStartScreen(vm) : _buildInterviewBody(vm)),
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
                color: _cardBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.close, color: _mutedText, size: 20),
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
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (session != null)
                  Text(
                    'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
                    style: TextStyle(color: _mutedText, fontSize: 12),
                  ),
              ],
            ),
          ),

          // End Interview button
          if (session != null && session.status != InterviewStatus.completed)
            TextButton.icon(
              onPressed: () => _confirmEndInterview(vm),
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent, size: 18),
              label: const Text('End', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          const SizedBox(width: 8),

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

  // ─── Start Screen ──────────────────────────────────────────────────────────
  Widget _buildStartScreen(MockInterviewViewModel vm) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_none_rounded, color: Color(0xFF4F46E5), size: 60),
            ),
            const Gap(32),
            Text(
              'Ready to begin?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textColor),
            ),
            const Gap(16),
            Text(
              'Your AI interviewer is ready to evaluate your skills in ${widget.jobRole}.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedText, fontSize: 16, height: 1.5),
            ),
            const Gap(40),
            SizedBox(
              width: 240,
              height: 60,
              child: ElevatedButton(
                onPressed: () => vm.startSession(
                  userId: widget.userId,
                  jobRole: widget.jobRole,
                  skills: widget.skills,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                  shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded),
                    Gap(8),
                    Text('Start Interview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Gap(24),
            Text(
              'Ensure you are in a quiet environment.',
              style: TextStyle(color: _mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, curve: Curves.easeOut);
  }

  // ─── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFF4F46E5)),
          const Gap(20),
          Text(
            'Preparing your interview questions\nusing AI & RAG system...',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedText, fontSize: 14),
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
                style: TextStyle(color: _textColor, fontSize: 14),
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
            const Gap(16),
            
            // Countdown Timer Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: (vm.remainingSeconds <= 5 ? Colors.redAccent : _textColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (vm.remainingSeconds <= 5 ? Colors.redAccent : const Color(0xFF4F46E5)).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: vm.remainingSeconds <= 5 ? Colors.redAccent : const Color(0xFF4F46E5),
                  ),
                  const Gap(8),
                  Text(
                    'Time remaining: ${vm.remainingSeconds}s',
                    style: TextStyle(
                      color: vm.remainingSeconds <= 5 ? Colors.redAccent : _textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate(target: vm.remainingSeconds <= 5 ? 1 : 0).shake(hz: 4, curve: Curves.easeInOut),
            const Gap(8),
          ],

          // Evaluating spinner
          if (vm.isEvaluating)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Color(0xFF4F46E5),
                      strokeWidth: 2,
                    ),
                  ),
                  const Gap(12),
                  Text('Evaluating your answer...', style: TextStyle(color: _mutedText)),
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
          backgroundColor: _cardBorder,
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

  void _confirmEndInterview(MockInterviewViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('End Interview?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to end the interview now? You will see results for the questions you have completed.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Interview'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.endInterview();
            },
            child: const Text('End Now', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
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
