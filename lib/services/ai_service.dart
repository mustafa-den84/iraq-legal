import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Cloudflare Secrets - These should be set in Cloudflare Pages/Workers
  // GEMINI_API_KEY, OPENAI_API_KEY, ANTHROPIC_API_KEY, GROQ_API_KEY, HUGGINGFACE_API_KEY
  
  static String get geminiApiKey => const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static String get openaiApiKey => const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static String get anthropicApiKey => const String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');
  static String get groqApiKey => const String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static String get huggingfaceApiKey => const String.fromEnvironment('HUGGINGFACE_API_KEY', defaultValue: '');

  // API Endpoints
  static const String geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String openaiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String anthropicUrl = 'https://api.anthropic.com/v1/messages';
  static const String groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String huggingfaceUrl = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2';

  // Available models in order of preference
  static const List<String> availableModels = [
    'groq',      // Fastest, free tier
    'gemini',    // Google, free tier
    'openai',    // GPT-3.5, free tier
    'anthropic', // Claude, free tier
    'huggingface', // Open source, free
  ];

  static Future<String> getLegalAdvice(String prompt, String lang) async {
    final systemPrompt = _getSystemPrompt(lang);
    
    // Try each model in order until one succeeds
    for (final model in availableModels) {
      try {
        final response = await _callModel(model, systemPrompt, prompt, lang);
        return response;
      } catch (e) {
        print('Failed to use $model: $e');
        continue; // Try next model
      }
    }
    
    throw Exception('All AI models failed');
  }

  static Future<String> _callModel(String model, String systemPrompt, String prompt, String lang) async {
    switch (model) {
      case 'gemini':
        return await _callGemini(systemPrompt, prompt);
      case 'openai':
        return await _callOpenAI(systemPrompt, prompt);
      case 'anthropic':
        return await _callAnthropic(systemPrompt, prompt);
      case 'groq':
        return await _callGroq(systemPrompt, prompt);
      case 'huggingface':
        return await _callHuggingFace(systemPrompt, prompt);
      default:
        throw Exception('Unknown model: $model');
    }
  }

  static Future<String> _callGemini(String systemPrompt, String prompt) async {
    if (geminiApiKey.isEmpty) throw Exception('Gemini API key not set');
    
    final response = await http.post(
      Uri.parse('$geminiUrl?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$systemPrompt\n\nUser question: $prompt'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    }
    throw Exception('Gemini API error: ${response.statusCode}');
  }

  static Future<String> _callOpenAI(String systemPrompt, String prompt) async {
    if (openaiApiKey.isEmpty) throw Exception('OpenAI API key not set');
    
    final response = await http.post(
      Uri.parse(openaiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openaiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    }
    throw Exception('OpenAI API error: ${response.statusCode}');
  }

  static Future<String> _callAnthropic(String systemPrompt, String prompt) async {
    if (anthropicApiKey.isEmpty) throw Exception('Anthropic API key not set');
    
    final response = await http.post(
      Uri.parse(anthropicUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': anthropicApiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-3-haiku-20240307',
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'];
    }
    throw Exception('Anthropic API error: ${response.statusCode}');
  }

  static Future<String> _callGroq(String systemPrompt, String prompt) async {
    if (groqApiKey.isEmpty) throw Exception('Groq API key not set');
    
    final response = await http.post(
      Uri.parse(groqUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $groqApiKey',
      },
      body: jsonEncode({
        'model': 'llama3-8b-8192',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    }
    throw Exception('Groq API error: ${response.statusCode}');
  }

  static Future<String> _callHuggingFace(String systemPrompt, String prompt) async {
    if (huggingfaceApiKey.isEmpty) throw Exception('HuggingFace API key not set');
    
    final response = await http.post(
      Uri.parse(huggingfaceUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $huggingfaceApiKey',
      },
      body: jsonEncode({
        'inputs': '<s>[INST] $systemPrompt\n\nUser: $prompt [/INST]',
        'parameters': {
          'max_new_tokens': 1024,
          'temperature': 0.7,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0]['generated_text'];
    }
    throw Exception('HuggingFace API error: ${response.statusCode}');
  }

  static String _getSystemPrompt(String lang) {
    switch (lang) {
      case 'ar':
        return '''أنت مساعد قانوني عراقي متخصص في القانون العراقي. قدم إجابات قصيرة ومباشرة على الأسئلة القانونية.

القواعد:
- أجب باختصار (1-3 جمل)
- ركز على المعلومات الأساسية
- إذا لم تكن متأكداً، أشر إلى الحاجة لاستشارة محامي
- استخدم لغة عربية بسيطة وواضحة
- لا تقدم نصائح قانونية معقدة دون تحذير''';
      case 'ku':
        return '''تۆ ڕاوێژکاری یاسایی کوردی تەخصصت لە یاسای عێراقە. وەڵامی کورت و ڕووت بدەرەوە بۆ پرسیارە یاساییەکان.

ڕێساکان:
- وەڵامی کورت بدەرەوە (1-3 ڕستەر)
- سەرنجت بخەنە سەر زانیاری سەرەکی
- ئەگەر دڵنیا نیت، ئاماژە بە پێویستی بە ڕاوێژی پارێزەر بکە
- زمانی کوردی سادە و ڕووت بەکاربەنە
- ڕاوێژی یاسایی ئاڵۆز نەدە بەبێ ئاگاداری''';
      default:
        return '''You are an Iraqi legal assistant specializing in Iraqi law. Provide short, direct answers to legal questions.

Rules:
- Answer briefly (1-3 sentences)
- Focus on essential information
- If unsure, indicate need to consult a lawyer
- Use simple, clear English
- Do not provide complex legal advice without disclaimer''';
    }
  }
}
