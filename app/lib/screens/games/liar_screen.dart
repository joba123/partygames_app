import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/deck.dart';
import '../../data/liar_questions.dart';
import '../../models/player.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/pass_phone.dart';

enum _LiarPhase { handoff, answering, reveal, voting, resolution }

/// Finde den Lügner.
///
/// The phone goes round once: everyone reads a question and types a short
/// answer. All but one read the same question — the liar gets the decoy and
/// does not know it. Afterwards the real question goes on the table together
/// with every answer, and the group works out whose answer belongs to a
/// different question.
class LiarScreen extends StatefulWidget {
  const LiarScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<LiarScreen> createState() => _LiarScreenState();
}

class _LiarScreenState extends State<LiarScreen> {
  final _random = Random();
  final _controller = TextEditingController();

  late final Deck<LiarQuestion> _deck = Deck(liarQuestions, random: _random);

  late LiarQuestion _question;
  late int _liarIndex;

  _LiarPhase _phase = _LiarPhase.handoff;
  int _turn = 0;
  int _round = 1;
  int? _accused;

  final Map<String, String> _answers = {};

  int _groupScore = 0;
  int _liarScore = 0;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRound() {
    _question = _deck.draw() ?? liarQuestions.first;
    _liarIndex = _random.nextInt(widget.players.length);
    _turn = 0;
    _accused = null;
    _answers.clear();
    _controller.clear();
    _phase = _LiarPhase.handoff;
  }

  Player get _current => widget.players[_turn];

  bool get _currentIsLiar => _turn == _liarIndex;

  String get _currentQuestion => _currentIsLiar ? _question.decoy : _question.real;

  void _submitAnswer() {
    final answer = _controller.text.trim();
    if (answer.isEmpty) return;
    setState(() {
      _answers[_current.id] = answer;
      _controller.clear();
      if (_turn < widget.players.length - 1) {
        _turn += 1;
        _phase = _LiarPhase.handoff;
      } else {
        _phase = _LiarPhase.reveal;
      }
    });
  }

  void _resolve() {
    setState(() {
      if (_accused == _liarIndex) {
        _groupScore += 1;
      } else {
        _liarScore += 1;
      }
      _phase = _LiarPhase.resolution;
    });
    // Resolving is the end of a round for the promo pacing.
    context.read<AppState>().markRoundFinished();
  }

  void _nextRound() => setState(_startRound);

