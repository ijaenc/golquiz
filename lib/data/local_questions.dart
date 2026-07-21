import '../models/quiz_category.dart';
import '../models/quiz_question.dart';

const quizCategories = <QuizCategory>[
  QuizCategory(
    id: 'world_cups',
    name: 'Mundiales',
    description: 'Historia de las Copas del Mundo',
    iconName: 'trophy',
    colorValue: 0xFFFFB020,
  ),
  QuizCategory(
    id: 'players',
    name: 'Jugadores',
    description: 'Cracks, récords y momentos',
    iconName: 'person',
    colorValue: 0xFF7C3AED,
  ),
  QuizCategory(
    id: 'national_teams',
    name: 'Selecciones',
    description: 'Equipos nacionales y hazañas',
    iconName: 'flag',
    colorValue: 0xFF0EA5E9,
  ),
  QuizCategory(
    id: 'general',
    name: 'Fútbol general',
    description: 'Reglas, ligas y estadios',
    iconName: 'sports_soccer',
    colorValue: 0xFF34C759,
  ),
  QuizCategory(
    id: 'world_cup_2026',
    name: 'Mundial 2026',
    description: 'Sedes, formato y protagonistas',
    iconName: 'public',
    colorValue: 0xFF3557E0,
  ),
];

class _QuestionSeed {
  const _QuestionSeed(this.text, this.options, this.correct, this.explanation);
  final String text;
  final List<String> options;
  final int correct;
  final String explanation;
}

final localQuestions = <QuizQuestion>[
  ..._buildQuestions('world_cups', _worldCups),
  ..._buildQuestions('players', _players),
  ..._buildQuestions('national_teams', _nationalTeams),
  ..._buildQuestions('general', _general),
  ..._buildQuestions('world_cup_2026', _worldCup2026),
];

List<QuizQuestion> _buildQuestions(
  String categoryId,
  List<_QuestionSeed> seeds,
) {
  return [
    for (final difficulty in QuizDifficulty.values)
      for (var index = 0; index < seeds.length; index++)
        QuizQuestion(
          id: '${categoryId}_${difficulty.name}_$index',
          categoryId: categoryId,
          difficulty: difficulty,
          text: seeds[index].text,
          options: seeds[index].options,
          correctAnswerIndex: seeds[index].correct,
          explanation: seeds[index].explanation,
        ),
  ];
}

const _worldCups = <_QuestionSeed>[
  _QuestionSeed(
    '¿Qué selección ganó el Mundial de 2018?',
    ['Argentina', 'Francia', 'Alemania', 'Brasil'],
    1,
    'Francia derrotó a Croacia 4–2 en la final de Rusia 2018.',
  ),
  _QuestionSeed(
    '¿Dónde se disputó el primer Mundial en 1930?',
    ['Brasil', 'Italia', 'Uruguay', 'Francia'],
    2,
    'Uruguay organizó y ganó la primera Copa del Mundo.',
  ),
  _QuestionSeed(
    '¿Qué país tiene más títulos mundiales masculinos?',
    ['Alemania', 'Brasil', 'Italia', 'Argentina'],
    1,
    'Brasil ha conquistado cinco Copas del Mundo.',
  ),
  _QuestionSeed(
    '¿Quién ganó el Mundial de 2022?',
    ['Francia', 'Argentina', 'Croacia', 'España'],
    1,
    'Argentina venció a Francia por penales en Catar 2022.',
  ),
  _QuestionSeed(
    '¿Qué selección ganó el Mundial de 2010?',
    ['Países Bajos', 'Alemania', 'España', 'Italia'],
    2,
    'España logró su primer título mundial en Sudáfrica.',
  ),
  _QuestionSeed(
    '¿En qué Mundial apareció por primera vez la tarjeta roja?',
    ['1966', '1970', '1974', '1978'],
    1,
    'Las tarjetas se introdujeron en México 1970.',
  ),
  _QuestionSeed(
    '¿Quién fue campeón mundial en 2006?',
    ['Francia', 'Brasil', 'Italia', 'Alemania'],
    2,
    'Italia superó a Francia por penales en Berlín.',
  ),
  _QuestionSeed(
    '¿Qué país organizó el Mundial de 2014?',
    ['Sudáfrica', 'Brasil', 'Rusia', 'Alemania'],
    1,
    'Brasil fue sede de la Copa del Mundo 2014.',
  ),
  _QuestionSeed(
    '¿Qué selección ganó dos Mundiales consecutivos en 1958 y 1962?',
    ['Brasil', 'Italia', 'Uruguay', 'Alemania'],
    0,
    'Brasil fue campeón en Suecia 1958 y Chile 1962.',
  ),
  _QuestionSeed(
    '¿Quién fue el goleador del Mundial de 2014?',
    ['Messi', 'Neymar', 'James Rodríguez', 'Müller'],
    2,
    'James Rodríguez marcó seis goles en Brasil 2014.',
  ),
];

