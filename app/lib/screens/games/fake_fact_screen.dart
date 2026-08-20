import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/deck.dart';
import '../../data/fact_cards.dart';
import '../../models/player.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/game_icons.dart';
import '../../widgets/pass_phone.dart';

enum _FactPhase { handoff, card, discussion, voting, resolution }

/// Fake oder Fakt.
///
/// Everyone memorises the same true fact. One player — the fake — sees only
/// the topic and has to invent something that could pass for it. Afterwards
/// everyone states their fact in their own words and the group votes.
///
/// The fake gets the topic rather than a blank screen on purpose: with
/// nothing at all to go on, the bluff is hopeless and the round is over
/// before it starts.
class FakeFactScreen extends StatefulWidget {
  const FakeFactScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<FakeFactScreen> createState() => _FakeFactScreenState();
}

class _FakeFactScreenState extends State<FakeFactScreen> {
  final _random = Random();
  late final Deck<FactCard> _deck = Deck(factCards, random: _random);

  late FactCard _card;
  late int _fakeIndex;

  _FactPhase _phase = _FactPhase.handoff;
  int _turn = 0;
  int _round = 1;
  int? _accused;

  int _groupScore = 0;
  int _fakeScore = 0;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    _card = _deck.draw() ?? factCards.first;
    _fakeIndex = _random.nextInt(widget.players.length);
    _turn = 0;
    _accused = null;
    _phase = _FactPhase.handoff;
  }

  Player get _current => widget.players[_turn];

  bool get _currentIsFake => _turn == _fakeIndex;

  void _afterCard() {
    setState(() {
      if (_turn < widget.players.length - 1) {
        _turn += 1;
        _phase = _FactPhase.handoff;
      } else {
        _phase = _FactPhase.discussion;
      }
    });
  }

  void _resolve() {
    setState(() {
      if (_accused == _fakeIndex) {
        _groupScore += 1;
      } else {
        _fakeScore += 1;
      }
      _phase = _FactPhase.resolution;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _FactPhase.handoff) {
      return PassPhoneView(
        player: _current,
        index: _turn,
        total: widget.players.length,
        subtitle: 'Merk dir, was auf der nächsten Seite steht. Niemand liest mit.',
        onConfirm: () => setState(() => _phase = _FactPhase.card),
      );
    }

    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: switch (_phase) {
                _FactPhase.card => '${_turn + 1} von ${widget.players.length}',
                _FactPhase.discussion => 'Runde $_round · Gruppe $_groupScore : $_fakeScore Fake',
                _FactPhase.voting => 'Runde $_round · Abstimmung',
                _ => 'Runde $_round · Auflösung',
              },
              trailingLabel: '$_groupScore : $_fakeScore',
              trailingColor: p.secondary,
            ),
            Expanded(
              child: switch (_phase) {
                _FactPhase.card => _cardView(context),
                _FactPhase.discussion => _discussionView(context),
                _FactPhase.voting => _votingView(context),
                _ => _resolutionView(context),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardView(BuildContext context) {
    final p = context.palette;
    final fake = _currentIsFake;
    final accent = fake ? p.danger : p.accentSafe;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(AppRadius.sheet),
                    border: Border.all(color: accent.withValues(alpha: .45), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GameIconGlyph(type: GameIconType.fakeFact, color: accent, size: 22),
                          const SizedBox(width: 10),
                          Text(fake ? 'DU BIST DER FAKE' : 'DEIN FAKT',
                              style: AppText.labelMono(accent, size: 12)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('THEMA: ${germanUpper(_card.topic)}', style: AppText.labelMono(p.textMuted, size: 11)),
                      const SizedBox(height: 14),
                      Text(
                        fake
                            ? 'Denk dir einen Fakt aus, der zu diesem Thema passt.'
                            : _card.fact,
                        style: AppText.headline(p.textPrimary).copyWith(fontSize: 24, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  fake
                      ? 'Die anderen haben alle denselben echten Fakt. Erfinde etwas, '
                          'das dazu passen könnte — und hör gut zu, bevor du dran bist.'
                      : 'Merk ihn dir. Gleich gibst du ihn in eigenen Worten wieder — '
                          'nicht wortwörtlich, sonst ist der Fake sofort raus.',
                  style: AppText.bodySmall(p.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
          child: AppButton(
            label: _turn < widget.players.length - 1
                ? 'Gemerkt — weiter an ${widget.players[_turn + 1].name}'
                : 'Gemerkt — los geht’s',
            size: AppButtonSize.large,
            color: p.secondary,
            onColor: p.onSecondary,
            onPressed: _afterCard,
          ),
        ),
      ],
    );
  }

  Widget _discussionView(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameIconGlyph(type: GameIconType.fakeFact, color: p.primary, size: 76),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Reihum erzählen', textAlign: TextAlign.center, style: AppText.headline(p.textPrimary)),
                  const SizedBox(height: 14),
                  Text(
                    'Jeder gibt seinen Fakt in eigenen Worten wieder — beginnend bei '
                    '${widget.players.first.name}. Einer von euch erfindet gerade.',
                    textAlign: TextAlign.center,
                    style: AppText.bodySmall(p.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var i = 0; i < widget.players.length; i++)
                        Container(
                          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: p.outlineVariant),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AvatarCircle(initial: widget.players[i].initial, colorIndex: i, size: 30, fontSize: 13),
                              const SizedBox(width: 10),
                              Text(widget.players[i].name, style: AppText.caption(p.textSecondary).copyWith(fontSize: 14)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
          child: AppButton(
            label: 'Alle durch — abstimmen',
            size: AppButtonSize.large,
            onPressed: () => setState(() => _phase = _FactPhase.voting),
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
              Text('Wer hat sich das ausgedacht?', style: AppText.headline(p.textPrimary)),
              const SizedBox(height: 8),
              Text('Einigt euch und tippt den Namen an.', style: AppText.bodySmall(p.textSecondary)),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < widget.players.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SuspectRow(
                    player: widget.players[i],
                    colorIndex: i,
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
    final fake = widget.players[_fakeIndex];
    final caught = _accused == _fakeIndex;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
            children: [
              Text(caught ? 'ERWISCHT' : 'DAVONGEKOMMEN',
                  style: AppText.labelMono(caught ? p.accentSafe : p.danger, size: 12)),
              const SizedBox(height: 12),
              Text('${fake.name} war der Fake', style: AppText.headline(p.textPrimary)),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: p.accentSafe.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: p.accentSafe.withValues(alpha: .4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DER ECHTE FAKT · ${germanUpper(_card.topic)}',
                        style: AppText.labelMono(p.accentSafe, size: 10)),
                    const SizedBox(height: 8),
                    Text(_card.fact, style: AppText.bodySmall(p.textPrimary).copyWith(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                caught
                    ? 'Die Gruppe hat ihn enttarnt — ein Punkt für die Gruppe.'
                    : 'Niemand hat es gemerkt. Der Punkt geht an ${fake.name}.',
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
                onPressed: () => setState(() {
                  _round += 1;
                  _startRound();
                }),
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

class _SuspectRow extends StatelessWidget {
  const _SuspectRow({
    required this.player,
    required this.colorIndex,
    required this.selected,
    required this.onTap,
  });

  final Player player;
  final int colorIndex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.danger.withValues(alpha: .12) : p.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? p.danger : p.outlineVariant, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              AvatarCircle(initial: player.initial, colorIndex: colorIndex, size: 42, fontSize: 17),
              const SizedBox(width: 14),
              Expanded(
                child: Text(player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title(p.textPrimary).copyWith(fontSize: 19)),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: p.danger, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
