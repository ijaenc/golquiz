class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorValue,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String description;
  final String iconName;
  final int colorValue;
  final bool isActive;
}
