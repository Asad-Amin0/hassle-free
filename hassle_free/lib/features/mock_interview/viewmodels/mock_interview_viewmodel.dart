import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/interview_question.dart';
import '../models/interview_session.dart';
import '../models/interview_result.dart';
import '../models/avatar_state.dart';
import '../services/rag_question_service.dart';
import '../services/answer_evaluation_service.dart';
import '../services/tts_service.dart';
import '../services/speech_service.dart';
import '../services/lipsync_service.dart';
import '../../../services/job_service.dart';

class MockInterviewViewModel extends ChangeNotifier {
  final RagQuestionService _ragService = RagQuestionService();
  final AnswerEvaluationService _evalService = AnswerEvaluationService();
  final TtsService _ttsService = TtsService();
  final SpeechService _speechService = SpeechService();
  final LipSyncService _lipSyncService = LipSyncService();

  // ─── State ────────────────────────────────────────────────────────────────
  InterviewSession? _session;
  AvatarState _avatarState = const AvatarState();
  String _partialTranscript = '';
  String _finalTranscript = '';
  bool _isLoading = false;
  bool _isEvaluating = false;
  String? _jobId;
  InterviewResult? _lastResult;
  String? _error;
  int _remainingSeconds = 30;
  Timer? _countdownTimer;
  final ValueNotifier<String> _phonemeNotifier = ValueNotifier<String>('X');
  Timer? _lipSyncTimer;
  double _lipSyncTime = 0.0;
  List<LipSyncFrame> _currentFrames = [];


  void reset() {
    _session = null;
    _isEvaluating = false;
    _lastResult = null;
    _error = null;
    _partialTranscript = '';
    _finalTranscript = '';
    _phonemeNotifier.value = 'X';
  }



  // ─── Getters ──────────────────────────────────────────────────────────────
  InterviewSession? get session => _session;
  AvatarState get avatarState => _avatarState;
  String get partialTranscript => _partialTranscript;
  String get finalTranscript => _finalTranscript;
  ValueNotifier<String> get phonemeNotifier => _phonemeNotifier;
  bool get isLoading => _isLoading;
  bool get isEvaluating => _isEvaluating;
  bool get isListening => _speechService.isListening;
  InterviewResult? get lastResult => _lastResult;
  String? get error => _error;
  int get remainingSeconds => _remainingSeconds;
  bool get isCompleted => _session?.isCompleted ?? false;
  InterviewQuestion? get currentQuestion => _session?.currentQuestion;
  List<InterviewResult> get allResults => _session?.results ?? [];

