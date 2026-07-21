# GOLQUIZ — CONTEXTO PARA CODEX

## 1. Objetivo general

Construir una aplicación móvil en Flutter + Dart llamada **GolQuiz**, orientada a trivia de fútbol.

El proyecto debe comenzar con una versión local funcional, usando `Provider` y `MultiProvider`, pero quedar preparado para integrar Supabase más adelante.

La aplicación debe respetar en lo posible el mockup existente en Figma:

https://www.figma.com/design/oj40V6uvdGEC0SpcgBSSRL/Trivia-mundial?node-id=0-1&p=f

Nombre visible de la app:
GolQuiz

Nombre del proyecto Flutter:
golquiz

Nombre del repositorio:
golquiz-flutter


## 2. Contexto académico

Curso:
IIP323W — Tecnologías y Aplicaciones Web y Móviles

Tecnologías principales:
- Flutter
- Dart
- Provider
- MultiProvider
- SharedPreferences
- Supabase más adelante
- Consumo de API REST más adelante

Requisitos técnicos del trabajo:
- Mínimo 3 pantallas conectadas.
- Navegación funcional.
- Uso de Provider y MultiProvider.
- Al menos una lista.
- CRUD visible dentro de la aplicación.
- Consumo de datos mediante API o base de datos.
- Uso de Git y commits realizados por los integrantes.
- Diseño coherente con el mockup.
- Aplicación móvil funcional y demostrable.

La propuesta académica original planteaba un MVP con categorías, preguntas de selección múltiple, retroalimentación inmediata, puntaje final, API REST pública de trivia y respaldo local. La versión actual amplía ese alcance con usuario demo, ranking, perfil y futura integración de Supabase.


## 3. Decisiones ya tomadas

### Primera etapa

Se desarrollará primero una versión local y funcional.

La autenticación real con Supabase se implementará después.

Por ahora existirá:
- Usuario demo local.
- Estado de sesión simulado.
- Navegación completa.
- Preguntas locales.
- Ranking simulado.
- Perfil editable.
- Persistencia local con SharedPreferences.

La arquitectura debe quedar preparada para reemplazar el usuario demo por Supabase Auth sin rehacer toda la aplicación.


## 4. Gestión de estado

Usar exclusivamente:
- `provider`
- `MultiProvider`
- `ChangeNotifier`

Providers iniciales:
- `AuthProvider`
- `ProfileProvider`
- `QuizProvider`
- `RankingProvider`

No usar Riverpod, Bloc ni otra solución de estado.


## 5. Flujo principal del MVP

Flujo esperado:

1. Pantalla de bienvenida.
2. Entrada como usuario demo.
3. Home del usuario.
4. Selección de categoría.
5. Apertura de `showModalBottomSheet`.
6. Selección de dificultad.
7. Selección de cantidad de preguntas.
8. Inicio del quiz.
9. Respuesta de preguntas.
10. Retroalimentación inmediata.
11. Resultado final.
12. Actualización de puntaje acumulado.
13. Actualización de ranking.
14. Persistencia local.
15. Consulta del perfil.

Después se agregará:
- Supabase Auth.
- Base de datos.
- Grupos.
- Ranking real.
- CRUD real.
- API deportiva.


## 6. Pantallas del mockup

El mockup actual tiene 5 pantallas principales:

1. Inicio / bienvenida.
2. Selección de categoría.
3. Pregunta activa.
4. Retroalimentación.
5. Resultado final.

Además, para el MVP local deben existir:
- Home.
- Ranking.
- Perfil.

La retroalimentación puede ser un estado dentro de la misma pantalla del quiz, no necesariamente una ruta independiente.


## 7. Navegación recomendada

Después del ingreso demo, usar una navegación principal inferior con:

- Inicio
- Ranking
- Perfil

La pantalla de categorías puede abrirse desde Home.

Durante el quiz no mostrar barra inferior.

No es necesario implementar un router complejo en la primera iteración. Puede usarse `Navigator` y `MaterialPageRoute`, pero la estructura debe permitir migrar a rutas nombradas más adelante.


## 8. Categorías

La aplicación tendrá 5 categorías:

1. Mundiales
2. Jugadores
3. Selecciones
4. Fútbol general
5. Mundial 2026

Cada categoría debe tener:
- id
- nombre
- descripción
- icono
- color o estilo visual
- estado activo


## 9. Configuración del quiz

Al tocar una categoría debe abrirse un:

`showModalBottomSheet`

El modal debe permitir seleccionar:

### Dificultad
- Fácil
- Media
- Difícil

