import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';

class CricketGameScreen extends StatelessWidget {
  final CricketGame game;

  const CricketGameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
    // return ListView(
    //   children: [
    //     //Cricket Match Tile
    //     MatchTile(match: match)
    //     //PlayersInAction
    //     PlayersInActionPane(innings: innings, isHomeTeamBatting: isHomeTeamBatting, onTapBatter: onTapBatter, onLongTapBatter: onLongTapBatter, onLongTapBowler: onLongTapBowler)
    //     //Recent Balls
    //     //Wicket Selector
    //     //Ball Details Selector
    //     //
    //   ],
    // );
  }
}
