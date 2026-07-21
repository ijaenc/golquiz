import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:golquiz/data/local_questions.dart';
import 'package:golquiz/main.dart';
import 'package:golquiz/models/quiz_question.dart';
import 'package:golquiz/models/quiz_result.dart';
import 'package:golquiz/providers/profile_provider.dart';

void main() {
  Future<void> enterDemo(WidgetTester tester) async {
    final demoButton = find.text('Entrar como usuario demo');
    expect(demoButton, findsOneWidget);
    await tester.ensureVisible(demoButton);
    await tester.tap(demoButton);
    await tester.pumpAndSettle();
  }

  testWidgets('usuario demo puede entrar al home con cuatro destinos', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await enterDemo(tester);

    expect(find.text('¡Hola!'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Ranking'), findsWidgets);
    expect(find.text('Grupos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('flujo local anterior llega a un quiz de cinco preguntas', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(414, 896);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await enterDemo(tester);

    final categoryButton = find.text('Elegir categoría');
    await tester.ensureVisible(categoryButton);
    await tester.tap(categoryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mundiales').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar quiz'));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 1 de 5'), findsOneWidget);
    expect(find.text('Responder'), findsOneWidget);
  });

  testWidgets('login se adapta al tamaño lógico de iPhone 11', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(414, 896);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de vuelta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login se adapta a iPhone posterior de 393 puntos', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de vuelta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('banco conserva 150 preguntas y diez por combinación', () {
    expect(localQuestions, hasLength(150));
    for (final category in quizCategories) {
      for (final difficulty in QuizDifficulty.values) {
        final count = localQuestions
            .where(
              (question) =>
                  question.categoryId == category.id &&
                  question.difficulty == difficulty,
            )
            .length;
        expect(count, 10, reason: '${category.id}/${difficulty.name}');
      }
    }
  });

  testWidgets('un mismo resultado local se procesa una sola vez', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await enterDemo(tester);
    final profile = Provider.of<ProfileProvider>(
      tester.element(find.text('¡Hola!')),
      listen: false,
    );
    const result = QuizResult(
      categoryId: 'world_cups',
      categoryName: 'Mundiales',
      difficulty: QuizDifficulty.easy,
      questionCount: 5,
      score: 50,
      correctAnswers: 5,
      incorrectAnswers: 0,
      bestStreak: 5,
      attemptId: 'test-attempt-id',
    );

    await profile.recordResult(result);
    await profile.recordResult(result);

    expect(profile.user.gamesPlayed, 1);
    expect(profile.user.totalScore, 50);
  });
}
