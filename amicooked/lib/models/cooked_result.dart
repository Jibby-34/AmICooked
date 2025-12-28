/// Model representing the result of analyzing how "cooked" the user is
class CookedResult {
  /// Percentage of how cooked the user is (0-100)
  final int cookedPercent;
  
  /// The main verdict headline
  final String verdict;
  
  /// 2-4 sentences of humorous explanation
  final String explanation;
  
  /// Optional user input text (for context in sharing)
  final String? inputText;
  
  /// Optional chat highlights or key moments
  final List<String>? chatHighlights;

  CookedResult({
    required this.cookedPercent,
    required this.verdict,
    required this.explanation,
    this.inputText,
    this.chatHighlights,
  });

  /// Factory constructor for JSON deserialization (for future API integration)
  factory CookedResult.fromJson(Map<String, dynamic> json) {
    return CookedResult(
      cookedPercent: json['cookedPercent'] as int,
      verdict: json['verdict'] as String,
      explanation: json['explanation'] as String,
      inputText: json['inputText'] as String?,
      chatHighlights: json['chatHighlights'] != null 
          ? List<String>.from(json['chatHighlights'] as List)
          : null,
    );
  }

  /// Convert to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'cookedPercent': cookedPercent,
      'verdict': verdict,
      'explanation': explanation,
      if (inputText != null) 'inputText': inputText,
      if (chatHighlights != null) 'chatHighlights': chatHighlights,
    };
  }
}

