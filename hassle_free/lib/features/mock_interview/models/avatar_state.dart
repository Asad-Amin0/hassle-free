enum AvatarMood { idle, talking, listening, thinking, happy, concerned }

class AvatarState {
  final AvatarMood mood;
  final String animation;        // matches R3F/model_viewer animation name
  final String facialExpression; // "smile"|"default"|"surprised"|"sad"
  final String currentText;      // text the avatar is "speaking"
  final List<LipSyncFrame> lipSyncFrames;
  final bool isSpeaking;

  const AvatarState({
    this.mood = AvatarMood.idle,
    this.animation = 'Idle',
    this.facialExpression = 'default',
    this.currentText = '',
    this.lipSyncFrames = const [],
    this.isSpeaking = false,
  });

  AvatarState copyWith({
    AvatarMood? mood,
    String? animation,
    String? facialExpression,
    String? currentText,
    List<LipSyncFrame>? lipSyncFrames,
    bool? isSpeaking,
  }) {
    return AvatarState(
      mood: mood ?? this.mood,
      animation: animation ?? this.animation,
      facialExpression: facialExpression ?? this.facialExpression,
      currentText: currentText ?? this.currentText,
      lipSyncFrames: lipSyncFrames ?? this.lipSyncFrames,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

class LipSyncFrame {
  final double time;
  final String phoneme; // "A"|"B"|"C"|"D"|"E"|"F"|"G"|"H"|"X"
  const LipSyncFrame({required this.time, required this.phoneme});

  factory LipSyncFrame.fromJson(Map<String, dynamic> json) =>
      LipSyncFrame(time: (json['time'] ?? 0).toDouble(), phoneme: json['value'] ?? 'X');
}