### Cantidad de preguntas
- 5 preguntas
- 10 preguntas

Botón:
- Comenzar quiz

No crear una pantalla adicional para esta configuración.


## 10. Preguntas

Las preguntas serán inicialmente locales.

Cada pregunta debe contener:
- id
- categoría
- dificultad
- enunciado
- cuatro alternativas
- índice o id de respuesta correcta
- explicación
- imagen opcional
- estado activo

Las preguntas deben aparecer:
- mezcladas aleatoriamente;
- sin repetirse dentro de una partida;
- evitando volver a mostrar preguntas ya usadas hasta agotar el banco disponible de esa categoría y dificultad;
- al agotarse el banco, se reinicia el ciclo de preguntas disponibles.

Crear un banco local suficientemente amplio para que el flujo funcione.

Ideal inicial:
- mínimo 10 preguntas por categoría;
- preferentemente distribuidas entre fácil, media y difícil.

Si todavía no existe un banco completo, dejar datos de ejemplo y una estructura clara para ampliarlo.


## 11. Tiempo

No existe temporizador.

El usuario responde a su ritmo.

No hay penalización por demora.


## 12. Puntaje

Puntaje base por respuesta correcta:

- Fácil: 10 puntos.
- Media: 20 puntos.
- Difícil: 30 puntos.

Bono por racha:
- 2 respuestas correctas seguidas: +5 puntos.
- 3 respuestas correctas seguidas: +10 puntos.
- 4 o más respuestas correctas seguidas: +15 puntos por respuesta.

Respuesta incorrecta:
- no suma;
- no resta;
- reinicia la racha actual.

Guardar:
- puntaje de la partida;
- racha actual;
- mejor racha;
- correctas;
- incorrectas;
- porcentaje de acierto.


## 13. Métricas persistentes

El perfil debe guardar:

- nombre;
- avatar o inicial;
- puntaje total acumulado;
- partidas jugadas;
- respuestas correctas;
- respuestas incorrectas;
- porcentaje de acierto;
- mejor racha histórica;
- mejor puntaje por categoría;
- mejor puntaje por dificultad;
- mejor puntaje según cantidad de preguntas.

Ejemplo de clave lógica:

Mundiales + Difícil + 10 preguntas = mejor puntaje.


## 14. Ranking local

El ranking global de la primera versión será simulado.

Debe contener:
- varios usuarios mock;
- usuario demo;
- puntajes mock para los demás usuarios;
- puntaje real acumulado para el usuario demo;
- orden descendente por puntaje;
- posición recalculada automáticamente;
- nombre actualizado desde Perfil;
- avatar o inicial.

El ranking debe persistir el puntaje del usuario demo usando SharedPreferences.


## 15. Perfil local

El usuario demo debe poder:

- ver su nombre;
- editar su nombre;
- ver su puntaje total;
- ver partidas jugadas;
- ver correctas e incorrectas;
- ver porcentaje de acierto;
- ver mejor racha;
- ver mejores puntajes;
- cerrar sesión demo;
- opcionalmente reiniciar datos locales con confirmación.

La edición del nombre debe actualizar:
- Home;
- Ranking;
- Perfil.


## 16. Persistencia local

Usar:
- `shared_preferences`

Guardar como mínimo:
- sesión demo;
- nombre del usuario;
- puntaje total;
- partidas jugadas;
- correctas;
- incorrectas;
- mejor racha;
- mejores puntajes;
- ids de preguntas ya utilizadas por categoría y dificultad.

Crear un servicio dedicado:
- `LocalStorageService`

No colocar llamadas directas a SharedPreferences dentro de cada pantalla.


## 17. Estructura actual del proyecto

La estructura ya fue creada:

lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_spacing.dart
│   ├── routes/
│   │   └── app_routes.dart
│   └── theme/
│       └── app_theme.dart
├── models/
│   ├── app_user.dart
│   ├── quiz_category.dart
│   ├── quiz_question.dart
│   ├── quiz_result.dart
│   └── leaderboard_user.dart
├── providers/
│   ├── auth_provider.dart
│   ├── quiz_provider.dart
│   ├── profile_provider.dart
│   └── ranking_provider.dart
├── services/
│   ├── local_storage_service.dart
│   ├── question_service.dart
│   └── supabase_service.dart
├── screens/
│   ├── welcome/
│   │   └── welcome_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── categories/
│   │   └── categories_screen.dart
│   ├── quiz/
│   │   ├── quiz_screen.dart
│   │   └── result_screen.dart
│   ├── ranking/
│   │   └── ranking_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/
│   ├── primary_button.dart
│   ├── category_card.dart
│   ├── answer_option_card.dart
│   ├── score_badge.dart
│   └── quiz_settings_sheet.dart
└── data/
    └── local_questions.dart


