import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cooked_result.dart';

/// Service responsible for analyzing input and determining how "cooked" the user is
/// 
/// Uses AI proxy server for real analysis
class AnalysisService {
  static const String _apiUrl = 'https://amicooked-worker.image-proxy-gateway.workers.dev';

  /// Analyzes the provided input (text or image) and returns a judgment
  /// 
  /// [text] - The text content to analyze
  /// [image] - The image file to analyze
  /// [rizzMode] - Whether to analyze in rizz mode (dating/attraction context)
  /// 
  /// Throws an exception if the API call fails or returns invalid data
  Future<CookedResult> analyzeInput({
    String? text,
    File? image,
    bool rizzMode = false,
  }) async {
    try {
      print('=== Starting API request ===');
      
      // Prepare request body
      final Map<String, dynamic> requestBody = {};

      // Add text if provided
      if (text != null && text.isNotEmpty) {
        requestBody['text'] = text;
        print('Added text to request: ${text.length} characters');
      }

      // Add image as base64 if provided
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        requestBody['imageBase64'] = base64Image;
        print('Added image to request: ${bytes.length} bytes');
      }
      
      // Add rizzMode parameter
      requestBody['rizzMode'] = rizzMode;
      print('Rizz mode: $rizzMode');

      // Make API request
      final url = Uri.parse(_apiUrl);
      print('Sending POST request to: $_apiUrl');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('=== Raw API Response ===');
        print(response.body);
        print('=== End Raw Response ===');
        
        try {
          final data = jsonDecode(response.body);
          print('Successfully decoded response body');
          
          // Handle multiple possible response formats:
          // 1. Gemini API format: { "candidates": [{ "content": { "parts": [{ "text": "```json\n{...}\n```" }] } }] }
          // 2. Simple nested: { "text": "{\"cookedPercent\":95,...}" }
          // 3. Direct JSON: { "cookedPercent": 95, "verdict": "...", "explanation": "..." }
          
          String responseText;
          
          if (data.containsKey('candidates') && data['candidates'] is List) {
            // Format 1: Gemini API format
            print('✓ Detected Gemini API format');
            
            try {
              final candidates = data['candidates'] as List;
              if (candidates.isEmpty) {
                throw Exception('API response has empty candidates array');
              }
              
              final firstCandidate = candidates[0] as Map<String, dynamic>;
              print('First candidate keys: ${firstCandidate.keys.join(", ")}');
              
              final content = firstCandidate['content'] as Map<String, dynamic>;
              print('Content keys: ${content.keys.join(", ")}');
              
              final parts = content['parts'] as List;
              if (parts.isEmpty) {
                throw Exception('API response has empty parts array');
              }
              
              final firstPart = parts[0] as Map<String, dynamic>;
              print('First part keys: ${firstPart.keys.join(", ")}');
              
              responseText = firstPart['text'] as String;
              print('=== Extracted Text ===');
              print(responseText);
              print('=== End Extracted Text ===');
              
              // Strip markdown code fences if present (```json\n...\n```)
              responseText = responseText.trim();
              if (responseText.startsWith('```json')) {
                responseText = responseText.substring('```json'.length);
                print('Stripped ```json prefix');
              } else if (responseText.startsWith('```')) {
                responseText = responseText.substring('```'.length);
                print('Stripped ``` prefix');
              }
              if (responseText.endsWith('```')) {
                responseText = responseText.substring(0, responseText.length - 3);
                print('Stripped ``` suffix');
              }
              responseText = responseText.trim();
              
              print('=== After Stripping Markdown ===');
              print(responseText);
              print('=== End Stripped Text ===');
            } catch (e, stackTrace) {
              print('❌ ERROR parsing Gemini API structure: $e');
              print('Stack trace: $stackTrace');
              rethrow;
            }
          } else if (data.containsKey('text') && data['text'] is String) {
            // Format 2: Simple nested format
            print('✓ Detected simple nested format');
            responseText = data['text'] as String;
            print('Text field (before stripping): $responseText');
            
            // Strip markdown code fences if present (```json\n...\n```)
            responseText = responseText.trim();
            if (responseText.startsWith('```json')) {
              responseText = responseText.substring('```json'.length);
              print('Stripped ```json prefix');
            } else if (responseText.startsWith('```')) {
              responseText = responseText.substring('```'.length);
              print('Stripped ``` prefix');
            }
            if (responseText.endsWith('```')) {
              responseText = responseText.substring(0, responseText.length - 3);
              print('Stripped ``` suffix');
            }
            responseText = responseText.trim();
            print('Text field (after stripping): $responseText');
          } else if (data.containsKey('cookedPercent')) {
            // Format 3: Direct format (already parsed)
            print('✓ Detected direct format');
            try {
              // Handle recoveryPlan - can be either a string or a list of strings
              String? recoveryPlanText;
              if (data['recoveryPlan'] != null) {
                if (data['recoveryPlan'] is List) {
                  final planList = List<String>.from(data['recoveryPlan'] as List);
                  recoveryPlanText = planList.map((item) => '• $item').join('\n\n');
                } else if (data['recoveryPlan'] is String) {
                  recoveryPlanText = data['recoveryPlan'] as String;
                }
              }
              
              return CookedResult(
                cookedPercent: data['cookedPercent'] as int,
                verdict: data['verdict'] as String,
                explanation: data['explanation'] as String,
                recoveryPlan: recoveryPlanText,
                suggestedResponse: data['suggestedResponse'] as String?,
              );
            } catch (e, stackTrace) {
              print('❌ ERROR parsing direct format: $e');
              print('Stack trace: $stackTrace');
              rethrow;
            }
          } else {
            print('❌ Unknown response format. Available keys: ${data.keys.join(", ")}');
            throw Exception('Unexpected API response format: ${data.keys.join(", ")}');
          }
          
          // Parse the JSON string
          print('Attempting to parse JSON string...');
          try {
            // Remove trailing commas before closing braces/brackets (invalid JSON)
            // This handles cases where AI generates JSON like: { "key": "value", }
            String cleanedJson = responseText.replaceAll(RegExp(r',\s*}'), '}');
            cleanedJson = cleanedJson.replaceAll(RegExp(r',\s*]'), ']');
            
            if (cleanedJson != responseText) {
              print('⚠️ Cleaned up trailing commas in JSON');
              print('Cleaned JSON: $cleanedJson');
            }
            
            final parsedJson = jsonDecode(cleanedJson) as Map<String, dynamic>;
            print('✓ Successfully parsed JSON');
            print('Parsed JSON keys: ${parsedJson.keys.join(", ")}');
            print('Parsed JSON: $parsedJson');
            
            // Handle recoveryPlan - can be either a string or a list of strings
            String? recoveryPlanText;
            if (parsedJson['recoveryPlan'] != null) {
              if (parsedJson['recoveryPlan'] is List) {
                final planList = List<String>.from(parsedJson['recoveryPlan'] as List);
                recoveryPlanText = planList.map((item) => '• $item').join('\n\n');
              } else if (parsedJson['recoveryPlan'] is String) {
                recoveryPlanText = parsedJson['recoveryPlan'] as String;
              }
            }
            
            return CookedResult(
              cookedPercent: parsedJson['cookedPercent'] as int,
              verdict: parsedJson['verdict'] as String,
              explanation: parsedJson['explanation'] as String,
              recoveryPlan: recoveryPlanText,
              suggestedResponse: parsedJson['suggestedResponse'] as String?,
            );
          } catch (e, stackTrace) {
            print('❌ ERROR parsing JSON string: $e');
            print('Failed to parse: $responseText');
            print('Stack trace: $stackTrace');
            rethrow;
          }
        } catch (e, stackTrace) {
          print('❌ ERROR decoding response body: $e');
          print('Response body: ${response.body}');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      } else {
        print('❌ API request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ FATAL ERROR in analyzeInput: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}