const _players = <_QuestionSeed>[
  _QuestionSeed(
    '¿Qué jugador es conocido como O Rei?',
    ['Maradona', 'Pelé', 'Cruyff', 'Zidane'],
    1,
    'Pelé recibió el apodo de O Rei por su extraordinaria carrera.',
  ),
  _QuestionSeed(
    '¿Quién ganó ocho Balones de Oro hasta 2023?',
    ['Cristiano Ronaldo', 'Messi', 'Modrić', 'Ronaldo'],
    1,
    'Lionel Messi alcanzó su octavo Balón de Oro en 2023.',
  ),
  _QuestionSeed(
    '¿Qué jugador portugués usa habitualmente las siglas CR7?',
    ['Figo', 'Eusébio', 'Cristiano Ronaldo', 'Bruno Fernandes'],
    2,
    'CR7 corresponde a Cristiano Ronaldo y su dorsal más famoso.',
  ),
  _QuestionSeed(
    '¿Quién marcó la Mano de Dios en 1986?',
    ['Pelé', 'Maradona', 'Valdano', 'Burruchaga'],
    1,
    'Diego Maradona anotó ese recordado gol ante Inglaterra.',
  ),
  _QuestionSeed(
    '¿Qué arquero ganó el Balón de Oro en 1963?',
    ['Yashin', 'Buffon', 'Banks', 'Casillas'],
    0,
    'Lev Yashin es el único arquero que ha ganado el Balón de Oro.',
  ),
  _QuestionSeed(
    '¿Qué jugador francés encabezó el título mundial de 1998?',
    ['Henry', 'Platini', 'Zidane', 'Deschamps'],
    2,
    'Zinedine Zidane marcó dos goles en la final de 1998.',
  ),
  _QuestionSeed(
    '¿Quién anotó el gol de España en la final de 2010?',
    ['Villa', 'Xavi', 'Iniesta', 'Torres'],
    2,
    'Andrés Iniesta marcó en la prórroga ante Países Bajos.',
  ),
  _QuestionSeed(
    '¿Qué brasileño era apodado O Fenômeno?',
    ['Ronaldinho', 'Rivaldo', 'Ronaldo', 'Romário'],
    2,
    'Ronaldo Nazário fue conocido mundialmente como O Fenômeno.',
  ),
  _QuestionSeed(
    '¿Quién capitaneó a Argentina campeona en 2022?',
    ['Di María', 'Messi', 'Otamendi', 'Martínez'],
    1,
    'Lionel Messi fue el capitán argentino en Catar.',
  ),
  _QuestionSeed(
    '¿Qué jugador croata ganó el Balón de Oro de 2018?',
    ['Rakitić', 'Perišić', 'Modrić', 'Mandžukić'],
    2,
    'Luka Modrić ganó el premio tras una gran temporada y Mundial.',
  ),
];

const _nationalTeams = <_QuestionSeed>[
  _QuestionSeed(
    '¿Cuál es el apodo de la selección de Brasil?',
    ['La Roja', 'Azzurra', 'Canarinha', 'Albiceleste'],
    2,
    'Brasil es conocida como la Canarinha por su camiseta amarilla.',
  ),
  _QuestionSeed(
    '¿Qué selección es conocida como la Albiceleste?',
    ['Uruguay', 'Argentina', 'Paraguay', 'Chile'],
    1,
    'El apodo alude a los colores blanco y celeste de Argentina.',
  ),
  _QuestionSeed(
    '¿Qué selección ganó la Eurocopa 2016?',
    ['Francia', 'España', 'Portugal', 'Italia'],
    2,
    'Portugal venció a Francia en la final disputada en París.',
  ),
  _QuestionSeed(
    '¿Qué país ganó la Copa América 2015?',
    ['Argentina', 'Chile', 'Brasil', 'Uruguay'],
    1,
    'Chile consiguió su primer título continental en 2015.',
  ),
  _QuestionSeed(
    '¿Qué selección africana alcanzó semifinales en 2022?',
    ['Senegal', 'Ghana', 'Marruecos', 'Camerún'],
    2,
    'Marruecos fue la primera selección africana semifinalista mundial.',
  ),
  _QuestionSeed(
    '¿Qué selección viste tradicionalmente de naranja?',
    ['Bélgica', 'Países Bajos', 'Dinamarca', 'Suiza'],
    1,
    'El naranja es el color tradicional de Países Bajos.',
  ),
  _QuestionSeed(
    '¿Cuál es el apodo de la selección italiana?',
    ['Azzurra', 'Blaugrana', 'Celeste', 'Ticos'],
    0,
    'Italia recibe el nombre de Azzurra por su camiseta azul.',
  ),
  _QuestionSeed(
    '¿Qué país ganó la primera Eurocopa en 1960?',
    ['España', 'URSS', 'Italia', 'Francia'],
    1,
    'La Unión Soviética ganó la edición inaugural.',
  ),
  _QuestionSeed(
    '¿Qué selección ganó el Mundial femenino de 2023?',
    ['Inglaterra', 'Estados Unidos', 'España', 'Suecia'],
    2,
    'España venció a Inglaterra en la final de Sídney.',
  ),
  _QuestionSeed(
    '¿Qué selección es conocida como los Samuráis Azules?',
    ['Corea del Sur', 'Japón', 'China', 'Australia'],
    1,
    'Samuráis Azules es el apodo de la selección japonesa.',
  ),
];

