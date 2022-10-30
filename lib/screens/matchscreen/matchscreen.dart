import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';

import '../../models/ball.dart';
import '../../models/cricketmatch.dart';
import '../../models/innings.dart';
import '../../models/player.dart';
import '../../models/wicket.dart';
import '../../styles/colorstyles.dart';
import '../../styles/strings.dart';
import '../../util/elements.dart';
import '../../util/helpers.dart';
import '../../util/utils.dart';
import '../playerlist.dart';
import '../titledpage.dart';
import '../widgets/matchtile.dart';
import 'inningsinitscreen.dart';
import 'playerscoretile.dart';
import 'scorecard.dart';

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

  bool _shouldEndInnings = false;

  List<BatterInnings> get onPitchBatters =>
      widget.match.currentInnings.onPitchBatters;

  /// The player on strike. Will always be in [onPitchBatters].
  late BatterInnings _striker;

  BatterInnings get _nonStriker => _striker == onPitchBatters.first
      ? onPitchBatters.last
      : onPitchBatters.first;

  /// The player that is bowling the current over
  Player get _bowler => widget.match.currentInnings.currentOver.bowler;

  final _RunSelection _runSelection = _RunSelection();
  final SingleToggleSelection<BowlingExtra> _bowlingExtraSelection =
      SingleToggleSelection(
          dataList: BowlingExtra.values, stringifier: Strings.getBowlingExtra);
  final SingleToggleSelection<BattingExtra> _battingExtraSelection =
      SingleToggleSelection(
    dataList: BattingExtra.values,
    stringifier: Strings.getBattingExtra,
  );

  Wicket? _wicketSelection;

  @override
  void initState() {
    super.initState();
    _striker = onPitchBatters.first;
  }

  @override
  void didUpdateWidget(covariant MatchScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    // Save match
    Utils.saveMatch(widget.match);
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
          MatchTile(
            match: widget.match,
            onSelectMatch: (match) => _goToScoreCard(),
          ),
          _wNowPlaying(),
          _wRecentBalls(),
          // Elements.getConfirmButton()
          _wExtraChooser(),
          _wWicketChooser(),
          _wRunChooser(),
          Row(
            children: [
              Expanded(child: _wUndoButton()),
              Expanded(flex: 2, child: _wConfirmButton())
            ],
          )
        ],
      ),
    );
  }

  // Widget _PlayingScores() {
  //   return
  // }

  Widget _wNowPlaying() {
    List<Widget> nowPlayingWidgets = [
      Expanded(
        child: Column(children: [
          ...onPitchBatters.map((batterInnings) => InkWell(
                onTap: () => setState(() {
                  _striker = batterInnings;
                }),
                child: PlayerScoreTile(
                  player: batterInnings.batter,
                  score: batterInnings.score,
                  isOnline: _striker == batterInnings,
                ),
              ))
        ]),
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlayerScoreTile(
                player: _bowler,
                score: widget.match.currentInnings.currentBowlerInnings.score),
            const SizedBox(height: 8),
            _wEndInningsButton()
          ],
        ),
      ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.match.currentInnings == widget.match.homeInnings
          ? nowPlayingWidgets
          : [...nowPlayingWidgets.reversed],
    );
  }

  Widget _wEndInningsButton() {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: OutlinedButton.icon(
          onPressed: null,
          onLongPress: _doEndInnings,
          style: OutlinedButton.styleFrom(primary: ColorStyles.remove),
          icon: const Icon(Icons.cancel),
          label: Text("End Innings"),
        ),
      ),
    );
  }

  Widget _wUndoButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: OutlinedButton.icon(
        onPressed:
            widget.match.currentInnings.ballsBowled > 0 ? _undoMove : null,
        style: OutlinedButton.styleFrom(primary: ColorStyles.remove),
        icon: const Icon(Icons.undo),
        label: Text("Undo"),
      ),
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
      text = "Choose Batter";
      onPressed = _chooseBatter;
    } else if (_shouldChooseBowler) {
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
      const Spacer(),
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
    return GenericItem(
      leading: Elements.getOnlineIndicator(_wicketSelection != null),
      primaryHint: Strings.addWicket,
      secondaryHint: Strings.addWicketHint,
      trailing: Elements.forwardIcon,
      onSelect: () {
        setState(() {
          if (_wicketSelection != null) {
            _wicketSelection = null;
          } else {
            _wicketSelection = BowledWicket(_striker.batter, _bowler);
          }
        });
      },
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
          child: VerticalDivider(color: Colors.amber),
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
          foregroundColor: Colors.white,
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

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: widget,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processBall() {
    Ball ball = Ball(
      bowler: _bowler,
      batter: _striker.batter,
      runsScored: _runSelection.runs,
      wicket: _wicketSelection,
      bowlingExtra: _bowlingExtraSelection.selection,
      battingExtra: _battingExtraSelection.selection,
    );

    setState(() {
      Innings currentInnings = widget.match.currentInnings;
      currentInnings.addBall(ball);

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

      if (currentInnings.currentOver.balls.isEmpty) {
        _shouldChooseBowler = true;
      }

      if (currentInnings.currentOver.balls.isNotEmpty &&
          currentInnings.currentOver.balls.last.isWicket) {
        _shouldChooseBatter = true;
      }
    }
  }

  void _chooseBatter() {
    _choosePlayer(
        widget.match.currentInnings.battingTeam.squad,
        (batter) => setState(() {
              _shouldChooseBatter = false;
              widget.match.currentInnings.addBatter(batter);
              _striker = onPitchBatters.last;
            }));
  }

  void _chooseBowler() {
    _choosePlayer(
        widget.match.currentInnings.bowlingTeam.squad,
        (bowler) => setState(() {
              _shouldChooseBowler = false;
              widget.match.currentInnings.addOver(Over(bowler));
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
    if (_striker == onPitchBatters.first) {
      _striker = onPitchBatters.last;
    } else {
      _striker = onPitchBatters.first;
    }
  }

  void _doEndInnings() {
    if (widget.match.matchState == MatchState.firstInnings) {
      widget.match.startSecondInnings();
      Utils.goToPage(InningsInitScreen(match: widget.match), context);
    } else if (widget.match.matchState == MatchState.secondInnings) {
      widget.match.generateResult();
      _goToScoreCard();
    }
  }

  void _goToScoreCard() {
    Utils.goToPage(Scorecard(match: widget.match), context);
  }

  void _undoMove() {
    if (widget.match.currentInnings.currentOver.numOfBallsBowled == 0) {
      setState(() {
        widget.match.currentInnings.undoOver();
        _shouldChooseBowler = true;
      });
    } else {
      setState(() {
        widget.match.currentInnings.undoBall();
        _shouldEndInnings = false;
        _populateFlags();
      });
    }
  }

  void _clearSelections() {
    _battingExtraSelection.clear();
    _bowlingExtraSelection.clear();
    _runSelection.clear();
    _wicketSelection = null;
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
