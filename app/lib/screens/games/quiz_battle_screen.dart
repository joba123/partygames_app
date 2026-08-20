import 'package:flutter/material.dart';
import '../../data/deck.dart';
import '../../data/quiz_questions.dart';
import '../../models/team.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../shared/game_result_screen.dart';

/// Quiz-Battle. Teams alternate; the answering team taps one of four
/// options, the right one is revealed either way so the round teaches
/// something even when the guess was wrong.
class QuizBattleScreen extends StatefulWidget {
  const QuizBattleScreen({super.key, required this.teams, this.questionsPerTeam = 5});

  final List<Team> teams;
  final int questionsPerTeam;

  @override
  State<QuizBattleScreen> createState() => _QuizBattleScreenState();
}

class _QuizBattleScreenState extends State<QuizBattleScreen> {
  late Deck<QuizQuestion> _deck;
  QuizQuestion? _question;

  int _teamIndex = 0;
  int _questionNumber = 1;
  int? _picked;

  int get _totalQuestions => widget.questionsPerTeam * widget.teams.length;

  Team get _team => widget.teams[_teamIndex];

  bool get _revealed => _picked != null;

  bool get _isLastQuestion => _questionNumber >= _totalQuestions;

  @override
  void initState() {
    super.initState();
    _deck = Deck(quizQuestions);
    _question = _deck.draw();
  }

  void _pick(int index) {
    if (_revealed) return;
    setState(() {
      _picked = index;
      if (index == _question?.correctIndex) _team.score += 1;
    });
  }

  void _next() {
    if (_isLastQuestion) {
      _finish();
      return;
    }
    setState(() {
      _questionNumber += 1;
      _teamIndex = (_teamIndex + 1) % widget.teams.length;
      _picked = null;
      _question = _deck.draw();
    });
  }

  void _restart() {
    setState(() {
      for (final t in widget.teams) {
        t.score = 0;
      }
      _deck = Deck(quizQuestions);
      _question = _deck.draw();
      _teamIndex = 0;
      _questionNumber = 1;
      _picked = null;
    });
  }

  void _finish() {
    final entries = widget.teams
        .map((t) => ScoreEntry(name: t.name, score: t.score, detail: t.members.map((m) => m.name).join(', ')))
        .toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: 'Quiz vorbei',
        entries: entries,
        scoreUnit: 'Richtige',
        onRematch: () {
          Navigator.of(context).pop();
          _restart();
        },
        onExit: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = _teamIndex == 0 ? p.danger : p.secondary;
    final question = _question;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: 'Frage $_questionNumber von $_totalQuestions',
              trailingLabel: _team.name,
              trailingColor: accent,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < widget.teams.length; i++) ...[
                        if (i > 0) const SizedBox(width: 20),
                        Column(
                          children: [
                            Text('${widget.teams[i].score}', style: AppText.monoDisplay(p.textPrimary, size: 30)),
                            const SizedBox(height: 4),
                            Text(widget.teams[i].name.toUpperCase(),
                                style: AppText.labelMono(i == 0 ? p.danger : p.secondary, size: 10)),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(question?.question ?? '',
                      style: AppText.headline(p.textPrimary).copyWith(fontSize: 26, height: 1.25)),
                  const SizedBox(height: AppSpacing.xl),
                  if (question != null)
                    for (var i = 0; i < question.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AnswerOption(
                          label: question.options[i],
                          index: i,
                          state: !_revealed
                              ? _AnswerState.idle
                              : i == question.correctIndex
                                  ? _AnswerState.correct
                                  : (i == _picked ? _AnswerState.wrong : _AnswerState.dimmed),
                          onTap: () => _pick(i),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: Column(
                children: [
                  if (_revealed)
                    AppButton(
                      label: _isLastQuestion
                          ? 'Endstand ansehen'
                          : 'Weiter an ${widget.teams[(_teamIndex + 1) % widget.teams.length].name}',
                      size: AppButtonSize.large,
                      onPressed: _next,
                    )
                  else
                    Text('${_team.name} antwortet — eine Antwort antippen.',
                        textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
                  const SizedBox(height: 10),
                  AppButton(label: 'Spiel beenden', filled: false, onPressed: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AnswerState { idle, correct, wrong, dimmed }

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({required this.label, required this.index, required this.state, required this.onTap});

  final String label;
  final int index;
  final _AnswerState state;
  final VoidCallback onTap;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, border, fg) = switch (state) {
      _AnswerState.idle => (p.surface, p.outlineVariant, p.textPrimary),
      _AnswerState.correct => (p.accentSafe.withValues(alpha: .16), p.accentSafe, p.textPrimary),
      _AnswerState.wrong => (p.danger.withValues(alpha: .14), p.danger, p.textPrimary),
      _AnswerState.dimmed => (p.surface, p.outlineVariant, p.textFaint),
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: state == _AnswerState.idle ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: border, width: state == _AnswerState.idle ? 1 : 2),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: p.surfaceContainer, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text(_letters[index % _letters.length], style: AppText.labelMono(p.textMuted, size: 12)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: AppText.nameLabel(fg).copyWith(height: 1.3))),
            ],
          ),
        ),
      ),
    );
  }
}