## 18. Dependencias esperadas

Dependencias previstas:

- provider
- shared_preferences
- supabase_flutter
- http
- flutter_dotenv

En esta primera iteración usar principalmente:
- provider
- shared_preferences

No inicializar Supabase todavía si no existen credenciales.


## 19. Diseño visual

Respetar el estilo del Figma:

- Fondo azul oscuro.
- Color primario azul.
- Acento verde.
- Tarjetas blancas.
- Bordes redondeados.
- Botones grandes.
- Tipografía limpia.
- Diseño mobile-first.
- Buen espaciado.
- Feedback visual para respuestas correctas e incorrectas.
- Resultado final con resumen claro.

Colores aproximados ya definidos:

- primary: `#3557E0`
- secondary: `#34C759`
- background: `#101B3F`
- surface: `#F8FAFC`
- textPrimary: `#111827`
- textSecondary: `#64748B`
- success: `#2FAF46`
- error: `#EF4444`

No copiar código React/Tailwind generado desde Figma.
Convertir el diseño a widgets Flutter nativos.


## 20. Arquitectura y responsabilidades

### Screens
Solo interfaz, navegación y consumo de providers.

### Providers
Estado de la aplicación y coordinación de lógica.

### Services
Persistencia, obtención de preguntas y futuras conexiones externas.

### Models
Representación tipada de datos.

### Widgets
Componentes reutilizables.

### Data
Banco local de preguntas.

Evitar lógica extensa dentro de `build()`.


## 21. Supabase futuro

La estructura debe quedar lista para agregar después:

- registro;
- inicio de sesión;
- perfiles;
- preguntas;
- intentos;
- ranking;
- grupos;
- miembros de grupos.

No usar `service_role` dentro de Flutter.

La app móvil usará más adelante:
- Supabase URL;
- anon key o publishable key;
- RLS.

Por ahora `supabase_service.dart` puede quedar como placeholder bien documentado.


## 22. CRUD futuro

El CRUD formal se implementará con grupos de competencia:

- crear grupo;
- listar grupos;
- editar grupo;
- eliminar grupo;
- unirse por código;
- ranking del grupo.

No implementar todavía salvo que el usuario lo solicite.


## 23. API futura

No depender de una API pública para el banco principal de preguntas.

Las preguntas principales deben vivir:
- primero localmente;
- después en Supabase.

Una API deportiva se usará más adelante como complemento para:
- partidos;
- selecciones;
- competiciones;
- información del Mundial 2026.

La app debe seguir funcionando aunque la API falle.


## 24. Forma de trabajar

Trabajar por iteraciones pequeñas.

En cada iteración:
1. Revisar el estado actual del código.
2. Explicar brevemente qué se modificará.
3. Implementar solo el alcance solicitado.
4. Ejecutar:
   - `flutter pub get`
   - `flutter analyze`
   - pruebas disponibles
5. Corregir errores.
6. Entregar resumen de archivos modificados.
7. Proponer un commit con formato claro.

No rehacer la arquitectura sin necesidad.
No eliminar archivos útiles.
No cambiar el diseño sin explicar el motivo.
No agregar dependencias innecesarias.


## 25. Primera meta técnica

La primera meta es lograr una versión completamente navegable con datos locales:

- Welcome.
- Entrada demo.
- Home.
- Categorías.
- Modal de dificultad y cantidad.
- Quiz funcional.
- Retroalimentación.
- Resultado.
- Ranking.
- Perfil.
- Persistencia local.
- MultiProvider funcionando.

Todavía no implementar Supabase ni grupos.


## 26. Criterios de terminado de la primera meta

La iteración se considera terminada cuando:

- La app inicia sin errores.
- `flutter analyze` no presenta errores.
- El usuario puede entrar como demo.
- Puede elegir categoría.
- Puede elegir dificultad.
- Puede elegir 5 o 10 preguntas.
- Las preguntas no se repiten en una partida.
- Se calcula el puntaje correctamente.
- Se aplica el bono por racha.
- Se muestra retroalimentación.
- Se muestra resultado final.
- El puntaje se acumula.
- El ranking cambia.
- El nombre se puede editar.
- Los datos sobreviven al reinicio de la app.


## 27. Prioridad actual

Prioridad máxima:
Construir el MVP local completo, estable y visualmente cercano al Figma.

No comenzar Supabase todavía.
No comenzar API externa todavía.
No comenzar CRUD de grupos todavía.
