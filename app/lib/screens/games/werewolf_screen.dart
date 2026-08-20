import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/werewolf_round.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/game_icons.dart';
import '../../widgets/grid_background.dart';
import '../../widgets/pass_phone.dart';

enum _WolfPhase {
  deal,
  dealCard,
  nightFalls,
  wolvesWake,
  wolvesChoose,
  seerWake,
  seerChoose,
  seerResult,
  witchWake,
  witchChoose,
  morning,
  dayVote,
  dayResult,
  gameOver,
}

/// Werwölfe. The app is the narrator: it wakes each role in turn, takes their
/// choice in private and reads out the casualties in the morning. Everything
/// in between — the accusations, the lying — happens in the room.
class WerewolfScreen extends StatefulWidget {
  const WerewolfScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<WerewolfScreen> createState() => _WerewolfScreenState();
}

class _WerewolfScreenState extends State<WerewolfScreen> {
  late WerewolfRound _round = WerewolfRound(widget.players);

  _WolfPhase _phase = _WolfPhase.deal;
  int _dealIndex = 0;
  int? _selection;
  int? _seerTarget;
  int? _lynched;

  List<Player> get _players => widget.players;

  void _restart() {
    setState(() {
      _round = WerewolfRound(widget.players);
      _phase = _WolfPhase.deal;
      _dealIndex = 0;
      _selection = null;
      _seerTarget = null;
      _lynched = null;
    });
  }

  void _afterDealCard() {
    setState(() {
      if (_dealIndex < _players.length - 1) {
        _dealIndex += 1;
        _phase = _WolfPhase.deal;
      } else {
        _phase = _WolfPhase.nightFalls;
      }
    });
  }

  /// Skips straight past any role whose holder is already dead.
  void _afterWolves() {
    setState(() {
      _round.wolfVictim = _selection;
      _selection = null;
      _phase = _round.seerIndex != null ? _WolfPhase.seerWake : _nextAfterSeer();
    });
  }

  _WolfPhase _nextAfterSeer() =>
      _round.witchIndex != null ? _WolfPhase.witchWake : _WolfPhase.morning;

  void _afterSeer() {
    setState(() {
      _seerTarget = _selection;
      _selection = null;
      _phase = _WolfPhase.seerResult;
    });
  }

  void _afterWitch({required bool heal, int? poison}) {
    setState(() {
      if (heal) {
        _round.healed = true;
        _round.healUsed = true;
      }
      if (poison != null) {
        _round.poisoned = poison;
        _round.poisonUsed = true;
      }
      _selection = null;
      _phase = _WolfPhase.morning;
    });
  }

  void _toMorning() {
    setState(() {
      _round.resolveNight();
      _phase = _round.outcome != null ? _WolfPhase.gameOver : _WolfPhase.dayVote;
    });
  }

  void _lynch() {
    final target = _selection;
    if (target == null) return;
    setState(() {
      _round.lynch(target);
      _lynched = target;
      _selection = null;
      _phase = _WolfPhase.dayResult;
    });
  }

