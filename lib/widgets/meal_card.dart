import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_recipe_app/services/favorites_service.dart';
import '../models/meal.dart';


class MealCard extends StatefulWidget {
  final Meal meal;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.meal.idMeal);
    setState(() {
      _isFavorite = isFav;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    await _favoritesService.toggleFavorite(widget.meal.idMeal);
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite
                  ? 'Added to favorites!'
                  : 'Removed from favorites.'
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: widget.meal.strMealThumb,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _isLoading
                        ? const SizedBox(width: 40, height: 40)
                        : IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                              size: 28,
                            ),
                            onPressed: _toggleFavorite,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(8),
                            ),
                        ),
                  ),
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.meal.strMeal,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}