import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/matchscreen/ballselector.dart';
import 'package:scorecard/screens/matchscreen/playerscoretile.dart';
import 'package:scorecard/screens/matchscreen/playerselector.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';
import 'package:scorecard/screens/matchscreen/tossselector.dart';

class MatchScreen extends StatefulWidget {
  final CricketMatch match;

  const MatchScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  // final _dismissals = Dismissal.values.map((dimissal) => false).toList();

  /// Whether a batter should be chosen, typically after a wicket falls.
  bool _shouldChooseBatter = false;

  /// Whether a bowler should be chosen, typically when a new over is bowled.
  bool _shouldChooseBowler = false;

  /// A player that is batting
  final List<Player> _batters = [];

  /// The player on strike. Will always be in [_batters].
  late Player _striker;

  /// The player that is bowling the current over
  late Player _bowler;

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
        _shouldChooseBatter = true;
        _shouldChooseBowler = true;
        widget.match.startFirstInnings();
        return _wBatterSelector();

      default:
        if (_shouldChooseBatter) {
          _shouldChooseBatter = false;
          return _wBatterSelector();
        }

        if (_shouldChooseBowler) {
          _shouldChooseBowler = false;
          return _wBowlerSelector();
        }

        return Column(
          children: [
            Row(children: [
              ..._batters.map((batter) => Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        _striker = batter;
                      }),
                      child: PlayerScoreTile(
                        player: batter,
                        score: widget.match.currentInnings
                            .batterInningsOfPlayer(batter)
                            .score,
                        isOnStrike: _striker == batter,
                      ),
                    ),
                  ))
            ]),
            Row(children: [
              Spacer(),
              Expanded(
                child: PlayerScoreTile(
                    player: _bowler,
                    score:
                        widget.match.currentInnings.currentBowlerInnings.score),
              )
            ]),
            Expanded(
              child: BallSelector(onSelectBall: _processBall),
            ),
          ],
        );
    }
  }

  // Widget _PlayingScores() {
  //   return
  // }

  void _processBall(int runs, Wicket? wicket) {
    setState(() {
      Innings currentInnings = widget.match.currentInnings;

      currentInnings.addBall(Ball(
          bowler: _bowler, batter: _striker, runsScored: runs, wicket: wicket));

      if (currentInnings.isCompleted) {
        throw UnimplementedError();
      }

      if (currentInnings.currentOver.isCompleted) {
        _shouldChooseBowler = true;
        _swapStrike();
      }

      if (wicket != null) {
        _shouldChooseBatter = true;
        _batters.remove(wicket.batter);
      }

      // To change strike
      if (runs % 2 == 1) {
        _swapStrike();
      }
    });
  }

  Widget _wBatterSelector() {
    return PlayerSelector(
      selectionHeading: "Batter",
      team: widget.match.currentInnings.battingTeam,
      onPlayerSelect: (batter) {
        setState(() {
          widget.match.currentInnings.addBatter(batter);
          _batters.add(batter);
          if (_batters.length == 1) {
            _striker = _batters.single;
          } else if (!_batters.any((batter) => _striker == batter)) {
            _striker = batter;
          }
        });
      },
    );
  }

  Widget _wBowlerSelector() {
    return PlayerSelector(
      selectionHeading: "Bowler",
      team: widget.match.currentInnings.bowlingTeam,
      onPlayerSelect: (bowler) {
        setState(() {
          widget.match.currentInnings.addOver(Over(bowler));
          _bowler = bowler;
        });
      },
    );
  }

  void _swapStrike() {
    if (_striker == _batters.first) {
      _striker = _batters.last;
    } else {
      _striker = _batters.first;
    }
  }

  // void assignNewBatter(Player newBatter) {
  //   if (_batter1 == null) {
  //     _batter1 = newBatter;
  //   } else {
  //     _batter2 = newBatter;
  //   }
  // }
}