  void _nextNight() {
    setState(() {
      if (_round.outcome != null) {
        _phase = _WolfPhase.gameOver;
        return;
      }
      _round.nextNight();
      _lynched = null;
      _phase = _WolfPhase.nightFalls;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The two handoff screens own the whole viewport — they must not look
    // like game content.
    if (_phase == _WolfPhase.deal) {
      return PassPhoneView(
        player: _players[_dealIndex],
        index: _dealIndex,
        total: _players.length,
        subtitle: 'Deine Rolle sieht nur du. Halt das Handy flach.',
        onConfirm: () => setState(() => _phase = _WolfPhase.dealCard),
      );
    }

    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: switch (_phase) {
                _WolfPhase.dealCard => 'Rollen · ${_dealIndex + 1} von ${_players.length}',
                _WolfPhase.gameOver => 'Ende',
                _ => 'Nacht ${_round.night} · ${_round.aliveIndices.length} leben',
              },
              trailingLabel: switch (_phase) {
                // The night has not started while the roles are still going round.
                _WolfPhase.dealCard || _WolfPhase.gameOver => null,
                _WolfPhase.dayVote || _WolfPhase.dayResult => 'Tag',
                _ => 'Nacht',
              },
              trailingColor: p.secondary,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: switch (_phase) {
                  _WolfPhase.dealCard => _roleCard(context),
                  _WolfPhase.nightFalls => _nightFalls(context),
                  _WolfPhase.wolvesWake => _wake(context, 'Werwölfe', 'Wacht auf und einigt euch lautlos auf ein Opfer.', p.danger),
                  _WolfPhase.wolvesChoose => _pickList(context, 'Wen holt ihr euch?', _round.aliveVillagers),
                  _WolfPhase.seerWake => _wake(context, 'Seherin', 'Wach auf. Du darfst eine Rolle sehen.', p.accentSafe),
                  _WolfPhase.seerChoose => _pickList(context, 'In wen schaust du hinein?',
                      _round.aliveIndices.where((i) => i != _round.seerIndex).toList()),
                  _WolfPhase.seerResult => _seerResultView(context),
                  _WolfPhase.witchWake => _wake(context, 'Hexe', 'Wach auf. Du siehst gleich, wen es erwischt hat.', p.warning),
                  _WolfPhase.witchChoose => _witchView(context),
                  _WolfPhase.morning => _morningView(context),
                  _WolfPhase.dayVote => _pickList(context, 'Wen hängt das Dorf?', _round.aliveIndices),
                  _WolfPhase.dayResult => _dayResultView(context),
                  _WolfPhase.gameOver => _gameOverView(context),
                  _WolfPhase.deal => const SizedBox.shrink(),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: _actions(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final p = context.palette;
    return switch (_phase) {
      _WolfPhase.dealCard => AppButton(
          label: _dealIndex < _players.length - 1
              ? 'Gemerkt — weiter an ${_players[_dealIndex + 1].name}'
              : 'Alle haben ihre Rolle',
          size: AppButtonSize.large,
          color: p.secondary,
          onColor: p.onSecondary,
          onPressed: _afterDealCard,
        ),
      _WolfPhase.nightFalls => AppButton(
          label: 'Werwölfe aufwecken',
          size: AppButtonSize.large,
          onPressed: () => setState(() => _phase = _WolfPhase.wolvesWake),
        ),
      _WolfPhase.wolvesWake => AppButton(
          label: 'Wir sind wach',
          size: AppButtonSize.large,
          color: p.danger,
          onColor: p.onDanger,
          onPressed: () => setState(() => _phase = _WolfPhase.wolvesChoose),
        ),
      _WolfPhase.wolvesChoose => AppButton(
          label: _selection == null ? 'Opfer wählen' : 'Opfer bestätigen',
          size: AppButtonSize.large,
          color: p.danger,
          onColor: p.onDanger,
          onPressed: _selection == null ? null : _afterWolves,
        ),
      _WolfPhase.seerWake => AppButton(
          label: 'Ich bin wach',
          size: AppButtonSize.large,
          color: p.accentSafe,
          onColor: p.onAccentSafe,
          onPressed: () => setState(() => _phase = _WolfPhase.seerChoose),
        ),
      _WolfPhase.seerChoose => AppButton(
          label: _selection == null ? 'Jemanden wählen' : 'Hineinschauen',
          size: AppButtonSize.large,
          color: p.accentSafe,
          onColor: p.onAccentSafe,
          onPressed: _selection == null ? null : _afterSeer,
        ),
      _WolfPhase.seerResult => AppButton(
          label: 'Gemerkt — weiterschlafen',
          size: AppButtonSize.large,
          onPressed: () => setState(() => _phase = _nextAfterSeer()),
        ),
      _WolfPhase.witchWake => AppButton(
          label: 'Ich bin wach',
          size: AppButtonSize.large,
          color: p.warning,
          onColor: p.onWarning,
          onPressed: () => setState(() => _phase = _WolfPhase.witchChoose),
        ),
      _WolfPhase.witchChoose => _witchActions(context),
      _WolfPhase.morning => AppButton(
          label: _round.outcome != null ? 'Auflösung' : 'Das Dorf berät',
          size: AppButtonSize.large,
          onPressed: _toMorning,
        ),
      _WolfPhase.dayVote => AppButton(
          label: _selection == null ? 'Erst jemanden wählen' : 'Urteil vollstrecken',
          size: AppButtonSize.large,
          onPressed: _selection == null ? null : _lynch,
        ),
      _WolfPhase.dayResult => AppButton(
          label: _round.outcome != null ? 'Auflösung' : 'Die Nacht bricht an',
          size: AppButtonSize.large,
          onPressed: _nextNight,
        ),
      _WolfPhase.gameOver => Column(
          children: [
            AppButton(label: 'Neue Runde', size: AppButtonSize.large, onPressed: _restart),
            const SizedBox(height: 10),
            AppButton(
              label: 'Zurück zur Übersicht',
              filled: false,
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ],
        ),
      _WolfPhase.deal => const SizedBox.shrink(),
    };
  }

  Widget _roleCard(BuildContext context) {
    final p = context.palette;
    final role = _round.roles[_dealIndex];
    final wolf = role == WolfRole.werwolf;
    final accent = switch (role) {
      WolfRole.werwolf => p.danger,
      WolfRole.seher => p.accentSafe,
      WolfRole.hexe => p.warning,
      WolfRole.dorfbewohner => p.textSecondary,
    };
    final packmates = wolf
        ? [
            for (var i = 0; i < _players.length; i++)
              if (i != _dealIndex && _round.roles[i] == WolfRole.werwolf) _players[i].name,
          ]
        : const <String>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
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
                Text(germanUpper('${_players[_dealIndex].name}, du bist'),
                    style: AppText.labelMono(p.textMuted, size: 11)),
                const SizedBox(height: 14),
                Text(role.label, style: AppText.display(accent).copyWith(fontSize: 38)),
                const SizedBox(height: 14),
                Text(role.blurb, style: AppText.bodySmall(p.textPrimary).copyWith(fontSize: 16)),
                if (packmates.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(height: 1, color: accent.withValues(alpha: .3)),
                  const SizedBox(height: AppSpacing.lg),
                  Text('DEIN RUDEL', style: AppText.labelMono(accent, size: 10)),
                  const SizedBox(height: 8),
                  Text(packmates.join(', '), style: AppText.title(p.textPrimary).copyWith(fontSize: 19)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Merk dir die Rolle und gib das Handy weiter, ohne den Bildschirm zu zeigen.',
            style: AppText.bodySmall(p.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _nightFalls(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameIconGlyph(type: GameIconType.werewolf, color: p.secondary, size: 96),
          const SizedBox(height: AppSpacing.xl),
          Text('Nacht ${_round.night}', textAlign: TextAlign.center, style: AppText.display(p.textPrimary).copyWith(fontSize: 40)),
          const SizedBox(height: 14),
          Text('Alle schließen die Augen. Das Handy wandert zu den Rollen, die dran sind.',
              textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          _AliveStrip(round: _round, players: _players),
        ],
      ),
    );
  }

  Widget _wake(BuildContext context, String role, String instruction, Color accent) {
    return GridBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(germanUpper(role), style: AppText.labelMono(accent, size: 13).copyWith(letterSpacing: 13 * 0.24)),
            const SizedBox(height: 20),
            Text(instruction,
                textAlign: TextAlign.center,
                style: AppText.headline(context.palette.textPrimary).copyWith(fontSize: 26, height: 1.3)),
            const SizedBox(height: 18),
            Text('Erst tippen, wenn nur die richtige Person schaut.',
                textAlign: TextAlign.center, style: AppText.caption(context.palette.textFaint)),
          ],
        ),
      ),
    );
  }

  Widget _pickList(BuildContext context, String title, List<int> candidates) {
    final p = context.palette;
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Text(title, style: AppText.headline(p.textPrimary)),
        const SizedBox(height: AppSpacing.lg),
        for (final i in candidates)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlayerRow(
              player: _players[i],
              colorIndex: i,
              selected: _selection == i,
              onTap: () => setState(() => _selection = i),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _seerResultView(BuildContext context) {
    final p = context.palette;
    final target = _seerTarget!;
    final role = _round.roles[target];
    final wolf = role == WolfRole.werwolf;
    final accent = wolf ? p.danger : p.accentSafe;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarCircleRound(initial: _players[target].initial, colorIndex: target, size: 96, fontSize: 40),
          const SizedBox(height: AppSpacing.xl),
          Text(germanUpper(_players[target].name), style: AppText.labelMono(p.textMuted, size: 12)),
          const SizedBox(height: 12),
          Text('ist ${role.label}', textAlign: TextAlign.center, style: AppText.display(accent).copyWith(fontSize: 34)),
          const SizedBox(height: 18),
          Text(wolf ? 'Behalt es für dich, solange du kannst.' : 'Eine Sorge weniger.',
              textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
        ],
      ),
    );
  }

  Widget _witchView(BuildContext context) {
    final p = context.palette;
    final victim = _round.wolfVictim;

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Text('Die Wölfe haben zugeschlagen', style: AppText.headline(p.textPrimary).copyWith(fontSize: 26)),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: p.danger.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: p.danger.withValues(alpha: .4)),
          ),
          child: Text(
            victim == null ? 'Niemand wurde gewählt.' : '${_players[victim].name} liegt vor dir.',
            style: AppText.title(p.textPrimary).copyWith(fontSize: 20),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('GIFT — WEN ERWISCHT ES?', style: AppText.labelMono(p.textMuted, size: 11)),
        const SizedBox(height: 12),
        if (_round.poisonUsed)
          Text('Dein Gifttrank ist verbraucht.', style: AppText.bodySmall(p.textFaint))
        else
          for (final i in _round.aliveIndices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PlayerRow(
                player: _players[i],
                colorIndex: i,
                selected: _selection == i,
                onTap: () => setState(() => _selection = _selection == i ? null : i),
              ),
            ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _witchActions(BuildContext context) {
    final p = context.palette;
    final canHeal = !_round.healUsed && _round.wolfVictim != null;
    return Column(
      children: [
        AppButton(
          label: canHeal ? 'Heiltrank einsetzen' : 'Kein Heiltrank mehr',
          size: AppButtonSize.large,
          color: p.accentSafe,
          onColor: p.onAccentSafe,
          onPressed: canHeal ? () => _afterWitch(heal: true, poison: _selection) : null,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: _selection == null ? 'Nichts tun — weiterschlafen' : 'Nur vergiften',
          filled: false,
          onPressed: () => _afterWitch(heal: false, poison: _selection),
        ),
      ],
    );
  }

  Widget _morningView(BuildContext context) {
    final p = context.palette;
    // The deaths are only applied when the morning is confirmed, so preview
    // them from the pending choices.
    final pending = <int>{
      if (_round.wolfVictim != null && !_round.healed) _round.wolfVictim!,
      if (_round.poisoned != null) _round.poisoned!,
    }.toList();

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('DER MORGEN DANACH', style: AppText.labelMono(p.warning, size: 12)),
            const SizedBox(height: 18),
            if (pending.isEmpty)
              Text('Alle leben noch', textAlign: TextAlign.center, style: AppText.display(p.textPrimary).copyWith(fontSize: 34))
            else ...[
              for (final i in pending) ...[
                AvatarCircleRound(initial: _players[i].initial, colorIndex: i, size: 76, fontSize: 32),
                const SizedBox(height: 12),
                Text('${_players[i].name} ist tot',
                    textAlign: TextAlign.center, style: AppText.display(p.textPrimary).copyWith(fontSize: 30)),
                const SizedBox(height: 6),
                Text('war ${_round.roles[i].label}', style: AppText.bodySmall(p.textSecondary)),
                const SizedBox(height: 18),
              ],
            ],
            const SizedBox(height: 8),
            Text('Redet. Verdächtigt. Dann wird gehängt.',
                textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _dayResultView(BuildContext context) {
    final p = context.palette;
    final i = _lynched!;
    final role = _round.roles[i];
    final wolf = role == WolfRole.werwolf;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarCircleRound(initial: _players[i].initial, colorIndex: i, size: 96, fontSize: 40),
          const SizedBox(height: AppSpacing.xl),
          Text('${_players[i].name} hängt', textAlign: TextAlign.center, style: AppText.headline(p.textPrimary)),
          const SizedBox(height: 12),
          Text('war ${role.label}',
              textAlign: TextAlign.center,
              style: AppText.display(wolf ? p.danger : p.accentSafe).copyWith(fontSize: 30)),
          const SizedBox(height: 18),
          Text(wolf ? 'Das Dorf hatte recht.' : 'Ein Unschuldiger weniger.',
              textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          _AliveStrip(round: _round, players: _players),
        ],
      ),
    );
  }

  Widget _gameOverView(BuildContext context) {
    final p = context.palette;
    final villageWon = _round.outcome == WerewolfOutcome.village;
    final accent = villageWon ? p.accentSafe : p.danger;

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Text(villageWon ? 'DAS DORF GEWINNT' : 'DIE WÖLFE GEWINNEN',
            style: AppText.labelMono(accent, size: 12)),
        const SizedBox(height: 12),
        Text(
          villageWon ? 'Kein Wolf mehr übrig.' : 'Die Wölfe sind in der Überzahl.',
          style: AppText.headline(p.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('ALLE ROLLEN', style: AppText.labelMono(p.textMuted, size: 11)),
        const SizedBox(height: 12),
        for (var i = 0; i < _players.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RoleRevealRow(
              player: _players[i],
              colorIndex: i,
              role: _round.roles[i],
              alive: _round.alive[i],
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
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

class _RoleRevealRow extends StatelessWidget {
  const _RoleRevealRow({
    required this.player,
    required this.colorIndex,
    required this.role,
    required this.alive,
  });

  final Player player;
  final int colorIndex;
  final WolfRole role;
  final bool alive;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final wolf = role == WolfRole.werwolf;
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: wolf ? p.danger.withValues(alpha: .5) : p.outlineVariant),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: alive ? 1 : 0.4,
            child: AvatarCircle(initial: player.initial, colorIndex: colorIndex, size: 40, fontSize: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.nameLabel(alive ? p.textPrimary : p.textDim).copyWith(
                decoration: alive ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
          Text(germanUpper(role.label),
              style: AppText.labelMono(wolf ? p.danger : p.textMuted, size: 10)),
        ],
      ),
    );
  }
}

class _AliveStrip extends StatelessWidget {
  const _AliveStrip({required this.round, required this.players});

  final WerewolfRound round;
  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < players.length; i++)
          Opacity(
            opacity: round.alive[i] ? 1 : 0.35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: p.outlineVariant),
              ),
              child: Text(
                players[i].name,
                style: AppText.caption(round.alive[i] ? p.textSecondary : p.textDim).copyWith(
                  decoration: round.alive[i] ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
