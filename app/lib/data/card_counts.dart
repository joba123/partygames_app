import 'content.dart';
import 'prompts_rounds.dart';
import 'prompts_social.dart';
import 'prompts_truth_dare.dart';
import 'quiz_questions.dart';
import 'word_games.dart';

/// Every prompt the app ships, in one list — so the settings screen can state
/// how many cards the current filter actually leaves, instead of a number
/// somebody once typed into a mockup.
const _allPrompts = <List<Prompt>>[
  truthPrompts,
  darePrompts,
  neverHaveIEverPrompts,
  wouldRatherPrompts,
  duelPrompts,
  bombCategories,
  rouletteRules,
];

/// Word and quiz cards carry no spice rating — they are always in play.
final int _fixedCardCount = charadeWords.length + tabooWords.length + quizQuestions.length;

int activeCardCount(ContentFilter filter) {
  var total = _fixedCardCount;
  for (final pool in _allPrompts) {
    total += pool.where(filter.allows).length;
  }
  return total;
}

/// How many more cards a Plus unlock would add under the current settings.
int lockedPremiumCardCount(ContentFilter filter) {
  if (filter.premium) return 0;
  final unlocked = ContentFilter(spices: filter.spices, noAlcohol: filter.noAlcohol, premium: true);
  var extra = 0;
  for (final pool in _allPrompts) {
    extra += pool.where(unlocked.allows).length - pool.where(filter.allows).length;
  }
  return extra;
}
