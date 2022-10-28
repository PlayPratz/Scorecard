import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricketmatch.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/screens/matchscreen/matchscreen.dart';
import 'package:scorecard/screens/playerlist.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

import '../widgets/playertile.dart';

class InningsInitScreen extends StatefulWidget {
  final CricketMatch match;
  const InningsInitScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<InningsInitScreen> createState() => _InningsInitScreenState();
}

class _InningsInitScreenState extends State<InningsInitScreen> {
  Player? _batterOne;
  Player? _batterTwo;
  Player? _bowler;

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: "Let's Start The Innings",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Batter One"),
            SizedBox(height: 24),
            _wBatterSelection(_batterOne, ((p) {
              _batterOne = p;
              if (_batterTwo == p) {
                _batterTwo = null;
              }
            })),
            Spacer(),
            Text("Batter Two"),
            SizedBox(height: 24),
            _wBatterSelection(_batterTwo, ((p) {
              _batterTwo = p;
              if (_batterOne == p) {
                _batterOne = null;
              }
            })),
            Spacer(),
            Text("Bowler"),
            SizedBox(height: 24),
            _wBowlerSelection(_bowler),
            Spacer(),
            _wConfirmButton(),
          ],
        ));
  }

  Widget _wBatterSelection(Player? batter, Function(Player) onSelectBatter) {
    return _wPlayerSelection(
        batter,
        onSelectBatter,
        "Choose a Batter",
        "Someone who can score many runs, hopefully",
        "Pick a Batter",
        widget.match.currentInnings.battingTeam.squad);
  }

  Widget _wBowlerSelection(Player? bowler) {
    return _wPlayerSelection(
        bowler,
        (p) => _bowler = p,
        "Choose a Bowler",
        "Somene who can take many wickets, hopefully",
        "Pick a Bowler",
        widget.match.currentInnings.bowlingTeam.squad);
  }

  Widget _wPlayerSelection(Player? player, Function(Player) onSelectPlayer,
      String primary, String secondary, String title, List<Player> squad) {
    if (player == null) {
      return GenericItem(
          primaryHint: primary,
          secondaryHint: secondary,
          onSelect: () => onTapPlayer(onSelectPlayer, title, squad));
    } else {
      return PlayerTile(
        player,
        onSelect: (ignoreplayer) => onTapPlayer(onSelectPlayer, title, squad),
      );
    }
  }

  Widget _wConfirmButton() {
    return Elements.getConfirmButton(
      text: "Start Match",
      onPressed: _canInitInnings
          ? () {
              if (widget.match.matchState == MatchState.tossCompleted) {
                widget.match.startFirstInnings();
              } else {
                widget.match.startSecondInnings();
              }

              widget.match.currentInnings.addBatter(_batterOne!);
              widget.match.currentInnings.addBatter(_batterTwo!);
              widget.match.currentInnings.addOver(Over(_bowler!));
              Utils.goToPage(
                  MatchScreen(
                    match: widget.match,
                    initData: InningInitData(
                        batters: [_batterOne!, _batterTwo!], bowler: _bowler!),
                  ),
                  context);
            }
          : null,
    );
  }

  void onTapPlayer(
      Function(Player) onSelect, String title, List<Player> squad) {
    Utils.goToPage(
        TitledPage(
            title: title,
            child: PlayerList(
              playerList: squad,
              showAddButton: false,
              onSelectPlayer: (player) {
                setState(() {
                  onSelect(player);
                  Utils.goBack(context);
                });
              },
            )),
        context);
  }

  bool get _canInitInnings =>
      _batterOne != null && _batterTwo != null && _bowler != null;
}
