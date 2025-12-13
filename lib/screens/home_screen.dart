import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_recipe_app/models/meal_details.dart';
import 'package:my_recipe_app/screens/favorites_screen.dart';
import 'package:my_recipe_app/services/favorites_service.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import 'meals_screen.dart';
import 'meal_details_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    print('Firebase initialized: ${Firebase.apps.isNotEmpty}');
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.fetchCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ErrorL $e')),
        );
      }
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCategories = _categories
        .where((cat) =>
        cat.strCategory.toLowerCase().contains(query.toLowerCase()))
      .toList();
    });
  }

  Future<void> _showRandomMeal() async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator(),
          )
      );

      final randomMeal = await _apiService.fetchRandomMeal();

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MealDetailsScreen(mealId: randomMeal.idMeal),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading random meal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Categories'),
        backgroundColor: Colors.pink,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'My Favorites',
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random Recipe',
            onPressed: _showRandomMeal,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterCategories,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCategories.isEmpty
                ? Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No categories found'
                    : 'No results for "$_searchQuery"',
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                return CategoryCard(
                  category: category,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealsScreen(
                          category: category.strCategory,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}