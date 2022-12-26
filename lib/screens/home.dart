import 'package:flutter/material.dart';
import 'package:scorecard/screens/match/create_match.dart';
import 'package:scorecard/screens/player/create_player.dart';
import 'package:scorecard/screens/team/create_team.dart';
import 'package:scorecard/screens/team/team_list.dart';
import 'package:scorecard/services/storage_service.dart';

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
        child: Scaffold(
      body: screens[_index],
      backgroundColor: ColorStyles.background,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: ColorStyles.card,

        // type: BottomNavigationBarType.fixed,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.live_tv),
            label: "Ongoing",
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_available),
            label: "Completed",
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.add),
          //   label: "Create",
          // ),
          DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.tealAccent,
                  width: 2,
                ),
                shape: BoxShape.circle),
            child: IconButton(
              onPressed: () => Utils.goToPage(
                const CreateMatchForm(),
                context,
              ),
              icon: const Icon(Icons.add),
            ),
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups),
            label: Strings.navbarTeams,
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: Strings.navbarPlayers,
          ),
        ],
        onDestinationSelected: (selectedIndex) => setState(() {
          _index = selectedIndex;
        }),
      ),
    ));
  }

  List<Widget> get screens => [
        MatchList(
          matchList: StorageService.getOngoingMatches(),
        ),
        MatchList(
          matchList: StorageService.getCompletedMatches(),
        ),
        const CreateMatchForm(),
        TeamList(
          teamList: StorageService.getAllTeams(),
          onSelectTeam: (team) => Utils.goToPage(
            CreateTeamForm.update(team: team),
            context,
          ).then((_) => setState(() {})),
          onCreateTeam: (team) => setState(() {}),
        ),
        PlayerList(
          playerList: StorageService.getAllPlayers(),
          onSelectPlayer: (player) => Utils.goToPage(
            CreatePlayerForm.update(player: player),
            context,
          ).then((_) => setState(() {})),
          onCreatePlayer: (player) => setState(() {}),
        ),
      ];
}