const _general = <_QuestionSeed>[
  _QuestionSeed(
    '¿Cuántos jugadores inicia cada equipo en cancha?',
    ['9', '10', '11', '12'],
    2,
    'Cada equipo comienza con once jugadores, incluido el arquero.',
  ),
  _QuestionSeed(
    '¿Cuánto dura un partido reglamentario sin descuentos?',
    ['80 min', '90 min', '100 min', '120 min'],
    1,
    'Se juegan dos tiempos de 45 minutos.',
  ),
  _QuestionSeed(
    '¿Qué tarjeta indica expulsión?',
    ['Azul', 'Amarilla', 'Roja', 'Verde'],
    2,
    'La tarjeta roja obliga al jugador a abandonar el partido.',
  ),
  _QuestionSeed(
    '¿Desde dónde se ejecuta un penal?',
    ['9 metros', '10 metros', '11 metros', '12 metros'],
    2,
    'El punto penal está a once metros de la línea de gol.',
  ),
  _QuestionSeed(
    '¿Qué organismo gobierna el fútbol mundial?',
    ['UEFA', 'CONMEBOL', 'FIFA', 'COI'],
    2,
    'La FIFA es el organismo rector internacional del fútbol.',
  ),
  _QuestionSeed(
    '¿Cuántos puntos entrega normalmente una victoria de liga?',
    ['1', '2', '3', '4'],
    2,
    'El sistema moderno entrega tres puntos por victoria.',
  ),
  _QuestionSeed(
    '¿Qué club juega sus partidos en Anfield?',
    ['Arsenal', 'Liverpool', 'Chelsea', 'Everton'],
    1,
    'Anfield es el estadio del Liverpool FC.',
  ),
  _QuestionSeed(
    '¿En qué país nació el fútbol moderno?',
    ['Italia', 'Brasil', 'Inglaterra', 'Francia'],
    2,
    'Las reglas modernas se codificaron en Inglaterra en el siglo XIX.',
  ),
  _QuestionSeed(
    '¿Qué significa un hat-trick?',
    [
      'Tres asistencias',
      'Tres goles de un jugador',
      'Tres penales',
      'Tres tarjetas',
    ],
    1,
    'Un hat-trick son tres goles del mismo jugador en un partido.',
  ),
  _QuestionSeed(
    '¿Qué competición europea usa un trofeo de grandes asas?',
    ['Europa League', 'Champions League', 'Conference League', 'Supercopa'],
    1,
    'La copa de la Champions es popularmente llamada la Orejona.',
  ),
];

const _worldCup2026 = <_QuestionSeed>[
  _QuestionSeed(
    '¿Cuántos países coorganizaron el Mundial 2026?',
    ['1', '2', '3', '4'],
    2,
    'Canadá, Estados Unidos y México fueron los tres coanfitriones.',
  ),
  _QuestionSeed(
    '¿Cuántas selecciones participaron en el Mundial 2026?',
    ['32', '36', '40', '48'],
    3,
    'La edición de 2026 reunió a 48 selecciones.',
  ),
  _QuestionSeed(
    '¿Qué país fue sede por tercera vez en 2026?',
    ['Canadá', 'Estados Unidos', 'México', 'Argentina'],
    2,
    'México ya fue sede en 1970 y 1986.',
  ),
  _QuestionSeed(
    '¿Qué sede fue elegida para la final de 2026?',
    ['Los Ángeles', 'Ciudad de México', 'Miami', 'Nueva York/Nueva Jersey'],
    3,
    'La final se programó en el estadio de Nueva York/Nueva Jersey.',
  ),
  _QuestionSeed(
    '¿Qué selección llegó al torneo como campeona vigente?',
    ['Francia', 'Argentina', 'Brasil', 'España'],
    1,
    'Argentina ganó el Mundial anterior, Catar 2022.',
  ),
  _QuestionSeed(
    '¿Cuántos partidos contempló el Mundial 2026?',
    ['64', '80', '96', '104'],
    3,
    'El formato oficial contempla 104 encuentros.',
  ),
  _QuestionSeed(
    '¿Cuál de estos países debutó como anfitrión mundialista?',
    ['México', 'Estados Unidos', 'Canadá', 'Brasil'],
    2,
    'Canadá nunca había albergado un Mundial masculino.',
  ),
  _QuestionSeed(
    '¿En qué continente se disputó el Mundial 2026?',
    ['Europa', 'Asia', 'América del Norte', 'África'],
    2,
    'Las sedes están repartidas por América del Norte.',
  ),
  _QuestionSeed(
    '¿Cuántos grupos tuvo la fase inicial?',
    ['8', '10', '12', '16'],
    2,
    'El formato tuvo doce grupos de cuatro selecciones.',
  ),
  _QuestionSeed(
    '¿Qué estadio mexicano volvió a recibir partidos mundialistas?',
    ['Azteca', 'Maracaná', 'Centenario', 'Monumental'],
    0,
    'El Estadio Azteca fue sede mundialista por tercera ocasión.',
  ),
];
