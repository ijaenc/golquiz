import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/ranking_provider.dart';
import 'services/local_storage_service.dart';
import 'services/question_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<_AppDependencies> _initialization = _createDependencies();
  _AppDependencies? _dependencies;

  Future<_AppDependencies> _createDependencies() async {
    final storage = await LocalStorageService.create();
    final auth = AuthProvider(storage);
    await auth.initialize();
    final profile = ProfileProvider(auth);
    final ranking = RankingProvider(profile);
    final quiz = QuizProvider(QuestionService(storage), profile);
    return _dependencies = _AppDependencies(
      auth: auth,
      profile: profile,
      quiz: quiz,
      ranking: ranking,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppDependencies>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('No se pudo iniciar GolQuiz: ${snapshot.error}'),
              ),
            ),
          );
        }
        final dependencies = snapshot.data;
        if (dependencies == null) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dependencies.auth),
            ChangeNotifierProvider.value(value: dependencies.profile),
            ChangeNotifierProvider.value(value: dependencies.quiz),
            ChangeNotifierProvider.value(value: dependencies.ranking),
          ],
          child: const GolQuizApp(),
        );
      },
    );
  }

  @override
  void dispose() {
    _dependencies?.ranking.dispose();
    _dependencies?.quiz.dispose();
    _dependencies?.profile.dispose();
    _dependencies?.auth.dispose();
    super.dispose();
  }
}

class _AppDependencies {
  const _AppDependencies({
    required this.auth,
    required this.profile,
    required this.quiz,
    required this.ranking,
  });

  final AuthProvider auth;
  final ProfileProvider profile;
  final QuizProvider quiz;
  final RankingProvider ranking;
}