  @override
  Widget build(BuildContext context) {
    if (_phase == _LiarPhase.handoff) {
      return PassPhoneView(
        player: _current,
        index: _turn,
        total: widget.players.length,
        subtitle: 'Lies deine Frage, tipp deine Antwort — niemand darf mitlesen.',
        onConfirm: () => setState(() => _phase = _LiarPhase.answering),
      );
    }

    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: switch (_phase) {
                _LiarPhase.answering => '${_turn + 1} von ${widget.players.length}',
                _LiarPhase.reveal => 'Runde $_round · Gruppe $_groupScore : $_liarScore Lügner',
                _LiarPhase.voting => 'Runde $_round · Abstimmung',
                _ => 'Runde $_round · Auflösung',
              },
              trailingLabel: '$_groupScore : $_liarScore',
              trailingColor: p.secondary,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: switch (_phase) {
                _LiarPhase.answering => _answerView(context),
                _LiarPhase.reveal => _revealView(context),
                _LiarPhase.voting => _votingView(context),
                _ => _resolutionView(context),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerView(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${germanUpper(_current.name)}, DEINE FRAGE', style: AppText.labelMono(p.textMuted, size: 12)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sheet),
                    border: Border.all(color: p.outlineVariant),
                  ),
                  // Deliberately identical framing for both questions — the
                  // liar must not be able to tell from the screen.
                  child: Text(_currentQuestion,
                      style: AppText.headline(p.textPrimary).copyWith(fontSize: 26, height: 1.25)),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('DEINE ANTWORT', style: AppText.labelMono(p.textMuted, size: 11)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    border: Border.all(color: p.primary, width: 2),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLength: 40,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppText.nameLabel(p.textPrimary).copyWith(fontSize: 19),
                    cursorColor: p.primary,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterStyle: AppText.labelMono(p.textFaint, size: 10),
                      hintText: 'Kurz und knapp',
                      hintStyle: AppText.nameLabel(p.textFaint).copyWith(fontSize: 19),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onSubmitted: (_) => _submitAnswer(),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Ein bis drei Wörter reichen. Zu genau ist verräterisch.',
                    style: AppText.caption(p.textFaint)),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
          child: AppButton(
            label: _turn < widget.players.length - 1
                ? 'Fertig — weiter an ${widget.players[_turn + 1].name}'
                : 'Fertig — alle Antworten zeigen',
            size: AppButtonSize.large,
            onPressed: _submitAnswer,
          ),
        ),
      ],
    );
  }

  Widget _revealView(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
            children: [
              Text('DIE ECHTE FRAGE WAR', style: AppText.labelMono(p.accentSafe, size: 11)),
              const SizedBox(height: 12),
              Text(_question.real, style: AppText.headline(p.textPrimary).copyWith(fontSize: 24, height: 1.25)),
              const SizedBox(height: AppSpacing.xl),
              Container(height: 1, color: p.outlineVariant),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < widget.players.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AnswerCard(
                    player: widget.players[i],
                    colorIndex: i,
                    answer: _answers[widget.players[i].id] ?? '—',
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Eine dieser Antworten gehört zu einer anderen Frage. Redet drüber, '
                'dann stimmt ab.',
                style: AppText.bodySmall(p.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
          child: AppButton(
            label: 'Abstimmen',
            size: AppButtonSize.large,
            onPressed: () => setState(() => _phase = _LiarPhase.voting),
          ),
        ),
      ],
    );
  }

  Widget _votingView(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
            children: [
              Text('Wer hat gelogen?', style: AppText.headline(p.textPrimary)),
              const SizedBox(height: 8),
              Text('Einigt euch auf einen Namen und tippt ihn an.', style: AppText.bodySmall(p.textSecondary)),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < widget.players.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AnswerCard(
                    player: widget.players[i],
                    colorIndex: i,
                    answer: _answers[widget.players[i].id] ?? '—',
                    selected: _accused == i,
                    onTap: () => setState(() => _accused = i),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
          child: AppButton(
            label: _accused == null ? 'Erst jemanden wählen' : 'Auflösen',
            size: AppButtonSize.large,
            onPressed: _accused == null ? null : _resolve,
          ),
        ),
      ],
    );
  }

  Widget _resolutionView(BuildContext context) {
    final p = context.palette;
    final liar = widget.players[_liarIndex];
    final caught = _accused == _liarIndex;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
            children: [
              Text(caught ? 'ERWISCHT' : 'DURCHGERUTSCHT',
                  style: AppText.labelMono(caught ? p.accentSafe : p.danger, size: 12)),
              const SizedBox(height: 12),
              Text('${liar.name} hat gelogen', style: AppText.headline(p.textPrimary)),
              const SizedBox(height: AppSpacing.xl),
              _QuestionRow(label: 'ALLE ANDEREN', question: _question.real, color: p.accentSafe),
              const SizedBox(height: 12),
              _QuestionRow(label: '${germanUpper(liar.name)} BEKAM', question: _question.decoy, color: p.danger),
              const SizedBox(height: AppSpacing.xl),
              Text(
                caught
                    ? 'Die Gruppe hat es erkannt — ein Punkt für die Gruppe.'
                    : 'Falsch geraten. Der Punkt geht an ${liar.name}.',
                style: AppText.bodySmall(p.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
          child: Column(
            children: [
              AppButton(
                label: 'Nächste Runde',
                size: AppButtonSize.large,
                onPressed: () {
                  setState(() => _round += 1);
                  _nextRound();
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Spiel beenden',
                filled: false,
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.player,
    required this.colorIndex,
    required this.answer,
    this.selected = false,
    this.onTap,
  });

  final Player player;
  final int colorIndex;
  final String answer;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.danger.withValues(alpha: .12) : p.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: selected ? p.danger : p.outlineVariant, width: selected ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarCircle(initial: player.initial, colorIndex: colorIndex, size: 40, fontSize: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(germanUpper(player.name), style: AppText.labelMono(p.textFaint, size: 10)),
                    const SizedBox(height: 6),
                    Text(answer, style: AppText.title(p.textPrimary).copyWith(fontSize: 19, height: 1.25)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.label, required this.question, required this.color});

  final String label;
  final String question;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.labelMono(color, size: 10)),
          const SizedBox(height: 8),
          Text(question, style: AppText.bodySmall(p.textPrimary).copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}
