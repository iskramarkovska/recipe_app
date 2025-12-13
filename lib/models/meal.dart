class Meal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String? strCategory;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    this.strCategory
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strCategory: json['strCategory'] ?? '',
    );
  }
}