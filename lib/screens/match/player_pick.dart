import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/match/player_score_tile.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/separated_widgets.dart';
import 'package:scorecard/util/strings.dart';

class PickBatter extends StatelessWidget {
  final List<Player> squad;
  final Player batterToReplace;
  final Wicket? wicket;
  const PickBatter({
    super.key,
    required this.squad,
    required this.batterToReplace,
    this.wicket,
  });

  @override
  Widget build(BuildContext context) {
    return TitledPage(
      title: Strings.pickBatterTitle,
      child: SeparatedWidgetPair(
        top: PlayerScoreTile.wicket(
          player: batterToReplace,
          score: wicket != null ? Strings.getWicketDescription(wicket) : "",
        ),
        bottom: Expanded(
          child: PlayerList(playerList: squad),
        ),
      ),
    );
  }
}
