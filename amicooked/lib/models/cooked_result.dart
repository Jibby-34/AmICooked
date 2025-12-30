/// Model representing the result of analyzing how "cooked" the user is
class CookedResult {
  /// Percentage of how cooked the user is (0-100)
  final int cookedPercent;
  
  /// The main verdict headline
  final String verdict;
  
  /// 2-4 sentences of humorous explanation
  final String explanation;
  
  /// Recovery plan to fix the situation
  final String? recoveryPlan;
  
  /// Suggested response message
  final String? suggestedResponse;
  
  /// Optional user input text (for context in sharing)
  final String? inputText;
  
  /// Optional chat highlights or key moments
  final List<String>? chatHighlights;

  CookedResult({
    required this.cookedPercent,
    required this.verdict,
    required this.explanation,
    this.recoveryPlan,
    this.suggestedResponse,
    this.inputText,
    this.chatHighlights,
  });

  /// Factory constructor for JSON deserialization (for future API integration)
  factory CookedResult.fromJson(Map<String, dynamic> json) {
    // Handle recoveryPlan - can be either a string or a list of strings
    String? recoveryPlanText;
    if (json['recoveryPlan'] != null) {
      if (json['recoveryPlan'] is List) {
        // Convert list to bullet points
        final planList = List<String>.from(json['recoveryPlan'] as List);
        recoveryPlanText = planList.map((item) => '• $item').join('\n\n');
      } else if (json['recoveryPlan'] is String) {
        recoveryPlanText = json['recoveryPlan'] as String;
      }
    }
    
    return CookedResult(
      cookedPercent: json['cookedPercent'] as int,
      verdict: json['verdict'] as String,
      explanation: json['explanation'] as String,
      recoveryPlan: recoveryPlanText,
      suggestedResponse: json['suggestedResponse'] as String?,
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
      if (recoveryPlan != null) 'recoveryPlan': recoveryPlan,
      if (suggestedResponse != null) 'suggestedResponse': suggestedResponse,
      if (inputText != null) 'inputText': inputText,
      if (chatHighlights != null) 'chatHighlights': chatHighlights,
    };
  }
}

