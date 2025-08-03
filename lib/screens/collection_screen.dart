import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:io';
import '../models/flower_card.dart';
import '../services/storage_service.dart';
import 'result_card_screen.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();
  
  List<FlowerCard> _cards = [];
  List<String> _availableMonths = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  String? _selectedMonth;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _storageService.getFlowerCards(
        searchQuery: _searchController.text,
        favoritesOnly: _showFavoritesOnly,
        monthFilter: _selectedMonth,
      );
      final months = await _storageService.getAvailableMonths();
      
      setState(() {
        _cards = cards;
        _availableMonths = months;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _loadData();
  }

  void _toggleFavoriteFilter() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
    _loadData();
  }

  void _onMonthSelected(String? month) {
    setState(() {
      _selectedMonth = month;
    });
    _loadData();
  }

  Future<void> _toggleCardFavorite(FlowerCard card) async {
    try {
      final updatedCard = card.copyWith(isFavorite: !card.isFavorite);
      await _storageService.updateFlowerCard(updatedCard);
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('즐겨찾기 업데이트에 실패했습니다'),
          backgroundColor: Color(0xFFE57373),
        ),
      );
    }
  }

  Future<void> _deleteCard(FlowerCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 삭제'),
        content: const Text('이 카드를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteFlowerCard(card.id);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카드가 삭제되었습니다'),
            backgroundColor: Color(0xFFA8D8A8),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('삭제에 실패했습니다'),
            backgroundColor: Color(0xFFE57373),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            _buildHeader(l10n),
            _buildSearchAndFilters(l10n),
            Expanded(
              child: _isLoading
                  ? _buildLoadingView()
                  : _cards.isEmpty
                      ? _buildEmptyView(l10n)
                      : _buildGridView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4A4A4A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.myCollection,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8B4B8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${_cards.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search bar
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
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: const TextStyle(color: Color(0xFF888888)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF888888)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(15),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Filter buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: l10n.favorite,
                  isSelected: _showFavoritesOnly,
                  icon: Icons.favorite,
                  onTap: _toggleFavoriteFilter,
                ),
                const SizedBox(width: 10),
                _buildFilterChip(
                  label: l10n.filterByMonth,
                  isSelected: _selectedMonth != null,
                  icon: Icons.calendar_month,
                  onTap: _showMonthPicker,
                ),
                if (_selectedMonth != null) ...[
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    label: _formatMonth(_selectedMonth!),
                    isSelected: true,
                    icon: Icons.close,
                    onTap: () => _onMonthSelected(null),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8B4B8) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE8B4B8) : const Color(0xFFDDDDDD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF888888),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF888888),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFE8B4B8),
      ),
    );
  }

  Widget _buildEmptyView(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Color(0xFFDDDDDD),
          ),
          const SizedBox(height: 20),
          Text(
            _showFavoritesOnly ? '즐겨찾기한 카드가 없습니다' : '아직 카드가 없습니다',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '첫 번째 꽃 카드를 만들어보세요!',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimationLimiter(
        child: MasonryGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: 2,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildCardItem(_cards[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardItem(FlowerCard card) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.file(
                  File(card.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF0F0F0),
                      child: const Icon(
                        Icons.broken_image,
                        color: Color(0xFFDDDDDD),
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.generatedText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(card.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF888888),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleCardFavorite(card),
                            child: Icon(
                              card.isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: card.isFavorite 
                                  ? const Color(0xFFE8B4B8) 
                                  : const Color(0xFF888888),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _deleteCard(card),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '월별 필터',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 20),
              if (_availableMonths.isEmpty)
                const Text(
                  '저장된 카드가 없습니다',
                  style: TextStyle(color: Color(0xFF888888)),
                )
              else
                ..._availableMonths.map((month) {
                  return ListTile(
                    title: Text(_formatMonth(month)),
                    selected: _selectedMonth == month,
                    selectedTileColor: const Color(0xFFE8B4B8).withOpacity(0.1),
                    onTap: () {
                      _onMonthSelected(month);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _formatMonth(String month) {
    final parts = month.split('-');
    if (parts.length == 2) {
      final year = parts[0];
      final monthNum = int.parse(parts[1]);
      final monthNames = [
        '1월', '2월', '3월', '4월', '5월', '6월',
        '7월', '8월', '9월', '10월', '11월', '12월'
      ];
      return '$year년 ${monthNames[monthNum - 1]}';
    }
    return month;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}