import 'package:flutter/material.dart';
import 'package:scorecard/models/result.dart';
import 'package:scorecard/screens/match/wicket_selector.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/util/storage_util.dart';

import '../../models/ball.dart';
import '../../models/cricket_match.dart';
import '../../models/innings.dart';
import '../../models/player.dart';
import '../../models/wicket.dart';
import '../../styles/color_styles.dart';
import '../../util/strings.dart';
import '../../util/elements.dart';
import '../../util/helpers.dart';
import '../../util/utils.dart';
import '../player/player_list.dart';
import '../templates/titled_page.dart';
import 'match_tile.dart';
import 'innings_init.dart';
import 'player_score_tile.dart';
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

  /// The player that is bowling the current over
  Player get _bowler => widget.match.currentInnings.currentOver.bowler;

  final _RunSelection _runSelection = _RunSelection();
  final SingleToggleSelection<BowlingExtra> _bowlingExtraSelection =
      SingleToggleSelection.withWidgetifier(
          dataList: BowlingExtra.values,
          widgetifier: (bowlingExtra, selection) {
            Color color = ColorStyles.ballWide;
            if (bowlingExtra == selection) {
              color = Colors.black;
            } else if (bowlingExtra == BowlingExtra.noBall) {
              color = ColorStyles.ballNoBall;
            }
            return Text(
              Strings.getBowlingExtra(bowlingExtra),
              style: TextStyle(color: color),
            );
          });
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
  void dispose() {
    super.dispose();
    StorageUtils.saveMatch(widget.match);
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.match.homeTeam.shortName +
        Strings.seperatorVersus +
        widget.match.awayTeam.shortName;
    return TitledPage(
      title: title,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MatchTile(
            match: widget.match,
            onSelectMatch: (match) =>
                Utils.goToPage(Scorecard(match: match), context),
          ),
          _wRecentBalls(),
          _wNowPlaying(),
          // Elements.getConfirmButton()
          _wWicketChooser(),
          _wExtraChooser(),
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
          ...onPitchBatters.map((batterInnings) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: InkWell(
                  onTap: () => setState(() {
                    _striker = batterInnings;
                  }),
                  child: PlayerScoreTile(
                    player: batterInnings.batter,
                    score: batterInnings.score,
                    teamColor: widget.match.currentInnings.battingTeam.color,
                    isOnline: _striker == batterInnings,
                  ),
                ),
              ))
        ]),
      ),
      const SizedBox(width: 4),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: PlayerScoreTile(
                player: _bowler,
                teamColor: widget.match.currentInnings.bowlingTeam.color,
                score: widget.match.currentInnings.currentBowlerInnings.score,
              ),
            ),
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
          label: const Text(Strings.matchScreenEndInnings),
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
        label: const Text(Strings.matchScreenUndo),
      ),
    );
  }

  Widget _wConfirmButton() {
    String text = Strings.buttonNext;
    bool canClick = _validateBallParams();
    Function() onPressed = _processBall;

    if (_shouldEndInnings) {
      text = Strings.matchScreenEndInnings;
      onPressed = _doEndInnings;
    } else if (_shouldChooseBatter) {
      text = Strings.matchScreenChooseBatter;
      onPressed = _chooseBatter;
    } else if (_shouldChooseBowler) {
      text = Strings.matchScreenChooseBowler;
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
          fillColor: _bowlingExtraSelection.selection != null
              ? ColorStyles.getBowlingExtraColour(
                  _bowlingExtraSelection.selection!)
              : null,
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          )),
    ]);
  }

  Widget _wRunChooser() {
    return Column(
      children: [
        // SizedBox(height: 12),
        ToggleButtons(
          onPressed: (int index) => setState(() {
            // The button that is tapped is set to true, and the others to false.
            _runSelection.runIndex = index;
          }),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          fillColor: _runSelection.runs == 4
              ? ColorStyles.ballFour
              : _runSelection.runs == 6
                  ? ColorStyles.ballSix
                  : ColorStyles.highlight,
          isSelected: _runSelection.booleans,
          children: _runSelection.widgets,
        ),
      ],
    );
  }

  Widget _wWicketChooser() {
    String primary = Strings.matchScreenAddWicket;
    String hint = Strings.matchScreenAddWicketHint;
    if (_wicketSelection != null) {
      primary = _wicketSelection!.batter.name;
      hint = Strings.getWicketDescription(_wicketSelection);
    }
    return GenericItemTile(
      leading: const Icon(
        Icons.gpp_bad,
        color: Colors.redAccent,
        size: 32,
      ),
      primaryHint: primary,
      secondaryHint: hint,
      trailing: Elements.forwardIcon,
      onSelect: _onSelectWicket,
      onLongPress: () => setState(() {
        _wicketSelection = null;
      }),
    );
  }

  void _onSelectWicket() async {
    Wicket? selectedWicket = await Utils.goToPage(
        WicketSelector(
          bowler: _bowler,
          striker: _striker.batter,
          fieldingTeam: widget.match.currentInnings.bowlingTeam,
          battingTeam: widget.match.currentInnings.battingTeam,
        ),
        context);
    setState(() {
      _wicketSelection = selectedWicket;
    });
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
      CircleAvatar currentBallWidget;

      if (currentBall.isWicket) {
        currentBallWidget = CircleAvatar(
          backgroundColor: ColorStyles.wicket,
          foregroundColor: Colors.white,
          child: Text(currentBall.runsScored.toString()),
        );
      } else if (currentBall.runsScored == 4) {
        currentBallWidget = CircleAvatar(
          backgroundColor: ColorStyles.ballFour,
          foregroundColor: Colors.white,
          child: Text(currentBall.runsScored.toString()),
        );
      } else if (currentBall.runsScored == 6) {
        currentBallWidget = CircleAvatar(
          backgroundColor: ColorStyles.ballSix,
          foregroundColor: Colors.white,
          child: Text(currentBall.runsScored.toString()),
        );
      } else {
        currentBallWidget = CircleAvatar(
            backgroundColor: ColorStyles.card,
            foregroundColor: Colors.white,
            child: Text(
              currentBall.runsScored.toString(),
            ));
      }

      Color? indicatorColor = currentBallWidget.backgroundColor;

      if (currentBall.isBowlingExtra) {
        switch (currentBall.bowlingExtra!) {
          case BowlingExtra.noBall:
            indicatorColor = ColorStyles.ballNoBall;
            break;
          case BowlingExtra.wide:
            indicatorColor = ColorStyles.ballWide;
            break;
        }
      }

      displayWidgets.add(CircleAvatar(
        child: currentBallWidget,
        radius: 22,
        backgroundColor: indicatorColor,
      ));
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorStyles.highlight),
          // color: Colors.red,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ...displayWidgets.map((widget) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 2),
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
          title: Strings.choosePlayer,
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
      Utils.goToReplacementPage(
          InningsInitScreen(match: widget.match), context);
    } else {
      widget.match.endSecondInnings();
      if (widget.match.result.getVictoryType() == VictoryType.tie) {
        // Super Over option
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Material(
                color: ColorStyles.background,
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const Text(
                      Strings.matchScreenMatchTied,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    const Text(Strings.matchScreenMatchTiedHint),
                    const SizedBox(height: 32),
                    GenericItemTile(
                      leading: const Icon(Icons.handshake),
                      primaryHint: Strings.matchScreenEndTiedMatch,
                      secondaryHint: Strings.matchScreenEndTiedMatchHint,
                      onSelect: () {
                        Utils.goBack(context);
                        Utils.goToReplacementPage(
                            Scorecard(match: widget.match), context);
                      },
                    ),
                    const SizedBox(height: 32),
                    GenericItemTile(
                      leading: const Icon(Icons.sports_baseball),
                      primaryHint: Strings.matchScreenSuperOver,
                      secondaryHint: Strings.matchScreenSuperOverHint,
                      onSelect: () {
                        widget.match.startSuperOver();
                        Utils.goBack(context);
                        Utils.goToReplacementPage(
                            InningsInitScreen(match: widget.match.superOver!),
                            context);
                      },
                    ),
                  ],
                ),
              );
            });
      } else {
        Utils.goToReplacementPage(Scorecard(match: widget.match), context);
      }
    }
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

  List<Widget> get widgets => runList.map((run) {
        Color color = Colors.white;
        if (_selectedRuns == run) {
          if (_selectedRuns == 4 || _selectedRuns == 6) {
            color = Colors.white;
          } else {
            color = Colors.black;
          }
        } else if (run == 4) {
          color = ColorStyles.ballFour;
        } else if (run == 6) {
          color = ColorStyles.ballSix;
        }
        return Text(
          Strings.getRunText(run),
          style: TextStyle(color: color),
        );
      }).toList();

  int get runs => _selectedRuns;
  set runIndex(int index) => _selectedRuns = runList[index];

  void clear() {
    _selectedRuns = 0;
  }
}
