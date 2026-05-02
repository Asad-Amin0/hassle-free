class InterviewQuestion {
  final String id;
  final String questionText;
  final String idealAnswer;         // RAG-retrieved ideal answer
  final List<String> keyPhrases;    // Keywords to match in user's answer
  final String skill;               // e.g. "Flutter", "REST APIs", "OOP"
  final String difficulty;          // "beginner" | "intermediate" | "advanced"
  final String category;            // "technical" | "behavioral" | "situational"
  final double ragConfidence;       // How confident the RAG system is in ideal answer
  final List<String> ragSources;    // Source chunks used to build ideal answer
  final String facialExpression;    // Avatar expression: "smile"|"serious"|"curious"
  final String avatarAnimation;     // Avatar animation: "talking"|"idle"

  const InterviewQuestion({
    required this.id,
    required this.questionText,
    required this.idealAnswer,
    required this.keyPhrases,
    required this.skill,
    this.difficulty = 'intermediate',
    this.category = 'technical',
    this.ragConfidence = 0.8,
    this.ragSources = const [],
    this.facialExpression = 'smile',
    this.avatarAnimation = 'talking',
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      id: json['id'] ?? '',
      questionText: json['question'] ?? json['questionText'] ?? '',
      idealAnswer: json['idealAnswer'] ?? json['answer'] ?? '',
      keyPhrases: List<String>.from(json['keyPhrases'] ?? json['key_phrases'] ?? []),
      skill: json['skill'] ?? '',
      difficulty: json['difficulty'] ?? 'intermediate',
      category: json['category'] ?? 'technical',
      ragConfidence: (json['confidence'] ?? json['ragConfidence'] ?? 0.8).toDouble(),
      ragSources: List<String>.from(json['sources'] ?? json['ragSources'] ?? []),
      facialExpression: json['facialExpression'] ?? 'smile',
      avatarAnimation: json['avatarAnimation'] ?? 'talking',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'questionText': questionText,
    'idealAnswer': idealAnswer,
    'keyPhrases': keyPhrases,
    'skill': skill,
    'difficulty': difficulty,
    'category': category,
    'ragConfidence': ragConfidence,
    'ragSources': ragSources,
    'facialExpression': facialExpression,
    'avatarAnimation': avatarAnimation,
  };
}
