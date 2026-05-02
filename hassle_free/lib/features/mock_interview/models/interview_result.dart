class InterviewResult {
  final String questionId;
  final String questionText;
  final String userAnswer;
  final String idealAnswer;
  final double score;               // 0.0 – 1.0
  final List<String> matchedPhrases;
  final List<String> missedPhrases;
  final String feedback;
  final String encouragement;
  final bool passed;                // score >= 0.6 = passed
  final DateTime answeredAt;

  const InterviewResult({
    required this.questionId,
    required this.questionText,
    required this.userAnswer,
    required this.idealAnswer,
    required this.score,
    required this.matchedPhrases,
    required this.missedPhrases,
    required this.feedback,
    required this.encouragement,
    required this.passed,
    required this.answeredAt,
  });

  int get points => (score * 10).round();

  factory InterviewResult.fromJson(Map<String, dynamic> json) {
    return InterviewResult(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      idealAnswer: json['idealAnswer'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      matchedPhrases: List<String>.from(json['matchedPhrases'] ?? []),
      missedPhrases: List<String>.from(json['missedPhrases'] ?? []),
      feedback: json['feedback'] ?? '',
      encouragement: json['encouragement'] ?? '',
      passed: json['passed'] ?? false,
      answeredAt: json['answeredAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['answeredAt'])
          : DateTime.now(),
    );
  }
}
