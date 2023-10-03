import 'package:flutter/material.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/player.dart';
import 'innings_play_screen/match_interface.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

import '../player/player_tile.dart';

class InningsInitScreen extends StatefulWidget {
  final CricketMatch match;
  const InningsInitScreen({super.key, required this.match});

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
            const Spacer(),
            const Text(Strings.initInningsStriker),
            _wBatterSelection(_batter1, ((p) {
              _batter1 = p;
            })),
            const Spacer(),
            const Text(Strings.initInningsNonStriker),
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
        widget.match.nextTeamToBat.squad);
  }

  Widget _wBowlerSelection(Player? bowler) {
    return _wPlayerSelection(
        bowler,
        (p) => _bowler = p,
        Strings.initInningsChooseBowler,
        Strings.initInningsChooseBowlerHint,
        Strings.initInningsChooseBowler,
        widget.match.nextTeamToBowl.squad);
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
              widget.match.progressMatch();
              // final batter =
              //     BatterInnings(_batter!, innings: widget.match.currentInnings);
              // final nsbatter = _batter2 == null
              //     ? null
              //     : BatterInnings(_batter2!,
              //         innings: widget.match.currentInnings);
              widget.match.currentInnings.initialize(
                  batter1: _batter1!, batter2: _batter2, bowler: _bowler!);

              Utils.goToReplacementPage(
                  MatchInterface(match: widget.match), context);
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

  bool get _canInitInnings => _batter1 != null && _bowler != null;
}
