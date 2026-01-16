import 'package:flutter/material.dart';

/// Widget that displays a speaker avatar with gradient background
///
/// Maps speakers to 5 distinct gradient color schemes:
/// - Speaker A: Blue gradient
/// - Speaker B: Purple gradient
/// - Speaker C: Emerald gradient
/// - Speaker D: Orange gradient
/// - Speaker E: Rose gradient
class SpeakerAvatar extends StatelessWidget {
  const SpeakerAvatar({
    super.key,
    required this.speaker,
    this.size = 40,
  });

  final String speaker;
  final double size;

  /// Get gradient colors based on speaker name
  List<Color> _getGradientColors() {
    // Extract speaker letter (e.g., "Speaker A" -> "A")
    final speakerLetter = speaker.toUpperCase().split(' ').last;

    // Hash-based color selection for consistency
    final hash = speakerLetter.codeUnitAt(0) % 5;

    switch (hash) {
      case 0: // Blue
        return [const Color(0xFF3B82F6), const Color(0xFF1E40AF)];
      case 1: // Purple
        return [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)];
      case 2: // Emerald
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 3: // Orange
        return [const Color(0xFFF97316), const Color(0xFFEA580C)];
      case 4: // Rose
        return [const Color(0xFFF43F5E), const Color(0xFFE11D48)];
      default:
        return [const Color(0xFF3B82F6), const Color(0xFF1E40AF)];
    }
  }

  /// Get speaker initial (first letter)
  String _getSpeakerInitial() {
    final words = speaker.split(' ');
    return words.isNotEmpty ? words.last[0].toUpperCase() : 'S';
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors();
    final initial = _getSpeakerInitial();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
