import '../core/constants/app_strings.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.totalScore,
    required this.gamesPlayed,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.bestStreak,
    required this.bestScores,
    this.username,
    this.email,
    this.avatarUrl,
  });

  factory AppUser.demo() => const AppUser(
    id: 'demo-user',
    name: AppStrings.demoUserName,
    totalScore: 0,
    gamesPlayed: 0,
    correctAnswers: 0,
    incorrectAnswers: 0,
    bestStreak: 0,
    bestScores: {},
    username: 'demo',
  );

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String? ?? 'demo-user',
    name: json['name'] as String? ?? AppStrings.demoUserName,
    totalScore: json['totalScore'] as int? ?? 0,
    gamesPlayed: json['gamesPlayed'] as int? ?? 0,
    correctAnswers: json['correctAnswers'] as int? ?? 0,
    incorrectAnswers: json['incorrectAnswers'] as int? ?? 0,
    bestStreak: json['bestStreak'] as int? ?? 0,
    bestScores: (json['bestScores'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, value as int),
    ),
    username: json['username'] as String?,
    email: json['email'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
  );

  factory AppUser.fromSupabase(Map<String, dynamic> json, {String? email}) =>
      AppUser(
        id: json['id'] as String,
        name:
            (json['display_name'] as String?) ??
            (json['username'] as String?) ??
            'Futbolero',
        username: json['username'] as String?,
        email: email,
        avatarUrl: json['avatar_url'] as String?,
        totalScore: json['total_points'] as int? ?? 0,
        gamesPlayed: json['games_played'] as int? ?? 0,
        correctAnswers: json['correct_answers'] as int? ?? 0,
        incorrectAnswers: json['incorrect_answers'] as int? ?? 0,
        bestStreak: json['best_streak'] as int? ?? 0,
        bestScores: const {},
      );

  final String id;
  final String name;
  final int totalScore;
  final int gamesPlayed;
  final int correctAnswers;
  final int incorrectAnswers;
  final int bestStreak;
  final Map<String, int> bestScores;
  final String? username;
  final String? email;
  final String? avatarUrl;

  String get initial =>
      name.trim().isEmpty ? 'G' : name.trim()[0].toUpperCase();
  int get totalAnswers => correctAnswers + incorrectAnswers;
  double get accuracy => totalAnswers == 0 ? 0 : correctAnswers / totalAnswers;

  AppUser copyWith({
    String? name,
    int? totalScore,
    int? gamesPlayed,
    int? correctAnswers,
    int? incorrectAnswers,
    int? bestStreak,
    Map<String, int>? bestScores,
    String? username,
    String? email,
    String? avatarUrl,
  }) => AppUser(
    id: id,
    name: name ?? this.name,
    totalScore: totalScore ?? this.totalScore,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
    bestStreak: bestStreak ?? this.bestStreak,
    bestScores: bestScores ?? this.bestScores,
    username: username ?? this.username,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalScore': totalScore,
    'gamesPlayed': gamesPlayed,
    'correctAnswers': correctAnswers,
    'incorrectAnswers': incorrectAnswers,
    'bestStreak': bestStreak,
    'bestScores': bestScores,
    'username': username,
    'email': email,
    'avatarUrl': avatarUrl,
  };
}
