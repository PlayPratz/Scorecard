import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/util/strings.dart';
import '../../models/cricket_match.dart';
import '../../models/player.dart';
import 'innings_play_screen/match_screen.dart';
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
  Player? _batter;
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
            const Spacer(),
            const Text(Strings.initInningsBatter),
            _wBatterSelection(_batter, ((p) {
              _batter = p;
            })),
            const Spacer(),
            const Text("Non Striker"), //TODO
            _wBatterSelection(_batter2, ((p) {
              _batter2 = p;
            })),
            const Spacer(),
            const Text(Strings.initInningsBowler),
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
              final batter = BatterInnings(
                  batter: _batter!, innings: widget.match.currentInnings);
              final nsbatter = _batter2 == null
                  ? null
                  : BatterInnings(
                      batter: _batter2!, innings: widget.match.currentInnings);
              final bowler = BowlerInnings(
                  bowler: _bowler!, innings: widget.match.currentInnings);
              Utils.goToReplacementPage(
                  ChangeNotifierProvider(
                    create: (context) => InningsManager(
                      widget.match.currentInnings,
                      batter: batter,
                      nsbatter: nsbatter,
                      bowler: bowler,
                    ),
                    child: MatchInterface(match: widget.match),
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
              onSelectPlayer: (player) {
                setState(() {
                  onSelect(player);
                  Utils.goBack(context);
                });
              },
            )),
        context);
  }

  bool get _canInitInnings => _batter != null && _bowler != null;
}
