import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import '../services/gemini_service.dart';
import 'result_card_screen.dart';

class AiGenerationScreen extends StatefulWidget {
  final String imagePath;
  final String emotion;
  final String style;

  const AiGenerationScreen({
    super.key,
    required this.imagePath,
    required this.emotion,
    required this.style,
  });

  @override
  State<AiGenerationScreen> createState() => _AiGenerationScreenState();
}

class _AiGenerationScreenState extends State<AiGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GeminiService _geminiService = GeminiService();
  bool _isGenerating = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
    _generatePoetry();
  }

  Future<void> _generatePoetry() async {
    try {
      final result = await _geminiService.generatePoetry(
        imagePath: widget.imagePath,
        emotion: widget.emotion,
        style: widget.style,
        language: 'ko',
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultCardScreen(
              imagePath: widget.imagePath,
              generatedText: result,
              emotion: widget.emotion,
              style: widget.style,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _error = e.toString();
      });
    }
  }

  void _retry() {
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    _generatePoetry();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F4F0),
              const Color(0xFFE8B4B8).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              
              Expanded(
                child: _isGenerating
                    ? _buildLoadingContent(l10n)
                    : _buildErrorContent(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // Animated flower icon
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B4B8).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.local_florist,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 30),
        
        // Loading animation (placeholder for Lottie)
        Container(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFFE8B4B8),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Loading message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            l10n.generatingMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
              height: 1.4,
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Estimated time
        Text(
          '예상 시간: 5-10초',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF888888),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Floating petals animation (simplified)
        Container(
          width: double.infinity,
          height: 80,
          child: Stack(
            children: List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    left: (index * 60.0) + 
                          (20 * _animationController.value),
                    top: 20 + (30 * _animationController.value),
                    child: Opacity(
                      opacity: 0.3 + (0.4 * _animationController.value),
                      child: Icon(
                        Icons.flutter_dash,
                        size: 20,
                        color: Color(0xFFE8B4B8),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 80,
          color: Color(0xFFE57373),
        ),
        
        const SizedBox(height: 30),
        
        Text(
          '오류가 발생했습니다',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
        
        const SizedBox(height: 15),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _error ?? '알 수 없는 오류가 발생했습니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        ElevatedButton(
          onPressed: _retry,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8B4B8),
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            '다시 시도',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}