  // ─── Initialize Session ───────────────────────────────────────────────────
  Future<void> startSession({
    required String userId,
    required String jobRole,
    required List<String> skills,
    String? jobId,
    int questionCount = 7,
  }) async {
    reset(); // Clear previous session state
    _jobId = jobId;
    _isLoading = true;
    _error = null;
    notifyListeners();


    try {
      final questions = await _ragService.getQuestionsForSession(
        jobRole: jobRole,
        userSkills: skills,
        count: questionCount,
      );

      _session = InterviewSession(
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        jobRole: jobRole,
        skills: skills,
        questions: questions,
        results: [],
        startedAt: DateTime.now(),
      );

      _session!.status = InterviewStatus.inProgress;
      _isLoading = false;
      notifyListeners();

      // Avatar greets and asks first question
      await _avatarIntroduction(jobRole);
      await Future.delayed(const Duration(milliseconds: 200));
      await _askCurrentQuestion();
    } catch (e) {
      _error = 'Failed to start interview: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Avatar Introduction ──────────────────────────────────────────────────
  Future<void> _avatarIntroduction(String jobRole) async {
    final intro = 'Welcome to your AI mock interview for the $jobRole position. '
        'I will ask you ${_session!.totalQuestions} questions. '
        'Please speak your answer clearly after each question. Let\'s begin.';

    await _avatarSpeak(
      text: intro,
      mood: AvatarMood.happy,
      animation: 'talking',
      facialExpression: 'smile',
    );
  }

  // ─── Ask Current Question ─────────────────────────────────────────────────
  Future<void> _askCurrentQuestion() async {
    final question = _session?.currentQuestion;
    if (question == null) return;

    _session!.status = InterviewStatus.avatarSpeaking;
    _lastResult = null;
    _partialTranscript = '';
    _finalTranscript = '';
    notifyListeners();

    final questionPrefix = 'Question ${(_session!.currentQuestionIndex + 1)} of '
        '${_session!.totalQuestions}. ';

    await _avatarSpeak(
      text: questionPrefix + question.questionText,
      mood: AvatarMood.talking,
      animation: question.avatarAnimation,
      facialExpression: question.facialExpression,
    );

    // After avatar finishes speaking, start listening
    await Future.delayed(const Duration(milliseconds: 200));
    await _startListening();
  }

  // ─── Avatar Speak (with lip-sync) ─────────────────────────────────────────
  Future<void> _avatarSpeak({
    required String text,
    AvatarMood mood = AvatarMood.talking,
    String animation = 'talking',
    String facialExpression = 'default',
  }) async {
    _currentFrames = _lipSyncService.generateFrames(text);
    _lipSyncTime = 0.0;

    _avatarState = AvatarState(
      mood: mood,
      animation: animation,
      facialExpression: facialExpression,
      currentText: text,
      lipSyncFrames: _currentFrames,
      isSpeaking: true,
    );
    notifyListeners();

    // Start lip-sync timer
    _lipSyncTimer?.cancel();
    _lipSyncTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _lipSyncTime += 0.05;
      _phonemeNotifier.value = _lipSyncService.getPhonemeAt(_currentFrames, _lipSyncTime);
    });

    await _ttsService.speak(text);


    _lipSyncTimer?.cancel();
    _phonemeNotifier.value = 'X';
    _avatarState = _avatarState.copyWith(
      mood: AvatarMood.idle,
      animation: 'idle',
      facialExpression: 'default',
      isSpeaking: false,
    );
    notifyListeners();
  }

