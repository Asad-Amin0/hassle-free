import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/interview_question.dart';

/// Connects to your Node.js RAG backend (index__1_.js style server)
/// or falls back to built-in professional question bank.
class RagQuestionService {
  // Your Node.js RAG backend URL — update this
  static const String _backendUrl = 'http://localhost:3000';

  // ─── Built-in Professional Question Bank (RAG fallback) ───────────────────
  // These are stored here in the app so the interview always works offline.
  // In production, these come from your /ragAsk endpoint.
  static final Map<String, List<Map<String, dynamic>>> _questionBank = {
    'flutter': [
      {
        'id': 'fl_001',
        'question': 'Explain the difference between StatelessWidget and StatefulWidget in Flutter, and when you would choose one over the other.',
        'idealAnswer': 'StatelessWidget is immutable — it has no mutable state and rebuilds only when its parent passes new configuration. StatefulWidget maintains a mutable State object that can call setState() to trigger a rebuild. Use StatelessWidget for UI that only depends on its constructor parameters (e.g. a styled text label). Use StatefulWidget when the widget needs to change over time, respond to user input, or maintain local state like form fields, animations, or toggles.',
        'keyPhrases': ['immutable', 'mutable', 'setState', 'rebuild', 'State object', 'constructor parameters'],
        'skill': 'Flutter',
        'difficulty': 'intermediate',
        'category': 'technical',
        'facialExpression': 'smile',
        'avatarAnimation': 'Talking_0',
      },
      {
        'id': 'fl_002',
        'question': 'What is the Widget tree in Flutter and how does the rendering pipeline work?',
        'idealAnswer': 'Flutter has three trees: Widget tree (immutable description of UI), Element tree (mutable instances managing state and lifecycle), and Render tree (handles layout and painting). Widgets are lightweight blueprints. When setState is called, Flutter diffs the widget tree, updates the element tree selectively, and repaints only dirty render objects. This makes Flutter fast even with complex UIs because full tree rebuilds are cheap — only painting is expensive.',
        'keyPhrases': ['Widget tree', 'Element tree', 'Render tree', 'setState', 'diff', 'layout', 'painting', 'immutable'],
        'skill': 'Flutter',
        'difficulty': 'advanced',
        'category': 'technical',
        'facialExpression': 'curious',
        'avatarAnimation': 'Talking_1',
      },
      {
        'id': 'fl_003',
        'question': 'Describe the Provider pattern in Flutter and explain how it compares to Riverpod or BLoC.',
        'idealAnswer': 'Provider is an InheritedWidget wrapper that allows dependency injection and state sharing down the widget tree via ChangeNotifier. It is simple and Flutter-idiomatic. Riverpod improves on Provider by removing context dependency, supporting compile-time safety, and allowing providers to be declared globally. BLoC separates business logic from UI using streams — input events go in, states come out — following strict unidirectional data flow. Provider is great for small apps; BLoC scales better for complex enterprise apps; Riverpod balances both.',
        'keyPhrases': ['InheritedWidget', 'ChangeNotifier', 'context', 'streams', 'BLoC', 'unidirectional', 'Riverpod', 'dependency injection'],
        'skill': 'Flutter',
        'difficulty': 'advanced',
        'category': 'technical',
        'facialExpression': 'smile',
        'avatarAnimation': 'Talking_2',
      },
    ],
    'dart': [
      {
        'id': 'dt_001',
        'question': 'What are Futures and Streams in Dart? Explain async/await and how you handle errors.',
        'idealAnswer': 'A Future represents a single asynchronous value that will be available at some point. A Stream is a sequence of asynchronous events over time. async/await makes asynchronous code look synchronous — await pauses execution until the Future completes. Error handling uses try-catch with await, or .catchError() on a Future chain. Streams can be listened to with await for loops and support transformations via map, where, and expand operators.',
        'keyPhrases': ['Future', 'Stream', 'async', 'await', 'try-catch', 'asynchronous', 'catchError'],
        'skill': 'Dart',
        'difficulty': 'intermediate',
        'category': 'technical',
        'facialExpression': 'curious',
        'avatarAnimation': 'Talking_0',
      },
    ],
    'firebase': [
      {
        'id': 'fb_001',
        'question': 'How does Firestore real-time listening work and what are its performance considerations?',
        'idealAnswer': 'Firestore uses persistent WebSocket connections to push document and collection changes to clients in real-time. You attach a listener using snapshots() stream in Flutter. For performance: always detach listeners (cancel StreamSubscription) when widgets dispose, use query cursors for pagination instead of fetching large collections, index composite queries in Firebase Console, and limit listener scope to only the documents the UI currently needs. Reads are billed per document, so avoid over-fetching.',
        'keyPhrases': ['WebSocket', 'snapshots', 'StreamSubscription', 'cancel', 'pagination', 'composite index', 'query cursors', 'billing'],
        'skill': 'Firebase',
        'difficulty': 'intermediate',
        'category': 'technical',
        'facialExpression': 'smile',
        'avatarAnimation': 'Talking_1',
      },
    ],
    'general': [
      {
        'id': 'gen_001',
        'question': 'Tell me about a challenging technical problem you faced and how you solved it.',
        'idealAnswer': 'A strong answer uses the STAR format: Situation (context of the project), Task (your specific responsibility), Action (the exact steps you took — debugging approach, tools used, colleagues consulted), and Result (measurable outcome — time saved, bugs fixed, performance improved). Emphasize your problem-solving process: how you isolated the issue, what you tried first, how you adapted when that failed, and what you learned.',
        'keyPhrases': ['STAR', 'situation', 'task', 'action', 'result', 'problem-solving', 'debugging', 'outcome'],
        'skill': 'Behavioral',
        'difficulty': 'intermediate',
        'category': 'behavioral',
        'facialExpression': 'curious',
        'avatarAnimation': 'Talking_2',
      },
      {
        'id': 'gen_002',
        'question': 'How do you approach learning a new technology or framework quickly?',
        'idealAnswer': 'Effective rapid learning follows a sequence: start with the official documentation overview to understand the mental model, then build a minimal working project (not just copy tutorials), identify the three most common patterns used in production, read source code of popular open-source projects using the technology, and deliberately practice edge cases. Teaching concepts back by writing a blog post or explaining to a teammate accelerates retention. Time-box exploration to avoid rabbit holes.',
        'keyPhrases': ['documentation', 'minimal project', 'patterns', 'source code', 'deliberate practice', 'teaching', 'time-box'],
        'skill': 'Behavioral',
        'difficulty': 'beginner',
        'category': 'behavioral',
        'facialExpression': 'smile',
        'avatarAnimation': 'Talking_0',
      },
    ],
    'rest_api': [
      {
        'id': 'api_001',
        'question': 'Explain REST API principles and how you handle authentication in a Flutter app.',
        'idealAnswer': 'REST (Representational State Transfer) is stateless — each request must contain all information needed to process it. Key constraints: uniform interface (standard HTTP verbs GET/POST/PUT/DELETE), statelessness, client-server separation, cacheability, and layered system. In Flutter, authentication is typically handled with JWT tokens: the login endpoint returns an access token and refresh token; the access token is stored in flutter_secure_storage (not SharedPreferences, which is insecure); every subsequent request includes Authorization: Bearer <token> in headers; the Dio interceptor automatically refreshes expired tokens using the refresh token.',
        'keyPhrases': ['stateless', 'GET', 'POST', 'PUT', 'DELETE', 'JWT', 'access token', 'refresh token', 'flutter_secure_storage', 'interceptor', 'Authorization header'],
        'skill': 'REST APIs',
        'difficulty': 'intermediate',
        'category': 'technical',
        'facialExpression': 'smile',
        'avatarAnimation': 'Talking_1',
      },
    ],
    'oop': [
      {
        'id': 'oop_001',
        'question': 'Explain the four pillars of OOP with Dart examples.',
        'idealAnswer': 'Encapsulation: bundling data and methods, hiding internals with private fields (underscore prefix in Dart). Abstraction: exposing only necessary interfaces via abstract classes or interfaces. Inheritance: a class extending another to reuse and override behavior (extends keyword in Dart). Polymorphism: the same interface behaving differently — method overriding, or implementing the same interface in multiple classes. In Dart, mixins add another form of code reuse without inheritance hierarchy.',
        'keyPhrases': ['encapsulation', 'abstraction', 'inheritance', 'polymorphism', 'abstract', 'extends', 'override', 'mixin', 'private'],
        'skill': 'OOP',
        'difficulty': 'beginner',
        'category': 'technical',
        'facialExpression': 'smile',
        'avatarAnimation': 'Talking_0',
      },
    ],
  };

