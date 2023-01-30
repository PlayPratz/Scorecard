import 'package:flutter/material.dart';
import 'package:scorecard/screens/match/innings_play_screen/match_screen.dart';
import '../../models/cricket_match.dart';
import '../../models/innings.dart';
import '../../models/result.dart';
import '../../styles/color_styles.dart';
import '../../util/strings.dart';
import '../../util/elements.dart';

class MatchTile extends StatelessWidget {
  final CricketMatch match;
  final void Function(CricketMatch match)? onSelectMatch;
  final void Function(CricketMatch match)? onLongPress;

  const MatchTile({
    required this.match,
    this.onSelectMatch,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: ColorStyles.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: InkWell(
        onTap: onSelectMatch != null ? () => onSelectMatch!(match) : null,
        onLongPress: onLongPress != null ? () => onLongPress!(match) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            children: [
              _wMatchDetails(),
              Row(
                children: [
                  Expanded(
                    child: _InningsTile(match.homeInnings),
                  ),
                  Expanded(
                    child: _InningsTile(match.awayInnings),
                  ),
                ],
              ),
              const SizedBox(height: 8)
            ],
          ),
        ),
      ),
    );
  }

  Widget _wMatchDetails() {
    String text = match.isSuperOver
        ? Strings.matchScreenSuperOver
        : match.maxOvers.toString() + Strings.scoreOvers;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(text),
    );
  }
}

class _InningsTile extends StatelessWidget {
  final Innings innings;

  const _InningsTile(this.innings);

  @override
  Widget build(BuildContext context) {
    String score = innings.runs.toString() +
        Strings.seperatorSlash +
        innings.wickets.toString();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      // tileColor: innings.battingTeam.color,
      minVerticalPadding: 8,
      minLeadingWidth: 0,
      // horizontalTitleGap: 0,
      dense: false,
      // leading: Elements.getOnlineIndicator(true),
      title: ScoreTile(
        battingInnings: innings,
        team: innings.battingTeam,
        useShortName: true,
      ),
      // subtitle: Padding(
      //   padding: const EdgeInsets.symmetric(vertical: 8),
      //   child: _wScoreDisplay(context),
      // ),
      trailing: Text(
        innings.strOvers,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
