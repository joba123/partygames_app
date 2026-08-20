import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/bet_categories.dart';
import '../../data/deck.dart';
import '../../models/team.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/round_timer.dart';
import '../shared/game_result_screen.dart';

enum _BetPhase { brief, bidding, challenge, roundResult }

/// Bet Buddy.
///
/// A category comes up and the two teams push each other higher: "wir nennen
/// 12", "wir nennen 15". Whoever loses their nerve calls the other team out —
/// and that team has to actually deliver its own last bid against the clock.
/// Deliver it and the point is theirs; fall short and it goes to the team
/// that called the bluff.
class BetBuddyScreen extends StatefulWidget {
  const BetBuddyScreen({super.key, required this.teams, this.roundsTotal = 4});

  final List<Team> teams;

  /// Kept even so both teams open the bidding equally often.
  final int roundsTotal;

  /// Where the opening bid starts — low enough to leave room to climb.
  static const openingBid = 5;

  /// The bid cannot climb past this; past it the round is a joke, not a game.
  static const maxBid = 99;

  @override
  State<BetBuddyScreen> createState() => _BetBuddyScreenState();
}

class _BetBuddyScreenState extends State<BetBuddyScreen> {
  late Deck<String> _deck = Deck(betCategories, random: Random());

  Timer? _timer;
  _BetPhase _phase = _BetPhase.brief;

  String _category = '';
  int _round = 1;

  /// Team that opens the bidding this round.
  int _openerIndex = 0;

  /// Team whose turn it is to raise or call.
  int _bidderIndex = 0;

  int _lastBid = 0;
  int? _lastBidderIndex;
  int _currentBid = BetBuddyScreen.openingBid;

