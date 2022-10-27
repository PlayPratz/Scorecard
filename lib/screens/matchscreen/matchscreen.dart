import 'package:flutter/material.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/matchscreen/ballselector.dart';
import 'package:scorecard/screens/matchscreen/batterselector.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';
import 'package:scorecard/screens/matchscreen/tossselector.dart';
import 'package:scorecard/util/elements.dart';

class MatchScreen extends StatefulWidget {
  final CricketMatch match;

  const MatchScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final _dismissals = Dismissal.values.map((dimissal) => false).toList();

  @override
  Widget build(BuildContext context) {
    String title = widget.match.homeTeam.shortName +
        " v " +
        widget.match.awayTeam.shortName;

    return TitledPage(
      title: title,
      child: Column(
        children: [
          MatchTile(match: widget.match),
          const SizedBox(height: 32),
          Expanded(child: _wContentSection()),
        ],
      ),
    );
  }

  Widget _wContentSection() {
    switch (widget.match.matchState) {
      case MatchState.notStarted:
        // show Toss
        return TossSelector(
          match: widget.match,
          onCompleteToss: (Toss toss) {
            setState(() {
              widget.match.startMatch(toss);
            });
          },
        );

      case MatchState.tossCompleted:
        return BatterSelector();

      default:
        return BallSelector();
    }
  }
}
