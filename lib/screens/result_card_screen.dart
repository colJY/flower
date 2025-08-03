import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/storage_service.dart';
import '../models/flower_card.dart';

class ResultCardScreen extends StatefulWidget {
  final String imagePath;
  final String generatedText;
  final String emotion;
  final String style;

  const ResultCardScreen({
    super.key,
    required this.imagePath,
    required this.generatedText,
    required this.emotion,
    required this.style,
  });

  @override
  State<ResultCardScreen> createState() => _ResultCardScreenState();
}

class _ResultCardScreenState extends State<ResultCardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final StorageService _storageService = StorageService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  int _selectedTheme = 0;
  bool _isSaved = false;
  bool _isEditing = false;
  String _currentText = '';

  final List<CardTheme> _themes = [
    CardTheme(
      backgroundColor: Color(0xFFF8F4F0),
      textColor: Color(0xFF4A4A4A),
      accentColor: Color(0xFFE8B4B8),
      name: '클래식',
    ),
    CardTheme(
      backgroundColor: Color(0xFF2C3E50),
      textColor: Colors.white,
      accentColor: Color(0xFFE8B4B8),
      name: '다크',
    ),
    CardTheme(
      backgroundColor: Color(0xFFF0F8FF),
      textColor: Color(0xFF2C3E50),
      accentColor: Color(0xFFA8C8E8),
      name: '시원한',
    ),
    CardTheme(
      backgroundColor: Color(0xFFFFF8DC),
      textColor: Color(0xFF8B4513),
      accentColor: Color(0xFFDEB887),
      name: '따뜻한',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentText = widget.generatedText;
    _textController.text = _currentText;
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(l10n),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AnimationLimiter(
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 600),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          _buildCard(),
                          const SizedBox(height: 30),
                          _buildThemeSelector(l10n),
                          const SizedBox(height: 30),
                          _buildActionButtons(l10n),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _isSaved ? Icons.favorite : Icons.favorite_border,
              color: _isSaved ? const Color(0xFFE8B4B8) : const Color(0xFF4A4A4A),
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final theme = _themes[_selectedTheme];
    
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // Image
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Generated text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                decoration: BoxDecoration(
                  color: theme.backgroundColor == const Color(0xFFF8F4F0)
                      ? Colors.white.withOpacity(0.7)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: _isEditing ? Border.all(
                    color: theme.accentColor,
                    width: 2,
                  ) : null,
                ),
                child: _isEditing
                    ? TextField(
                        controller: _textController,
                        focusNode: _textFocusNode,
                        textAlign: TextAlign.center,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: theme.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _currentText = value;
                          });
                        },
                      )
                    : GestureDetector(
                        onTap: _startEditing,
                        child: Text(
                          _currentText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            color: theme.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
              
              const SizedBox(height: 25),
              
              // Date
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getCurrentDate(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.palette,
              color: Color(0xFFE8B4B8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.changeStyle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              final theme = _themes[index];
              final isSelected = _selectedTheme == index;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTheme = index;
                  });
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected 
                          ? theme.accentColor
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        theme.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Column(
      children: [
        // Edit button
        if (!_isEditing)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 15),
            child: ElevatedButton.icon(
              onPressed: _startEditing,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                '텍스트 편집',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C88A3),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        
        // Edit mode buttons
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _cancelEditing,
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text(
                    '취소',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF999999),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveEditing,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    '완료',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C88A3),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        
        // Main action buttons (only shown when not editing)
        if (!_isEditing) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveCard,
                  icon: const Icon(Icons.save_alt, color: Colors.white),
                  label: Text(
                    l10n.save,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8D8A8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareCard,
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: Text(
                    l10n.share,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B4B8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _textController.text = _currentText;
    });
    // Focus on text field after a short delay to ensure it's rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      _textFocusNode.requestFocus();
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _textController.text = _currentText;
    });
    _textFocusNode.unfocus();
  }

  void _saveEditing() {
    setState(() {
      _currentText = _textController.text;
      _isEditing = false;
    });
    _textFocusNode.unfocus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('텍스트가 수정되었습니다'),
        backgroundColor: Color(0xFF9C88A3),
      ),
    );
  }

  Future<void> _saveCard() async {
    try {
      final flowerCard = FlowerCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: widget.imagePath,
        generatedText: _currentText, // Use current edited text
        emotion: widget.emotion,
        style: widget.style,
        theme: _selectedTheme,
        createdAt: DateTime.now(),
        isFavorite: false,
      );
      
      await _storageService.saveFlowerCard(flowerCard);
      
      setState(() {
        _isSaved = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카드가 저장되었습니다'),
          backgroundColor: Color(0xFFA8D8A8),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장에 실패했습니다'),
          backgroundColor: Color(0xFFE57373),
        ),
      );
    }
  }

  Future<void> _shareCard() async {
    try {
      final Uint8List? image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/flower_card_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(imagePath);
        await file.writeAsBytes(image);
        
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '꽃말 앱에서 만든 아름다운 카드입니다 🌸',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공유에 실패했습니다'),
          backgroundColor: Color(0xFFE57373),
        ),
      );
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isSaved = !_isSaved;
    });
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }
}

class CardTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final String name;

  CardTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    required this.name,
  });
}