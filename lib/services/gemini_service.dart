import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _baseUrl = 'https://api.x.ai/v1/chat/completions';
  static const String _model = 'grok-3-mini';
  static const String _identity = 'You are CareShare AI, a personalised skincare assistant for Indian users. Always refer to yourself as a personalised skincare assistant, never as a doctor, dermatologist, or medical professional. Always personalise responses based on the user profile provided.';

  static Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key') ?? '';
  }

  static Future<String> _userContext() async {
    final p = await SharedPreferences.getInstance();
    final name = p.getString('user_name') ?? 'User';
    final skin = p.getString('skin_type') ?? 'unknown';
    final hair = p.getString('hair_type') ?? 'unknown';
    final gender = p.getString('gender') ?? 'unknown';
    final allergies = p.getString('allergies') ?? 'none';
    final conditions = p.getString('conditions') ?? 'none';
    final cycle = p.getString('cycle_info') ?? '';
    return 'Name: $name | Gender: $gender | Skin: $skin | Hair: $hair | Allergies: $allergies | Conditions: $conditions${cycle.isNotEmpty ? ' | Cycle: $cycle' : ''}';
  }

  static Future<String> _call(String system, String message) async {
    final apiKey = await _getApiKey();
    if (apiKey.isEmpty) throw Exception('No API key set. Please add your API key in Profile > Settings.');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 1024,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['choices'][0]['message']['content'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception('API error ${response.statusCode}: ${error['error']['message']}');
    }
  }

  static Future<String> _callWithHistory(String system, List<Map<String, String>> messages) async {
    final apiKey = await _getApiKey();
    if (apiKey.isEmpty) throw Exception('No API key set. Please add your API key in Profile > Settings.');

    final allMessages = [
      {'role': 'system', 'content': system},
      ...messages,
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': allMessages,
        'max_tokens': 1024,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['choices'][0]['message']['content'] as String;
    } else {
      final error = jsonDecode(response.body);
      throw Exception('API error ${response.statusCode}: ${error['error']['message']}');
    }
  }

  static Future<String> analyzeProduct(String product) async {
    final ctx = await _userContext();
    final system = _identity + ' User profile: ' + ctx + ' Analyse products specifically for this user. Flag allergens and condition-specific warnings.';
    final message = 'Analyse this product: "$product"\n\n**Product Type** - What is it?\n**Key Ingredients** - Main ingredients and effects on this users skin/hair type\n**Harmful Ingredients** - Flag parabens, sulphates, alcohol, fragrances or anything conflicting with their allergies or conditions\n**Compatibility** - SAFE / USE WITH CAUTION / AVOID for this user\n**Verdict** - One personalised recommendation\n\nBe concise and personalised.';
    return await _call(system, message);
  }

  static Future<String> chat(String message, List<Map<String, String>> history) async {
    final ctx = await _userContext();
    final system = _identity + ' User profile: ' + ctx + ' Personalise advice based on their skin/hair type, allergies and conditions. Suggest Indian brands: Minimalist, Dot & Key, Mamaearth, Plum, mCaffeine, WOW, Aqualogica. Be concise, under 120 words unless asked for more.';
    final messages = <Map<String, String>>[];
    for (final m in history) {
      messages.add({'role': m['role'] == 'user' ? 'user' : 'assistant', 'content': m['content']!});
    }
    messages.add({'role': 'user', 'content': message});
    return await _callWithHistory(system, messages);
  }

  static Future<String> getRecommendations(String category) async {
    final ctx = await _userContext();
    final system = _identity + ' User profile: ' + ctx + ' Give specific personalised recommendations. Focus on Indian products available in 2024-2025.';
    final message = 'Recommend top 5 Indian $category products for this user.\nFor each: product name & brand, why it suits their specific profile, key ingredients, price in INR, where to buy (Nykaa/Amazon/etc).';
    return await _call(system, message);
  }

  static Future<String> analyzeIngredients(String ingredientText) async {
    final ctx = await _userContext();
    final system = _identity + ' User profile: ' + ctx + ' Analyse scanned ingredient lists specifically for this user.';
    final message = 'I scanned a product label. Extracted text:\n\n$ingredientText\n\nAnalyse for this user:\n**Product Type** - What kind of product?\n**Key Ingredients** - Effects on this users skin type and hair type\n**Harmful Ingredients** - Flag anything conflicting with their allergies or conditions\n**Compatibility** - SAFE / USE WITH CAUTION / AVOID for this user\n**Verdict** - One personalised recommendation\n\nBe concise and personalised.';
    return await _call(system, message);
  }
}