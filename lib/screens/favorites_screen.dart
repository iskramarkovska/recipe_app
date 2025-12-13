import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/meal_details.dart';
import '../services/favorites_service.dart';
import '../services/api_service.dart';
import '../widgets/meal_card.dart';
import 'meal_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final ApiService _apiService = ApiService();

  List<Meal> _favoriteMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<String> favoriteIds = await _favoritesService.getFavorites();

      List<Meal> meals = [];
      for (String id in favoriteIds) {
        try {
          MealDetails detail = await _apiService.fetchMealDetails(id);
          meals.add(
            Meal(
              idMeal: detail.idMeal,
              strMeal: detail.strMeal,
              strMealThumb: detail.strMealThumb,
              strCategory: detail.strCategory,
            ),
          );
        } catch (e) {
          print('Error loading meal $id: $e');
        }
      }

      setState(() {
        _favoriteMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading favorites: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: const Color.fromARGB(255, 234, 24, 101),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteMeals.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet!',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any meal to save it here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadFavorites,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _favoriteMeals.length,
          itemBuilder: (context, index) {
            final meal = _favoriteMeals[index];
            return MealCard(
              meal: meal,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MealDetailsScreen(mealId: meal.idMeal),
                  ),
                );
                _loadFavorites();
              },
            );
          },
        ),
      ),
    );
  }
}
