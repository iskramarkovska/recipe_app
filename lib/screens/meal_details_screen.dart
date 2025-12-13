import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_details.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class MealDetailsScreen extends StatefulWidget {
  final String mealId;

  const MealDetailsScreen({super.key, required this.mealId});

  @override
  State<MealDetailsScreen> createState() => _mealDetailsScreenState();
}

class _mealDetailsScreenState extends State<MealDetailsScreen> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();

  MealDetails? _mealDetails;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMealDetail();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.mealId);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    await _favoritesService.toggleFavorite(widget.mealId);
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite
                  ? 'Added to favorites!'
                  : 'Removed from favorites'
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadMealDetail() async {
    try {
      final detail = await _apiService.fetchMealDetails(widget.mealId);
      setState(() {
        _mealDetails = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mealDetails == null
          ? const Center(child: Text('Failed to load meal details'))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.pink,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
                tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _mealDetails!.strMeal,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: _mealDetails!.strMealThumb,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(_mealDetails!.strCategory),
                        backgroundColor: Colors.pink.shade100,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_mealDetails!.strArea),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ],
                  ),
                  if (_mealDetails!.strYoutube != null &&
                      _mealDetails!.strYoutube!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _launchYouTube(_mealDetails!.strYoutube!),
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Watch on YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _mealDetails!.ingredients.length,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_mealDetails!.ingredients[index]} - ${_mealDetails!.measures[index]}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _mealDetails!.strInstructions,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}