  // ─── Start Listening ──────────────────────────────────────────────────────
  Future<void> _startListening() async {
    _session?.status = InterviewStatus.userAnswering;
    _avatarState = _avatarState.copyWith(
      mood: AvatarMood.listening,
      animation: 'Idle',
      facialExpression: 'default',
    );
    _remainingSeconds = 30; // Reset timer for new question
    notifyListeners();

    _startCountdown();

    final success = await _speechService.startListening(
      onPartial: (partial) {
        _partialTranscript = partial;
        notifyListeners();
      },
      onFinal: (final_) {
        _finalTranscript = final_;
        _partialTranscript = '';
        notifyListeners();
        // Removed auto-submit on every onFinal to prevent cutting off users.
        // Users now use the 'Submit Answer' button for full control.
        // Or we could add a longer silence timer if needed.
      },
      listenFor: const Duration(seconds: 90),
      pauseFor: const Duration(seconds: 10),
    );


    if (!success) {
      _countdownTimer?.cancel();
      _error = 'Microphone not detected. Please ensure you have allowed microphone access in your browser and are using a secure connection (HTTPS or localhost).';
      notifyListeners();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        stopListening(); // Auto-submit when time is up
      }
    });
  }


  // ─── Manual Stop Listening ────────────────────────────────────────────────
  Future<void> stopListening() async {
    await _speechService.stopListening();
    if (_finalTranscript.isEmpty && _partialTranscript.isNotEmpty) {
      _finalTranscript = _partialTranscript;
    }
    // Always submit, even if empty, to ensure interview moves forward
    await submitAnswer(_finalTranscript);
  }

  // ─── Submit & Evaluate Answer ─────────────────────────────────────────────
  Future<void> submitAnswer(String answer) async {
    final question = _session?.currentQuestion;
    if (question == null || _isEvaluating) return;

    _countdownTimer?.cancel(); // Stop timer when answer is submitted
    await _speechService.cancelListening();
    _isEvaluating = true;

    _session!.status = InterviewStatus.evaluating;

    // Avatar thinks while evaluating
    _avatarState = _avatarState.copyWith(
      mood: AvatarMood.thinking,
      animation: 'Idle',
      facialExpression: 'default',
    );
    notifyListeners();

    try {
      final result = await _evalService.evaluate(
        question: question,
        userAnswer: answer.trim().isEmpty ? '(No answer provided)' : answer,
      );

      _lastResult = result;
      _session!.results.add(result);
      _session!.totalPoints += result.points;
      _isEvaluating = false;
      notifyListeners();

      // Avatar gives feedback
      await _avatarGiveFeedback(result);

    } catch (e) {
      _error = 'Evaluation error: $e';
      _isEvaluating = false;
      notifyListeners();
    }
  }

  // ─── Avatar Gives Feedback ────────────────────────────────────────────────
  Future<void> _avatarGiveFeedback(InterviewResult result) async {
    final mood = result.passed ? AvatarMood.happy : AvatarMood.concerned;
    final expression = result.passed ? 'smile' : 'sad';
    final animation = 'talking';

    await _avatarSpeak(
      text: result.encouragement,
      mood: mood,
      animation: animation,
      facialExpression: expression,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    // Advance to next question or finish
    _session!.currentQuestionIndex++;
    notifyListeners();

    if (_session!.isCompleted) {
      await _completeInterview();
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      await _askCurrentQuestion();
    }
  }

  // ─── Complete Interview ───────────────────────────────────────────────────
  Future<void> _completeInterview() async {
    _session!.status = InterviewStatus.completed;
    _session!.completedAt = DateTime.now();
    notifyListeners();

    final avg = _session!.overallScore;
    String closingText;
    if (avg >= 0.75) {
      closingText = 'Fantastic work! Your overall score is ${(avg * 100).round()} percent. '
          'You performed excellently. Best of luck with your actual interview!';
    } else if (avg >= 0.5) {
      closingText = 'Good effort! Your score is ${(avg * 100).round()} percent. '
          'Review the feedback for each question and keep practicing. You\'ve got this!';
    } else {
      closingText = 'Thank you for completing the interview. Your score is ${(avg * 100).round()} percent. '
          'Don\'t be discouraged — review the ideal answers and practice again. You\'ll improve!';
    }

    await _avatarSpeak(
      text: closingText,
      mood: avg >= 0.6 ? AvatarMood.happy : AvatarMood.concerned,
      animation: 'talking',
      facialExpression: avg >= 0.6 ? 'smile' : 'default',
    );

    // Save to Firestore if linked to a job application
    if (_jobId != null && _session != null) {
      try {
        await JobService().saveInterviewResult(
          jobId: _jobId!,
          seekerId: _session!.userId,
          resultData: _session!.toMap(),
        );
      } catch (e) {
        debugPrint('Error auto-saving interview result: $e');
      }
    }
  }

  // ─── Skip Question ────────────────────────────────────────────────────────
  Future<void> skipQuestion() async {
    await _speechService.stopListening();
    await submitAnswer('(Skipped)');
  }

  // ─── End Interview ────────────────────────────────────────────────────────
  Future<void> endInterview() async {
    _isEvaluating = false; // Force stop evaluation
    
    // 1. Stop everything first (including voice)
    await stopAll();
    
    // 2. Then update status to navigate
    if (_session != null) {
      _session!.status = InterviewStatus.completed;
      _session!.completedAt = DateTime.now();
      notifyListeners();
    }
  }

  // ─── Retry Current Question ────────────────────────────────────────────────
  Future<void> retryListening() async {
    _partialTranscript = '';
    _finalTranscript = '';
    _lastResult = null;
    notifyListeners();
    // Force re-init to clear any browser-level speech recognition hangs
    await _speechService.init(force: true);
    await _startListening();
  }

  // ─── Current Lip-Sync Phoneme ─────────────────────────────────────────────
  String get currentPhoneme => _phonemeNotifier.value;

  // ─── Stop All Activities ──────────────────────────────────────────────────
  Future<void> stopAll() async {
    _lipSyncTimer?.cancel();
    _countdownTimer?.cancel();
    
    // Force stop speech and listening immediately
    await _ttsService.stop();
    await _speechService.stopListening();

    // Update state to standstill
    _avatarState = const AvatarState(
      mood: AvatarMood.idle,
      animation: 'Idle',
      facialExpression: 'default',
      currentText: '',
      isSpeaking: false,
    );
    _phonemeNotifier.value = 'X';
    notifyListeners();
  }

  @override

  void dispose() {
    _lipSyncTimer?.cancel();
    _countdownTimer?.cancel();
    _ttsService.dispose();
    _speechService.dispose();
    super.dispose();
  }
}
