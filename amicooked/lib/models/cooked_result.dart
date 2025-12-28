/// Model representing the result of analyzing how "cooked" the user is
class CookedResult {
  /// Percentage of how cooked the user is (0-100)
  final int cookedPercent;
  
  /// The main verdict headline
  final String verdict;
  
  /// 2-4 sentences of humorous explanation
  final String explanation;

  CookedResult({
    required this.cookedPercent,
    required this.verdict,
    required this.explanation,
  });

  /// Factory constructor for JSON deserialization (for future API integration)
  factory CookedResult.fromJson(Map<String, dynamic> json) {
    return CookedResult(
      cookedPercent: json['cookedPercent'] as int,
      verdict: json['verdict'] as String,
      explanation: json['explanation'] as String,
    );
  }

  /// Convert to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'cookedPercent': cookedPercent,
      'verdict': verdict,
      'explanation': explanation,
    };
  }
}

