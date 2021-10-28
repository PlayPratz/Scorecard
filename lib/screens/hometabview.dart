import 'package:flutter/material.dart';
import 'package:scorecard/screens/basescreen.dart';
import 'package:scorecard/screens/matchlist.dart';
import 'package:scorecard/screens/playerlist.dart';
import 'package:scorecard/styles/colorstyles.dart';
import 'package:scorecard/styles/strings.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({Key? key}) : super(key: key);

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  int _index = 0;

  final List<Widget> test = [
    MatchList(),
    const Text("Tourney"),
    const Text("Teams"),
    PlayerList(),
    const Text("Settings"),
  ];
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          Expanded(child: test[_index]),
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
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events),
                label: Strings.navbarTournaments,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.thumbs_up_down),
                label: Strings.navbarTeams,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: Strings.navbarPlayers,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: Strings.navbarSettings,
              ),
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
