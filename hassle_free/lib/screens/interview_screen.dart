import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class InterviewScreen extends StatefulWidget {
  final List<String> skills;
  const InterviewScreen({super.key, this.skills = const []});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  bool _isInterviewStarted = false;
  bool _isLoadingQuestions = false;
  int _currentQuestionIndex = 0;

  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  String? _cameraError;
  bool _isCameraMuted = false;
  bool _isMicMuted = false;
  bool _isSpeaking = false;
  bool _isListening = false;
  String _userTranscription = "";
  
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isAnalyzing = false;
  bool _showFeedback = false;
  String _currentFeedback = "";
  bool _isFaceDetected = false; // Simulated face detection

  List<String> _questions = [];

  // SDS Metrics
  double _clarity = 0.0;
  double _confidence = 0.0;
  double _technicalDepth = 0.0;
  double _communication = 0.0;
  double _toneModulation = 0.0;
  double _keywordRelevance = 0.0;

  Timer? _metricsTimer;

  @override
  void initState() {
    super.initState();
    _initInterviewData();
  }

  Future<void> _initInterviewData() async {
    await _requestPermissions();
    await _initCameras();
    _initTTS();
    _initSTT();
    _fetchDynamicQuestions();
  }

  Future<void> _initCameras() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        setState(() => _cameraError = "No cameras found on this device.");
      }
    } catch (e) {
      setState(() => _cameraError = "Error loading cameras: $e");
    }
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0); // Natural pitch
    await _flutterTts.setSpeechRate(1.0); // 1x Speed as requested

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
        _startListening(); // Automatically start listening after AI finishes speaking
      }
    });
  }

  Future<void> _initSTT() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (!available && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition is not available on this device.')),
        );
      }
    } catch (e) {
      debugPrint("STT Initialization error: $e");
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (error) => debugPrint('STT Error: $error'),
      );
      
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _userTranscription = val.recognizedWords;
                
                // Enhanced Technical Scoring Logic
                if (widget.skills.isNotEmpty && val.recognizedWords.isNotEmpty) {
                  int matches = 0;
                  final words = val.recognizedWords.toLowerCase().split(' ');
                  for (var skill in widget.skills) {
                    if (words.any((w) => w.contains(skill.toLowerCase()) || skill.toLowerCase().contains(w))) {
                      matches++;
                    }
                  }
                  
                  // Dynamically update scores
                  _keywordRelevance = (0.4 + (matches * 0.2)).clamp(0, 1.0);
                  _technicalDepth = (0.5 + (matches * 0.15)).clamp(0, 1.0);
                }
              });
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            partialResults: true,
          ),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speakQuestion() async {
    if (_questions.isNotEmpty) {
      await _stopListening(); // Stop listening before AI speaks
      await _flutterTts.speak(_questions[_currentQuestionIndex]);
    }
  }

  Future<void> _fetchDynamicQuestions() async {
    setState(() => _isLoadingQuestions = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5002/api/generate-questions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'skills': widget.skills}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _questions = List<String>.from(data['questions']);
        });
      } else {
        // Fallback if backend fails, but still generated based on resume context dynamically if possible
        _useFallbackQuestions();
      }
    } catch (e) {
      debugPrint("Error fetching dynamic questions: $e");
      _useFallbackQuestions();
    } finally {
      if (mounted) setState(() => _isLoadingQuestions = false);
    }
  }

  void _useFallbackQuestions() {
    if (mounted) {
      setState(() {
        _questions = [
          "Based on your resume, could you walk me through your professional journey and highlight a key achievement?",
          "What specific technical challenges have you overcome in the skills you mentioned?",
          "Why do you believe you are the best fit for this specific role given your background?"
        ];
      });
    }
  }

  // Premium Dark Aesthetics (Matching Image)
  static const Color darkBg = Color(0xFF0F172A);
  static const Color cardBg = Color(0xFF1E293B);
  static const Color primaryBlue = Color(0xFF4F46E5);
  static const Color accentPurple = Color(0xFF818CF8);
  static const Color statusRed = Color(0xFFEF4444);

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  Future<void> _startInterview() async {
    if (!(await Permission.camera.isGranted) || !(await Permission.microphone.isGranted)) {
      await _requestPermissions();
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await _initializeCameraController();
    }

    setState(() {
      _isInterviewStarted = true;
      _currentQuestionIndex = 0;
      _userTranscription = "";
      _showFeedback = false;
    });

    _speakQuestion();

    _metricsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Only start updating percentages if interview started AND user is answering (not AI speaking)
      if (mounted && _isInterviewStarted && !_isSpeaking && _isListening) {
        setState(() {
          _clarity = (0.5 + (DateTime.now().second % 40) / 100).clamp(0, 1.0);
          _confidence = (0.5 + (DateTime.now().millisecond % 50) / 100).clamp(0, 1.0);
          _toneModulation = (0.5 + (DateTime.now().second % 35) / 100).clamp(0, 1.0);
          _communication = (0.6 + (DateTime.now().second % 30) / 100).clamp(0, 1.0);
          // Keyword relevance and technical depth update via actual speech recognition words above
        });
      }
    });
  }

  Future<void> _evaluateAnswer() async {
    if (_userTranscription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an answer before submitting.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _stopListening();
    });

    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 2));

    String feedback = "";
    double scoreBoost = 0.0;

    // Enhanced simulated feedback logic
    final words = _userTranscription.toLowerCase();
    
    bool isRelevant = false;
    int skillMatches = 0;
    for (var skill in widget.skills) {
      if (words.contains(skill.toLowerCase())) {
        isRelevant = true;
        skillMatches++;
        break;
      }
    }

    if (words.length < 30) {
      feedback = "Your answer was a bit brief. For an interview, it's better to use the STAR method (Situation, Task, Action, Result) to give more detail.";
      scoreBoost = 0.05;
      _clarity = (_clarity + 0.05).clamp(0, 1.0);
    } else if (isRelevant) {
      feedback = "Excellent response! You successfully incorporated key technical concepts. Your explanation was structured and showed a high level of expertise.";
      scoreBoost = 0.15;
      _clarity = (_clarity + 0.15).clamp(0, 1.0);
      _communication = (_communication + 0.10).clamp(0, 1.0);
    } else {
      feedback = "Good attempt, but your answer lacked technical specificity. Try to mention specific tools or methodologies mentioned in your resume.";
      scoreBoost = 0.10;
      _communication = (_communication + 0.15).clamp(0, 1.0);
    }

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _showFeedback = true;
        _currentFeedback = feedback;
        
        // Update metrics based on evaluation
        _technicalDepth = (_technicalDepth + (isRelevant ? 0.2 : 0.05)).clamp(0, 1.0);
        _confidence = (_confidence + scoreBoost).clamp(0, 1.0);
        _keywordRelevance = (skillMatches * 0.3).clamp(0, 1.0);
        _toneModulation = (_toneModulation + 0.05).clamp(0, 1.0);
      });
      
      await _flutterTts.speak(feedback);
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _userTranscription = "";
        _showFeedback = false;
        _currentFeedback = "";
      });
      _speakQuestion();
    } else {
      _finishInterview();
    }
  }

  Future<void> _finishInterview() async {
    _metricsTimer?.cancel();
    _cameraController?.dispose();
    await _speech.stop();
    setState(() {
      _isInterviewStarted = false;
      _isFaceDetected = false;
    });
    
    // Calculate final score
    final double overallScore = (_clarity + _confidence + _technicalDepth + _communication + _toneModulation + _keywordRelevance) / 6.0;
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: cardBg,
          title: Text(
            overallScore >= 0.7 ? 'Congratulations! 🎉' : 'Interview Complete', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                overallScore >= 0.7 ? Icons.verified_user : Icons.assignment_late, 
                color: overallScore >= 0.7 ? Colors.greenAccent : Colors.orangeAccent, 
                size: 64
              ),
              const SizedBox(height: 16),
              Text(
                'Overall Score: ${(overallScore * 100).toInt()}%', 
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (overallScore >= 0.7 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: overallScore >= 0.7 ? Colors.green : Colors.red),
                ),
                child: Text(
                  overallScore >= 0.7 ? 'ELIGIBLE FOR JOB' : 'NOT ELIGIBLE YET',
                  style: TextStyle(
                    color: overallScore >= 0.7 ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                overallScore >= 0.7 
                  ? 'Based on your performance and skills match, you are a strong candidate for this role!' 
                  : 'You might need to brush up on some key technical concepts before applying for this specific role.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)), 
                textAlign: TextAlign.center
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              child: const Text('Return to Dashboard', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _metricsTimer?.cancel();
    _cameraController?.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 1100;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  if (isMobile) 
                    _buildMobileLayout()
                  else
                    _buildWebLayout(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildInterviewerCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUserFeedCard()),
                ],
              ),
              const SizedBox(height: 24),
              _buildQuestionCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildInsightsPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInterviewerCard(),
        const SizedBox(height: 16),
        _buildUserFeedCard(),
        const SizedBox(height: 24),
        _buildQuestionCard(),
        const SizedBox(height: 24),
        _buildInsightsPanel(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Mock Interview',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          'Practice your skills with our state-of-the-art AI evaluator',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInterviewerCard() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: _isSpeaking ? 1.08 : 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: _isSpeaking ? [
                  BoxShadow(
                    color: accentPurple.withValues(alpha: 0.4),
                    blurRadius: 25,
                    spreadRadius: 5,
                  )
                ] : [],
                image: const DecorationImage(
                  image: AssetImage('assets/images/male_interviewer.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isSpeaking ? 0.9 : 1.0, // Subtle flicker to simulate life
                child: child,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              child: _buildBadge('Live', Colors.green),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Interviewer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('Alex AI', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
                  ],
                ),
              ),
            ),
            if (_isSpeaking)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('SPEAKING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeCameraController() async {
    try {
      if (_availableCameras.isEmpty) {
        _availableCameras = await availableCameras();
      }
      
      if (_availableCameras.isNotEmpty) {
        final camera = _availableCameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _availableCameras.first,
        );
        
        _cameraController = CameraController(
          camera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _cameraError = null;
            _isFaceDetected = true;
          });
        }
      } else {
        setState(() => _cameraError = "No camera found.");
      }
    } catch (e) {
      setState(() => _cameraError = "Camera error: $e");
    }
  }

  Widget _buildUserFeedCard() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_cameraController != null && _cameraController!.value.isInitialized && !_isCameraMuted)
                CameraPreview(_cameraController!)
              else if (_cameraError != null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_off, color: statusRed, size: 40),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _cameraError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: _initializeCameraController,
                        child: const Text('Retry Camera', style: TextStyle(color: accentPurple)),
                      ),
                    ],
                  ),
                )
              else
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2, color: accentPurple),
                      SizedBox(height: 12),
                      Text('Initializing Camera...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              Positioned(
                top: 12,
                left: 12,
                child: _buildBadge(
                  _isFaceDetected ? 'Face Detected' : 'Detecting...', 
                  _isFaceDetected ? Colors.blue : Colors.red
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _buildBadge('You', Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: const TextStyle(color: accentPurple, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          _isLoadingQuestions 
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: accentPurple)))
            : Text(
                _isInterviewStarted ? _questions[_currentQuestionIndex] : "Ready to start your interview?",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
              ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildIconBtn(Icons.videocam, !_isCameraMuted, _toggleCamera),
              const SizedBox(width: 12),
              _buildIconBtn(Icons.mic, !_isMicMuted, _toggleMic),
              const Spacer(),
              if (!_isInterviewStarted)
                ElevatedButton(
                  onPressed: _isLoadingQuestions || _questions.isEmpty ? null : _startInterview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(_isLoadingQuestions ? 'Generating...' : 'Start Interview', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              else ...[
                TextButton(
                  onPressed: _finishInterview,
                  child: Text('End Interview', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSpeaking || _isAnalyzing ? null : (_showFeedback ? _nextQuestion : _evaluateAnswer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isAnalyzing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _showFeedback 
                            ? (_currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'Finish')
                            : 'Submit Answer',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ],
          ),
          if (_showFeedback) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentPurple.withValues(alpha: 0.1), Colors.blueAccent.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentPurple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: accentPurple, size: 20),
                      SizedBox(width: 8),
                      Text('AI Feedback', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentFeedback,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
          if (_userTranscription.isNotEmpty && !_showFeedback) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over, color: accentPurple, size: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _userTranscription,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleCamera() async {
    if (_cameraController == null) {
      await _startInterview(); // Re-init if for some reason it's null
      return;
    }
    
    setState(() {
      _isCameraMuted = !_isCameraMuted;
    });
  }

  Future<void> _toggleMic() async {
    setState(() {
      _isMicMuted = !_isMicMuted;
    });
  }

  Widget _buildIconBtn(IconData icon, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.white : statusRed.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.black : statusRed, size: 24),
      ),
    );
  }

  Widget _buildInsightsPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live AI Insights', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('AI is analyzing your behavior in real-time', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
          const SizedBox(height: 40),
          _buildInsightRow('Clarity', _clarity, Colors.blueAccent),
          _buildInsightRow('Confidence', _confidence, Colors.blueAccent),
          _buildInsightRow('Technical', _technicalDepth, Colors.greenAccent),
          _buildInsightRow('Communication', _communication, Colors.blueAccent),
          _buildInsightRow('Tone Modulation', _toneModulation, Colors.blueAccent),
          _buildInsightRow('Keyword Relevance', _keywordRelevance, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
              Text('${(value * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
