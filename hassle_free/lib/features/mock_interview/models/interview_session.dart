import 'interview_question.dart';
import 'interview_result.dart';

enum InterviewStatus { notStarted, inProgress, avatarSpeaking, userAnswering, evaluating, completed }

class InterviewSession {
  final String sessionId;
  final String userId;
  final String jobRole;
  final List<String> skills;           // Skills pulled from parsed resume
  final List<InterviewQuestion> questions;
  final List<InterviewResult> results;
  int currentQuestionIndex;
  InterviewStatus status;
  int totalPoints;
  DateTime startedAt;
  DateTime? completedAt;

  InterviewSession({
    required this.sessionId,
    required this.userId,
    required this.jobRole,
    required this.skills,
    required this.questions,
    this.results = const [],
    this.currentQuestionIndex = 0,
    this.status = InterviewStatus.notStarted,
    this.totalPoints = 0,
    required this.startedAt,
    this.completedAt,
  });

  int get totalQuestions => questions.length;
  bool get isCompleted => currentQuestionIndex >= totalQuestions;
  double get progressPercent =>
      totalQuestions == 0 ? 0 : currentQuestionIndex / totalQuestions;

  InterviewQuestion? get currentQuestion =>
      currentQuestionIndex < questions.length ? questions[currentQuestionIndex] : null;

  double get overallScore =>
      results.isEmpty ? 0 : results.map((r) => r.score).reduce((a, b) => a + b) / results.length;
}
