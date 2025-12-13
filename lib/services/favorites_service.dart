import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_meals';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    if (!favorites.contains(mealId)) {
      favorites.add(mealId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    favorites.remove(mealId);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    return favorites.contains(mealId);
  }

  Future<void> toggleFavorite(String mealId) async {
    if (await isFavorite(mealId)) {
      await removeFavorite(mealId);
    } else {
      await addFavorite(mealId);
    }
  }
}
