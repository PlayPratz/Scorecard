import 'package:flutter/material.dart';
import 'package:scorecard/screens/createteam.dart';
import 'package:scorecard/screens/teamlist.dart';

import '../styles/colorstyles.dart';
import '../styles/strings.dart';
import '../util/utils.dart';
import 'basescreen.dart';
import 'matchlist.dart';
import 'playerlist.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({Key? key}) : super(key: key);

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      MatchList(),
      TeamList(
        teamList: Utils.getAllTeams(),
        onSelectTeam: (team) =>
            Utils.goToPage(CreateTeamForm(team: team), context),
      ),
      PlayerList(
        playerList: Utils.getAllPlayers(),
        showAddButton: true,
      ),
    ];
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
          BottomNavigationBar(
            currentIndex: _index,
            backgroundColor: ColorStyles.elevated,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_cricket),
                label: Strings.navbarMatches,
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.emoji_events),
              //   label: Strings.navbarTournaments,
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.thumbs_up_down),
                label: Strings.navbarTeams,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: Strings.navbarPlayers,
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.settings),
              //   label: Strings.navbarSettings,
              // ),
            ],
            onTap: (selectedIndex) => setState(() {
              _index = selectedIndex;
            }),
          )
        ],
      ),
    );
  }
}
