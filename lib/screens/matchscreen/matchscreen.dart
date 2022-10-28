import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/matchscreen/inningsinitscreen.dart';
import 'package:scorecard/screens/matchscreen/playerscoretile.dart';
import 'package:scorecard/screens/matchscreen/scorecard.dart';
import 'package:scorecard/screens/playerlist.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';
import 'package:scorecard/styles/colorstyles.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class MatchScreen extends StatefulWidget {
  final CricketMatch match;
  final InningInitData initData;

  const MatchScreen({Key? key, required this.match, required this.initData})
      : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  // final _dismissals = Dismissal.values.map((dimissal) => false).toList();

  /// Whether a batter should be chosen, typically after a wicket falls.
  bool _shouldChooseBatter = false;

  /// Whether a bowler should be chosen, typically when a new over is bowled.
  bool _shouldChooseBowler = false;

  bool _shouldEndInnings = false;

  /// A player that is batting
  late final List<Player> _batters;

  /// The player on strike. Will always be in [_batters].
  late Player _striker;

  Player get _nonStriker =>
      _striker == _batters.first ? _batters.last : _batters.first;

  /// The player that is bowling the current over
  late Player _bowler;

  _RunSelection _runSelection = _RunSelection();
  _SingleToggleSelection<BowlingExtra> _bowlingExtraSelection =
      _SingleToggleSelection(
          dataList: BowlingExtra.values, stringifier: Strings.getBowlingExtra);
  _SingleToggleSelection<BattingExtra> _battingExtraSelection =
      _SingleToggleSelection(
    dataList: BattingExtra.values,
    stringifier: Strings.getBattingExtra,
  );
  Wicket? _wicketSelection;
  // TODO temporary
  RunoutWicket? _nonStrikeRunout;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bowler = widget.initData.bowler;
    _batters = widget.initData.batters;
    _striker = _batters.first;
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.match.homeTeam.shortName +
        " v " +
        widget.match.awayTeam.shortName;

    return TitledPage(
      title: title,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MatchTile(match: widget.match),
          _wNowPlaying(),
          _wRecentBalls(),
          // Elements.getConfirmButton()
          _wExtraChooser(),
          _wWicketChooser(),
          _wRunChooser(),
          _wConfirmButton(),
        ],
      ),
    );
  }

  // Widget _PlayingScores() {
  //   return
  // }

  Widget _wNowPlaying() {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(children: [
            ..._batters.map((batter) => InkWell(
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
                ))
          ]),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlayerScoreTile(
                  player: _bowler,
                  score:
                      widget.match.currentInnings.currentBowlerInnings.score),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: OutlinedButton.icon(
                  onPressed: widget.match.currentInnings.ballsBowled > 0
                      ? _undoBall
                      : null,
                  style: OutlinedButton.styleFrom(primary: ColorStyles.remove),
                  icon: Icon(Icons.undo),
                  label: Text("Undo"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wConfirmButton() {
    String text = "Next";
    bool canClick = _validateBallParams();
    Function() onPressed = _processBall;

    if (_shouldEndInnings) {
      text = "End Innings";
      onPressed = _doEndInnings;
    } else if (_shouldChooseBatter) {
      _shouldChooseBatter = false;
      text = "Choose Batter";
      onPressed = _chooseBatter;
    } else if (_shouldChooseBowler) {
      _shouldChooseBowler = false;
      text = "Choose Bowler";
      onPressed = _chooseBowler;
    }

    return Elements.getConfirmButton(
        text: text, onPressed: canClick ? onPressed : null);
  }

  Widget _wExtraChooser() {
    return Row(children: [
      ToggleButtons(
          onPressed: (index) => setState(() {
                if (index == _battingExtraSelection.index) {
                  _battingExtraSelection.clear();
                } else {
                  _battingExtraSelection.index = index;
                }
              }),
          children: _battingExtraSelection.widgets,
          isSelected: _battingExtraSelection.booleans,
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          )),
      Spacer(),
      ToggleButtons(
          onPressed: (index) => setState(() {
                if (index == _bowlingExtraSelection.index) {
                  _bowlingExtraSelection.clear();
                } else {
                  _bowlingExtraSelection.index = index;
                }
              }),
          children: _bowlingExtraSelection.widgets,
          isSelected: _bowlingExtraSelection.booleans,
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          )),
    ]);
  }

  Widget _wRunChooser() {
    return Column(
      children: [
        // Text("Runs"),
        // SizedBox(height: 12),
        ToggleButtons(
          onPressed: (int index) => setState(() {
            // The button that is tapped is set to true, and the others to false.
            _runSelection.runIndex = index;
          }),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          selectedBorderColor: Colors.green[700],
          selectedColor: Colors.white,
          fillColor: Colors.green[200],
          // color: Colors.red[400],
          // constraints: const BoxConstraints(
          //   minHeight: 40.0,
          //   minWidth: 80.0,
          // ),
          isSelected: _runSelection.booleans,
          children: _runSelection.widgets,
        ),
      ],
    );
  }

  Widget _wWicketChooser() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            // leading: Elements.getOnlineIndicator(_nonStrikeRunout != null),
            title: const Text("Non Strike Runout"),
            isThreeLine: false,
            // subtitle: const Text(
            //   Strings.addWicketHint,
            // ),
            trailing: Elements.forwardIcon,
            onTap: () {
              _processBall(Ball.RunoutBeforeDelivery(
                  bowler: _bowler, batter: _nonStriker));
            },
          ),
        ),
        Expanded(
          child: ListTile(
            leading: Elements.getOnlineIndicator(_wicketSelection != null),
            title: const Text(Strings.addWicket),
            isThreeLine: false,
            // subtitle: const Text(
            //   Strings.addWicketHint,
            // ),
            trailing: Elements.forwardIcon,
            onTap: () {
              setState(() {
                if (_wicketSelection != null) {
                  _wicketSelection = null;
                } else {
                  _wicketSelection = BowledWicket(_striker, _bowler);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _wRecentBalls() {
    List<Ball> ballList = widget.match.currentInnings.allBalls;
    List<Widget> displayWidgets = [];

    for (int i = 0; i < ballList.length; i++) {
      if (i > 0 && ballList[i - 1].bowler != ballList[i].bowler) {
        // Add pipe
        displayWidgets.add(const SizedBox(
          height: 32,
          child: const VerticalDivider(color: Colors.amber),
        ));
      }

      Ball currentBall = ballList[i];
      Widget currentWidget;

      if (currentBall.runsScored == 4) {
        currentWidget = CircleAvatar(
          backgroundColor: ColorStyles.ballFour,
          child: Text(currentBall.runsScored.toString()),
        );
      } else if (currentBall.runsScored == 6) {
        currentWidget = CircleAvatar(
          backgroundColor: ColorStyles.ballSix,
          foregroundColor: Colors.white,
          child: Text(currentBall.runsScored.toString()),
        );
      } else if (currentBall.isWicket) {
        currentWidget = CircleAvatar(
          backgroundColor: ColorStyles.wicket,
          child: Text(currentBall.runsScored.toString()),
        );
      } else {
        currentWidget =
            CircleAvatar(child: Text(currentBall.runsScored.toString()));
      }

      Widget indicator = Elements.blankIndicator;

      if (currentBall.isBowlingExtra) {
        switch (currentBall.bowlingExtra!) {
          case BowlingExtra.noBall:
            indicator = Elements.noBallIndicator;
            break;
          case BowlingExtra.wide:
            indicator = Elements.wideBallIndicator;
            break;
        }
      }

      displayWidgets.add(Column(
        children: [
          SizedBox(
            child: currentWidget,
            height: 28,
          ),
          indicator
        ],
      ));
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.yellow),
        // color: Colors.red,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...displayWidgets.map((widget) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: widget,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _processBall([Ball? ball]) {
    setState(() {
      Innings currentInnings = widget.match.currentInnings;

      ball ??= Ball(
        bowler: _bowler,
        batter: _striker,
        runsScored: _runSelection.runs,
        wicket: _wicketSelection,
        bowlingExtra: _bowlingExtraSelection.selection,
        battingExtra: _battingExtraSelection.selection,
      );

      currentInnings.addBall(ball!);

      if (currentInnings.isCompleted) {
        _shouldEndInnings = true;
      }

      _populateFlags();

      // To change strike
      if (_runSelection.runs % 2 == 1) {
        _swapStrike();
      }

      _clearSelections();
    });
  }

  void _populateFlags() {
    Innings currentInnings = widget.match.currentInnings;

    _shouldChooseBatter = false;
    _shouldChooseBowler = false;

    if (currentInnings.ballsBowled == 0) {
      _shouldChooseBatter = false;
      _shouldChooseBowler = false;
    } else {
      if (currentInnings.currentOver.isCompleted) {
        _shouldChooseBowler = true;
        _swapStrike();
      }
      if (currentInnings.currentOver.balls.last.isWicket) {
        _shouldChooseBatter = true;
        _batters.remove(currentInnings.currentOver.balls.last.wicket!.batter);
      }
    }
  }

  void _chooseBatter() {
    _choosePlayer(
        widget.match.currentInnings.battingTeam.squad,
        (batter) => setState(() {
              widget.match.currentInnings.addBatter(batter);
              _batters.add(batter);
              if (_batters.length == 1) {
                _striker = _batters.single;
              } else if (!_batters.any((batter) => _striker == batter)) {
                _striker = batter;
              }
            }));
  }

  void _chooseBowler() {
    _choosePlayer(
        widget.match.currentInnings.bowlingTeam.squad,
        (bowler) => setState(() {
              widget.match.currentInnings.addOver(Over(bowler));
              _bowler = bowler;
            }));
  }

  void _choosePlayer(List<Player> squad, Function(Player) onSelectPlayer) {
    Utils.goToPage(
        TitledPage(
          title: "Pick a Player",
          child: PlayerList(
              playerList: squad,
              showAddButton: false,
              onSelectPlayer: (player) {
                setState(() {
                  onSelectPlayer(player);
                });
                Utils.goBack(context);
              }),
        ),
        context);
  }

  void _swapStrike() {
    if (_striker == _batters.first) {
      _striker = _batters.last;
    } else {
      _striker = _batters.first;
    }
  }

  void _doEndInnings() {
    if (widget.match.matchState == MatchState.firstInnings) {
      widget.match.startSecondInnings();
      Utils.goToPage(InningsInitScreen(match: widget.match), context);
    } else if (widget.match.matchState == MatchState.secondInnings) {
      widget.match.generateResult();
      Utils.goToPage(Scorecard(match: widget.match), context);
    }
  }

  void _undoBall() {
    setState(() {
      widget.match.currentInnings.undoBall();
      _shouldEndInnings = false;
      _populateFlags();
    });
  }

  void _clearSelections() {
    _battingExtraSelection.clear();
    _bowlingExtraSelection.clear();
    _runSelection.clear();
  }

  bool _validateBallParams() {
    return true;
  }
}

class _RunSelection {
  static const List<int> runList = [0, 1, 2, 3, 4, 5, 6];
  int _selectedRuns = 0;

  List<bool> get booleans =>
      runList.map((run) => run == _selectedRuns).toList();

  List<Widget> get widgets =>
      runList.map((run) => Text(Strings.getRunText(run))).toList();

  int get runs => _selectedRuns;
  set runIndex(int index) => _selectedRuns = runList[index];

  void clear() {
    _selectedRuns = 0;
  }
}

class _SingleToggleSelection<T> {
  final List<T> dataList;
  final String Function(T) stringifier;

  _SingleToggleSelection({required this.dataList, required this.stringifier});

  int index = -1;

  T? get selection => index == -1 ? null : dataList[index];

  List<Widget> get widgets =>
      dataList.map((data) => Text(stringifier(data))).toList();

  List<bool> get booleans => dataList.map((data) => data == selection).toList();

  void clear() {
    index = -1;
  }
}

class InningInitData {
  /// A player that is batting
  final List<Player> batters;

  /// The player that is bowling the current over
  final Player bowler;

  InningInitData({required this.batters, required this.bowler});
}
