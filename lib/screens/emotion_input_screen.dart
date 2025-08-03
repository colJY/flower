import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import 'dart:io';
import 'ai_generation_screen.dart';

class EmotionInputScreen extends StatefulWidget {
  final String imagePath;

  const EmotionInputScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<EmotionInputScreen> createState() => _EmotionInputScreenState();
}

class _EmotionInputScreenState extends State<EmotionInputScreen> {
  final TextEditingController _emotionController = TextEditingController();
  String _selectedStyle = 'ai_choice';

  final Map<String, String> _styleOptions = {
    'warm_poetry': '따뜻한 시',
    'sensitive_prose': '감성적인 산문',
    'comfort_message': '위로의 메시지',
    'diary_feeling': '일기 느낌',
    'famous_quote': '명언/격언',
    'ai_choice': 'AI가 선택',
  };



  void _generatePoetry() {
    if (_emotionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('감정이나 상황을 입력해주세요.'),
          backgroundColor: Color(0xFFE8B4B8),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiGenerationScreen(
          imagePath: widget.imagePath,
          emotion: _emotionController.text.trim(),
          style: _selectedStyle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emotionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Emotion input section
            Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Color(0xFFE8B4B8),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.emotionInputTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _emotionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.emotionInputHint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ),
            
            
            const SizedBox(height: 40),
            
            // Style selection section
            Row(
              children: [
                const Icon(
                  Icons.edit,
                  color: Color(0xFFE8B4B8),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.styleSelectionTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _styleOptions.entries.map((entry) {
                final isSelected = _selectedStyle == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStyle = entry.key;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFFE8B4B8) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFFE8B4B8) 
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 60),
            
            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generatePoetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B4B8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  l10n.generateButton,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}