  int _duration = 90;
  int _secondsLeft = 90;
  int _counter = 0;
  int _target = 0;
  int _deliveringIndex = 0;
  bool _delivered = false;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _category = _deck.draw() ?? betCategories.first;
    _bidderIndex = _openerIndex;
    _lastBid = 0;
    _lastBidderIndex = null;
    _currentBid = BetBuddyScreen.openingBid;
    _counter = 0;
    _delivered = false;
    _phase = _BetPhase.brief;
  }

  Team get _bidder => widget.teams[_bidderIndex];

  Team get _opponent => widget.teams[1 - _bidderIndex];

  bool get _canCall => _lastBidderIndex != null;

  void _raise(int delta) {
    setState(() {
      _currentBid = (_currentBid + delta).clamp(_lastBid + 1, BetBuddyScreen.maxBid);
    });
  }

  void _placeBid() {
    setState(() {
      _lastBid = _currentBid;
      _lastBidderIndex = _bidderIndex;
      _bidderIndex = 1 - _bidderIndex;
      _currentBid = (_lastBid + 1).clamp(1, BetBuddyScreen.maxBid);
    });
  }

  void _call() {
    final delivering = _lastBidderIndex;
    if (delivering == null) return;
    setState(() {
      _deliveringIndex = delivering;
      _target = _lastBid;
      _counter = 0;
      _secondsLeft = _duration;
      _delivered = false;
      _phase = _BetPhase.challenge;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        _finishChallenge(delivered: false);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _count(int delta) {
    if (_phase != _BetPhase.challenge) return;
    final next = (_counter + delta).clamp(0, _target);
    if (next >= _target) {
      setState(() => _counter = next);
      _finishChallenge(delivered: true);
      return;
    }
    setState(() => _counter = next);
  }

  void _finishChallenge({required bool delivered}) {
    _timer?.cancel();
    setState(() {
      _delivered = delivered;
      // Deliver your own bid and the point is yours; fall short and it goes
      // to the team that dared you.
      widget.teams[delivered ? _deliveringIndex : 1 - _deliveringIndex].score += 1;
      _phase = _BetPhase.roundResult;
    });
  }

  bool get _isLastRound => _round >= widget.roundsTotal;

  void _nextRound() {
    if (_isLastRound) {
      _finish();
      return;
    }
    setState(() {
      _round += 1;
      _openerIndex = 1 - _openerIndex;
      _startRound();
    });
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      for (final t in widget.teams) {
        t.score = 0;
      }
      _deck = Deck(betCategories, random: Random());
      _round = 1;
      _openerIndex = 0;
      _startRound();
    });
  }

  void _finish() {
    _timer?.cancel();
    final entries = widget.teams
        .map((t) => ScoreEntry(name: t.name, score: t.score, detail: t.members.map((m) => m.name).join(', ')))
        .toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: 'Wetten beendet',
        entries: entries,
        scoreUnit: 'Punkte',
        onRematch: () {
          Navigator.of(context).pop();
          _restart();
        },
        onExit: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
    ));
  }

  Color _teamColor(int index) =>
      index == 0 ? context.palette.danger : context.palette.secondary;

  Color _onTeamColor(int index) =>
      index == 0 ? context.palette.onDanger : context.palette.onSecondary;

  @override
  Widget build(BuildContext context) {
    final active = switch (_phase) {
      _BetPhase.brief || _BetPhase.bidding => _bidderIndex,
      _BetPhase.challenge => _deliveringIndex,
      _BetPhase.roundResult => _delivered ? _deliveringIndex : 1 - _deliveringIndex,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: 'Runde $_round von ${widget.roundsTotal}',
              trailingLabel: widget.teams[active].name,
              trailingColor: _teamColor(active),
              onBack: () {
                _timer?.cancel();
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: switch (_phase) {
                  _BetPhase.brief => _briefView(context),
                  _BetPhase.bidding => _biddingView(context),
                  _BetPhase.challenge => _challengeView(context),
                  _BetPhase.roundResult => _resultView(context),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: switch (_phase) {
                _BetPhase.brief => AppButton(
                    label: '${_bidder.name} eröffnet',
                    size: AppButtonSize.large,
                    color: _teamColor(_bidderIndex),
                    onColor: _onTeamColor(_bidderIndex),
                    onPressed: () => setState(() => _phase = _BetPhase.bidding),
                  ),
                _BetPhase.bidding => _biddingActions(context),
                _BetPhase.challenge => _challengeActions(context),
                _BetPhase.roundResult => Column(
                    children: [
                      AppButton(
                        label: _isLastRound ? 'Endstand ansehen' : 'Nächste Runde',
                        size: AppButtonSize.large,
                        onPressed: _nextRound,
                      ),
                      const SizedBox(height: 10),
                      AppButton(label: 'Spiel beenden', filled: false, onPressed: _finish),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _briefView(BuildContext context) {
    final p = context.palette;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('KATEGORIE', style: AppText.labelMono(p.textMuted, size: 11)),
            const SizedBox(height: 12),
            Text(_category, textAlign: TextAlign.center, style: AppText.display(p.textPrimary).copyWith(fontSize: 34)),
            const SizedBox(height: 18),
            Text(
              'Bietet euch hoch: wie viele schafft ihr? Wer nicht mehr mitgeht, '
              'sagt „Zeig’s uns“ — dann muss das andere Team sein letztes Gebot liefern.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall(p.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('ZEIT ZUM ABLIEFERN', style: AppText.labelMono(p.textMuted, size: 11)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final seconds in const [60, 90, 120]) ...[
                  AppChip(
                    label: '$seconds S',
                    mono: true,
                    selected: _duration == seconds,
                    onTap: () => setState(() => _duration = seconds),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _ScoreLine(teams: widget.teams),
          ],
        ),
      ),
    );
  }

  Widget _biddingView(BuildContext context) {
    final p = context.palette;
    final accent = _teamColor(_bidderIndex);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_canCall) ...[
              Text('${germanUpper(widget.teams[_lastBidderIndex!].name)} BIETET',
                  style: AppText.labelMono(_teamColor(_lastBidderIndex!), size: 11)),
              const SizedBox(height: 8),
              Text('$_lastBid × $_category',
                  textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
              const SizedBox(height: AppSpacing.xl),
            ],
            Text('${germanUpper(_bidder.name)}, IHR SEID DRAN', style: AppText.labelMono(accent, size: 12)),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepButton(
                  icon: Icons.remove_rounded,
                  onTap: _currentBid > _lastBid + 1 ? () => _raise(-1) : null,
                ),
                Container(
                  width: 132,
                  alignment: Alignment.center,
                  child: Text('$_currentBid', style: AppText.monoDisplay(p.textPrimary, size: 72)),
                ),
                _StepButton(
                  icon: Icons.add_rounded,
                  onTap: _currentBid < BetBuddyScreen.maxBid ? () => _raise(1) : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(germanUpper(_category), style: AppText.labelMono(p.textMuted, size: 11)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final step in const [2, 5, 10]) ...[
                  AppChip(
                    label: '+$step',
                    mono: true,
                    onTap: _currentBid + step <= BetBuddyScreen.maxBid ? () => _raise(step) : null,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _ScoreLine(teams: widget.teams),
          ],
        ),
      ),
    );
  }

  Widget _biddingActions(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        AppButton(
          label: '$_currentBid bieten — weiter an ${_opponent.name}',
          size: AppButtonSize.large,
          color: _teamColor(_bidderIndex),
          onColor: _onTeamColor(_bidderIndex),
          onPressed: _placeBid,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: _canCall
              ? 'Zeig’s uns! — ${widget.teams[_lastBidderIndex!].name} muss $_lastBid liefern'
              : 'Erst muss jemand bieten',
          filled: false,
          onPressed: _canCall ? _call : null,
        ),
        if (!_canCall) ...[
          const SizedBox(height: 8),
          Text('Das eröffnende Team muss ein Gebot abgeben.',
              style: AppText.caption(p.textFaint).copyWith(fontSize: 12)),
        ],
      ],
    );
  }

  Widget _challengeView(BuildContext context) {
    final p = context.palette;
    final accent = _teamColor(_deliveringIndex);

    return Column(
      children: [
        const SizedBox(height: 6),
        RoundTimerBar(fraction: _duration == 0 ? 0 : _secondsLeft / _duration, color: accent),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatMmSs(_secondsLeft), style: AppText.monoValue(p.textPrimary, size: 20, weight: FontWeight.w700)),
            Text('${germanUpper(widget.teams[_deliveringIndex].name)} LIEFERT',
                style: AppText.labelMono(accent, size: 11)),
          ],
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(germanUpper(_category), style: AppText.labelMono(p.textMuted, size: 11)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$_counter', style: AppText.monoDisplay(accent, size: 84)),
                      Text(' / $_target', style: AppText.monoDisplay(p.textFaint, size: 40)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Nennt reihum Begriffe. Jemand tippt mit.',
                      textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _challengeActions(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Material(
                color: p.surface,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _counter > 0 ? () => _count(-1) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: p.outline),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.undo_rounded, color: p.textSecondary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                label: 'Zählt! +1',
                size: AppButtonSize.large,
                color: p.accentSafe,
                onColor: p.onAccentSafe,
                onPressed: () => _count(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppButton(label: 'Aufgeben', filled: false, onPressed: () => _finishChallenge(delivered: false)),
      ],
    );
  }

  Widget _resultView(BuildContext context) {
    final p = context.palette;
    final delivering = widget.teams[_deliveringIndex];
    final challenger = widget.teams[1 - _deliveringIndex];

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_delivered ? 'GELIEFERT' : 'NICHT GESCHAFFT',
                style: AppText.labelMono(_delivered ? p.accentSafe : p.danger, size: 12)),
            const SizedBox(height: 14),
            Text(
              _delivered
                  ? '${delivering.name} hat $_target geschafft'
                  : '${delivering.name} kam nur auf $_counter von $_target',
              textAlign: TextAlign.center,
              style: AppText.headline(p.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              _delivered
                  ? 'Punkt für ${delivering.name}.'
                  : 'Punkt für ${challenger.name} — richtig gezweifelt.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall(p.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _ScoreLine(teams: widget.teams),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: onTap == null ? p.outlineVariant : p.outline),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 24, color: onTap == null ? p.textDim : p.textPrimary),
        ),
      ),
    );
  }
}

class _ScoreLine extends StatelessWidget {
  const _ScoreLine({required this.teams});

  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < teams.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(':', style: AppText.monoValue(p.textFaint, size: 20)),
            ),
          Column(
            children: [
              Text('${teams[i].score}', style: AppText.monoDisplay(p.textPrimary, size: 32)),
              const SizedBox(height: 6),
              Text(germanUpper(teams[i].name),
                  style: AppText.labelMono(i == 0 ? p.danger : p.secondary, size: 10)),
            ],
          ),
        ],
      ],
    );
  }
}
