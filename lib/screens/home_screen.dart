import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'camera_screen.dart';
import 'collection_screen.dart';
import 'emotion_input_screen.dart';
import 'result_card_screen.dart';
import '../services/storage_service.dart';
import '../models/flower_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  List<FlowerCard> _recentCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentCards();
  }

  Future<void> _loadRecentCards() async {
    try {
      final cards = await _storageService.getFlowerCards(limit: 5);
      setState(() {
        _recentCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EmotionInputScreen(imagePath: image.path),
          ),
        ).then((_) => _loadRecentCards()); // Refresh cards after returning
      }
    } catch (e) {
      print('Error picking from gallery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: _buildMainContent(l10n),
            ),
            _buildRecentCards(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCurrentDate(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(AppLocalizations l10n) {
    return AnimationLimiter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            const Icon(
              Icons.local_florist,
              size: 80,
              color: Color(0xFFE8B4B8),
            ),
            const SizedBox(height: 30),
            Text(
              l10n.homeTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                ).then((_) => _loadRecentCards()); // Refresh cards after returning
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B4B8),
                  borderRadius: BorderRadius.circular(75),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8B4B8).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library, color: Colors.white, size: 20),
              label: Text(
                l10n.selectFromGallery,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA8D8A8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCards(AppLocalizations l10n) {
    return Container(
      height: 150,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CollectionScreen()),
              );
            },
            child: Row(
              children: [
                Text(
                  l10n.myCollection,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF888888),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE8B4B8),
                    ),
                  )
                : _recentCards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 40,
                              color: Color(0xFFDDDDDD),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '아직 카드가 없습니다',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recentCards.length,
                        itemBuilder: (context, index) {
                          final card = _recentCards[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResultCardScreen(
                                    imagePath: card.imagePath,
                                    generatedText: card.generatedText,
                                    emotion: card.emotion,
                                    style: card.style,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                  File(card.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Color(0xFFDDDDDD),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return '${now.year}년 ${months[now.month - 1]} ${now.day}일';
  }
}