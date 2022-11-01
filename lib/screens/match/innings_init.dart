import 'package:flutter/material.dart';
import 'package:scorecard/util/strings.dart';
import '../../models/ball.dart';
import '../../models/cricket_match.dart';
import '../../models/player.dart';
import 'match_screen.dart';
import '../player/player_list.dart';
import '../templates/titled_page.dart';
import '../widgets/generic_item_tile.dart';
import '../../util/elements.dart';
import '../../util/utils.dart';

import '../player/player_tile.dart';

class InningsInitScreen extends StatefulWidget {
  final CricketMatch match;
  const InningsInitScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<InningsInitScreen> createState() => _InningsInitScreenState();
}

class _InningsInitScreenState extends State<InningsInitScreen> {
  Player? _batter1;
  Player? _batter2;
  Player? _bowler;

  @override
  Widget build(BuildContext context) {
    return TitledPage(
        title: Strings.initInningsTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(Strings.initInningsBatter1),
            const SizedBox(height: 24),
            _wBatterSelection(_batter1, ((p) {
              _batter1 = p;
            })),
            const Spacer(),
            const Text(Strings.initInningsBatter2),
            const SizedBox(height: 24),
            _wBatterSelection(_batter2, ((p) {
              _batter2 = p;
            })),
            const Spacer(),
            const Text(Strings.initInningsBowler),
            const SizedBox(height: 24),
            _wBowlerSelection(_bowler),
            const Spacer(),
            _wConfirmButton(),
          ],
        ));
  }

  Widget _wBatterSelection(Player? batter, Function(Player) onSelectBatter) {
    return _wPlayerSelection(
        batter,
        onSelectBatter,
        Strings.initInningsChooseBatter,
        Strings.initInningsChooseBatterHint,
        Strings.initInningsChooseBatter,
        widget.match.currentInnings.battingTeam.squad);
  }

  Widget _wBowlerSelection(Player? bowler) {
    return _wPlayerSelection(
        bowler,
        (p) => _bowler = p,
        Strings.initInningsChooseBowler,
        Strings.initInningsChooseBowlerHint,
        Strings.initInningsChooseBowler,
        widget.match.currentInnings.bowlingTeam.squad);
  }

  Widget _wPlayerSelection(Player? player, Function(Player) onSelectPlayer,
      String primary, String secondary, String title, List<Player> squad) {
    if (player == null) {
      return GenericItemTile(
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
      text: Strings.initInningsStartInnings,
      onPressed: _canInitInnings
          ? () {
              if (widget.match.matchState == MatchState.tossCompleted) {
                widget.match.startFirstInnings();
              } else {
                widget.match.startSecondInnings();
              }

              widget.match.currentInnings.addBatter(_batter1!);
              widget.match.currentInnings.addBatter(_batter2!);
              widget.match.currentInnings.addOver(Over(_bowler!));
              Utils.goToReplacementPage(
                  MatchScreen(match: widget.match), context);
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
      _batter1 != null && _batter2 != null && _bowler != null;
}
