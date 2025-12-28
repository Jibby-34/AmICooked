import 'dart:io';
import 'dart:math';
import '../models/cooked_result.dart';

/// Service responsible for analyzing input and determining how "cooked" the user is
/// 
/// Currently uses mock responses, but structured to easily swap in a real AI API
class AnalysisService {
  final Random _random = Random();

  /// Analyzes the provided input (text or image) and returns a judgment
  /// 
  /// [text] - The text content to analyze
  /// [image] - The image file to analyze
  /// [mode] - The context mode: "school" | "work" | "social" | "dating" | "general"
  /// 
  /// TODO: Replace mock logic with real AI API call
  Future<CookedResult> analyzeInput({
    String? text,
    File? image,
    String mode = 'general',
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // ============================================
    // DEBUG: Using mock AI response
    // TODO: Replace this section with actual API call
    // Example:
    // final response = await http.post(
    //   Uri.parse('YOUR_AI_API_ENDPOINT'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'text': text,
    //     'image': image != null ? base64Encode(image.readAsBytesSync()) : null,
    //     'mode': mode,
    //   }),
    // );
    // return CookedResult.fromJson(jsonDecode(response.body));
    // ============================================

    return _generateMockResponse(text, image, mode);
  }

  /// Generates a mock response based on simple heuristics
  /// This will be replaced with real AI analysis
  CookedResult _generateMockResponse(String? text, File? image, String mode) {
    // Generate a random cooked percentage
    int cookedPercent = _random.nextInt(101);

    // Adjust based on text length (just for fun)
    if (text != null && text.isNotEmpty) {
      if (text.length > 500) {
        cookedPercent = (cookedPercent * 1.2).clamp(0, 100).toInt();
      }
      if (text.toLowerCase().contains('sorry')) {
        cookedPercent = (cookedPercent * 0.7).toInt();
      }
      if (text.toLowerCase().contains('!!!') || 
          text.toLowerCase().contains('???')) {
        cookedPercent = (cookedPercent * 1.3).clamp(0, 100).toInt();
      }
    }

    // Generate verdict based on percentage
    String verdict = _getVerdict(cookedPercent);
    String explanation = _getExplanation(cookedPercent, mode);

    return CookedResult(
      cookedPercent: cookedPercent,
      verdict: verdict,
      explanation: explanation,
    );
  }

  String _getVerdict(int percent) {
    if (percent >= 90) {
      return _pickRandom([
        "Charcoal. Absolute charcoal.",
        "You're toast. Burnt toast.",
        "This is a five-alarm fire. 🚨",
        "Call the fire department. It's too late.",
      ]);
    } else if (percent >= 70) {
      return _pickRandom([
        "You're absolutely cooked.",
        "Medium-well to well-done.",
        "The damage is done. 🔥",
        "Yikes. This is not good.",
      ]);
    } else if (percent >= 50) {
      return _pickRandom([
        "You're medium-cooked.",
        "Could be worse... but not great.",
        "Treading on thin ice here.",
        "Slightly singed. Proceed with caution.",
      ]);
    } else if (percent >= 30) {
      return _pickRandom([
        "Barely cooked. You might survive.",
        "A little warm, but you're fine.",
        "Minor red flags detected.",
        "You're handling this... okay-ish.",
      ]);
    } else {
      return _pickRandom([
        "Surprisingly uncooked! 🎉",
        "You're in the clear. For now.",
        "Raw and ready. No issues here.",
        "Actually... you're good!",
      ]);
    }
  }

  String _getExplanation(int percent, String mode) {
    if (percent >= 90) {
      return _pickRandom([
        "This message raises several red flags. There's no coming back from this one. Time to delete everything and start a new life. 🔥",
        "The tone, the content, the timing... it's all wrong. This is beyond repair. Consider changing your name and moving to a different country.",
        "I've seen a lot, but this... this is next level. Whatever you were trying to achieve, you achieved the opposite. Good luck explaining this one.",
      ]);
    } else if (percent >= 70) {
      return _pickRandom([
        "There are some concerning elements here. You might be able to salvage this with some serious damage control, but it's going to take work. 🚒",
        "The vibes are off, and it shows. You're in hot water, but if you act fast, you might cool things down. No promises though.",
        "This is rough. Not irredeemable, but definitely problematic. Think carefully about your next move, because you're on thin ice.",
      ]);
    } else if (percent >= 50) {
      return _pickRandom([
        "You're in the danger zone. Not fully cooked yet, but you're getting there. A few more moves like this and you'll be toast. ⚠️",
        "This could go either way. Right now it's 50/50 whether you recover or go down in flames. Choose your next words carefully.",
        "The temperature is rising. You're not burnt yet, but the heat is definitely on. Proceed with extreme caution.",
      ]);
    } else if (percent >= 30) {
      return _pickRandom([
        "There are some minor issues, but nothing catastrophic. A little awkward, maybe, but you'll probably be fine. Just watch your step. 👀",
        "Slightly questionable, but survivable. You're not cooked... yet. Keep it together and you should be okay.",
        "This raises a few eyebrows, but it's not a disaster. You're in the safe zone for now, but don't push your luck.",
      ]);
    } else {
      return _pickRandom([
        "Honestly? You're golden. No red flags, no issues. Whatever you're doing, keep doing it. You've got this! ✨",
        "This is actually fine. Maybe even good! No signs of being cooked whatsoever. You're handling things like a pro.",
        "Clear skies ahead. Nothing to worry about here. You're perfectly uncooked and ready to go. Keep up the good work!",
      ]);
    }
  }

  String _pickRandom(List<String> options) {
    return options[_random.nextInt(options.length)];
  }
}

