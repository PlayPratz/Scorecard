import 'package:flutter/material.dart';
import 'package:scorecard/screens/player/create_player.dart';
import 'package:scorecard/screens/series/series_list.dart';
import 'package:scorecard/screens/team/create_team.dart';
import 'package:scorecard/screens/team/team_list.dart';
import 'package:scorecard/util/storage_utils.dart';

import '../styles/color_styles.dart';
import '../util/strings.dart';
import '../util/utils.dart';
import 'templates/base_screen.dart';
import 'match/match_list.dart';
import 'player/player_list.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({Key? key}) : super(key: key);

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
              child: screens[_index],
            ),
          ),
          // const Divider(),
          DecoratedBox(
            // position: DecorationPosition.foreground,
            decoration: const BoxDecoration(
              color: ColorStyles.card,
              border: Border(
                top: BorderSide(color: ColorStyles.highlight, width: 2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: BottomNavigationBar(
                currentIndex: _index,
                backgroundColor: ColorStyles.card,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.emoji_events),
                    label: "Series",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.live_tv),
                    label: "Ongoing",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_available),
                    label: "Completed",
                  ),
                  // BottomNavigationBarItem(
                  //   icon: Icon(Icons.emoji_events),
                  //   label: Strings.navbarTournaments,
                  // ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.groups),
                    label: Strings.navbarTeams,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: Strings.navbarPlayers,
                  ),
                ],
                onTap: (selectedIndex) => setState(() {
                  _index = selectedIndex;
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> get screens => [
        SeriesList(series: StorageUtils.getAllSeries()),
        MatchList(
          allowCreateMatch: true,
          matchList: StorageUtils.getOngoingMatches(),
        ),
        MatchList(
          matchList: StorageUtils.getCompletedMatches(),
        ),
        TeamList(
          teamList: StorageUtils.getAllTeams(),
          onSelectTeam: (team) => Utils.goToPage(
            CreateTeamForm.update(team: team),
            context,
          ).then((_) => setState(() {})),
          onCreateTeam: (team) => setState(() {}),
        ),
        PlayerList(
          playerList: StorageUtils.getAllPlayers(),
          onSelectPlayer: (player) => Utils.goToPage(
            CreatePlayerForm.update(player: player),
            context,
          ).then((_) => setState(() {})),
          onCreatePlayer: (player) => setState(() {}),
        ),
      ];
}
