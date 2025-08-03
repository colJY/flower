import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY_HERE';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  Future<String> generatePoetry({
    required String imagePath,
    required String emotion,
    required String style,
    required String language,
  }) async {
    try {
      // Read image file and convert to base64
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Create prompt based on style and language
      final prompt = _createPrompt(emotion, style, language);

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.8,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      };

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText =
            data['candidates'][0]['content']['parts'][0]['text'];
        return generatedText ?? '아름다운 꽃처럼\\n당신의 마음도\\n환하게 피어나기를';
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      // For demo purposes, return a sample text
      print('Gemini API Error: $e');
      return _getSampleText(style, emotion);
    }
  }

  String _createPrompt(String emotion, String style, String language) {
    final basePrompt = language == 'ko'
        ? '이 꽃 사진을 보고, 사용자의 감정과 상황에 맞는 아름다운 글을 작성해주세요.'
        : 'Looking at this flower photo, please write a beautiful text that matches the user\'s emotions and situation.';

    final emotionPrompt = language == 'ko'
        ? '사용자의 현재 감정/상황: $emotion'
        : 'User\'s current emotion/situation: $emotion';

    final stylePrompt = _getStylePrompt(style, language);

    final guidelines = language == 'ko'
        ? '''
작성 가이드라인:
- 꽃의 색깔, 형태, 분위기를 반영해주세요
- 사용자의 감정에 공감하고 위로가 되는 내용으로 작성해주세요
- 3-6줄 정도의 적당한 길이로 작성해주세요
- 따뜻하고 감성적인 톤으로 작성해주세요
- 직접적인 조언보다는 은유적 표현을 사용해주세요
'''
        : '''
Writing guidelines:
- Reflect the color, shape, and mood of the flowers
- Write content that empathizes with and comforts the user's emotions
- Write in an appropriate length of about 3-6 lines
- Write in a warm and emotional tone
- Use metaphorical expressions rather than direct advice
''';

    return '$basePrompt\n\n$emotionPrompt\n\n$stylePrompt\n\n$guidelines';
  }

  String _getStylePrompt(String style, String language) {
    final styleMap = {
      'warm_poetry': language == 'ko'
          ? '따뜻한 시의 형태로'
          : 'In the form of warm poetry',
      'sensitive_prose': language == 'ko' ? '감성적인 산문으로' : 'As sensitive prose',
      'comfort_message': language == 'ko' ? '위로의 메시지로' : 'As a comfort message',
      'diary_feeling': language == 'ko' ? '일기 같은 느낌으로' : 'Like a diary entry',
      'famous_quote': language == 'ko'
          ? '명언이나 격언 형태로'
          : 'In the form of a famous quote or maxim',
      'ai_choice': language == 'ko'
          ? '가장 적합한 스타일로'
          : 'In the most suitable style',
    };

    final styleText = styleMap[style] ?? styleMap['ai_choice']!;
    return language == 'ko' ? '글의 스타일: $styleText' : 'Text style: $styleText';
  }

  String _getSampleText(String style, String emotion) {
    // Sample texts for demo purposes
    final sampleTexts = {
      'warm_poetry': '''봄바람에 흔들리는
꽃잎처럼
당신의 마음도
다시 환하게 피어나리''',
      'sensitive_prose': '''작은 꽃봉오리가 피어나듯, 오늘의 기쁜 마음도 천천히 꽃피워가세요. 
당신의 웃음이 꽃잎보다 아름답습니다.''',
      'comfort_message': '''힘든 시간도 지나가는 계절처럼, 
반드시 따뜻한 봄이 찾아올 거예요. 
지금의 당신도 충분히 아름다워요.''',
      'diary_feeling': '''오늘 예쁜 꽃을 보며 문득 생각했다. 
나도 이 꽃처럼 조용히, 
그러나 확실하게 피어나고 있구나.''',
      'famous_quote': '''"꽃은 자신이 아름답다는 것을 
증명하려 하지 않는다. 
그저 피어날 뿐이다."''',
      'ai_choice': '''당신의 마음속에 핀
작은 희망의 꽃
오늘도 조용히 향기를 전해주네요''',
    };

    return sampleTexts[style] ?? sampleTexts['ai_choice']!;
  }
}