  /// Fetches questions from RAG backend. Falls back to built-in bank if backend unavailable.
  Future<List<InterviewQuestion>> getQuestionsForSession({
    required String jobRole,
    required List<String> userSkills,
    int count = 7,
  }) async {
    // Try RAG backend first
    try {
      return await _fetchFromBackend(jobRole: jobRole, skills: userSkills, count: count);
    } catch (e) {
      debugPrint('[RagQuestionService] Backend unavailable, using local bank: $e');
      return _getFromLocalBank(skills: userSkills, count: count);
    }
  }

  Future<List<InterviewQuestion>> _fetchFromBackend({
    required String jobRole,
    required List<String> skills,
    required int count,
  }) async {
    final response = await http.post(
      Uri.parse('$_backendUrl/generateInterviewQuestions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jobRole': jobRole,
        'skills': skills,
        'count': count,
        'sessionId': 'session_${DateTime.now().millisecondsSinceEpoch}',
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> questionsJson = data['questions'] ?? [];
      return questionsJson.map((q) => InterviewQuestion.fromJson(q)).toList();
    }
    throw Exception('Backend returned ${response.statusCode}');
  }

  List<InterviewQuestion> _getFromLocalBank({
    required List<String> skills,
    required int count,
  }) {
    final List<InterviewQuestion> selected = [];

    // Map user skills to question bank keys
    final skillKeys = _mapSkillsToKeys(skills);

    // Pick questions per skill
    for (final key in skillKeys) {
      final questions = _questionBank[key] ?? [];
      for (final q in questions) {
        if (selected.length < count) {
          selected.add(InterviewQuestion.fromJson({...q, 'ragConfidence': 0.9}));
        }
      }
    }

    // Fill remainder with general/behavioral questions
    if (selected.length < count) {
      final general = _questionBank['general'] ?? [];
      for (final q in general) {
        if (selected.length < count) {
          selected.add(InterviewQuestion.fromJson({...q, 'ragConfidence': 0.85}));
        }
      }
    }

    // Shuffle for variety
    selected.shuffle();
    return selected.take(count).toList();
  }

  List<String> _mapSkillsToKeys(List<String> skills) {
    final keyMap = {
      'flutter': 'flutter',
      'dart': 'dart',
      'firebase': 'firebase',
      'rest': 'rest_api',
      'api': 'rest_api',
      'http': 'rest_api',
      'oop': 'oop',
      'object': 'oop',
      'general': 'general',
    };

    final keys = <String>[];
    for (final skill in skills) {
      final lower = skill.toLowerCase();
      for (final entry in keyMap.entries) {
        if (lower.contains(entry.key) && !keys.contains(entry.value)) {
          keys.add(entry.value);
        }
      }
    }

    if (keys.isEmpty) keys.addAll(['general', 'oop']);
    return keys;
  }
}
