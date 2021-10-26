import 'package:flutter/material.dart';
import 'package:scorecard/screens/basescreen.dart';
import 'package:scorecard/screens/matchlist.dart';
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
    const Text("Friend"),
    const Text("Tourn"),
    const Text("Player"),
  ];
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          Expanded(child: test[_index]),
          const Divider(),
          BottomNavigationBar(
            currentIndex: _index,
            backgroundColor: ColorStyles.background,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_cricket),
                label: Strings.navbarMatches,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.thumbs_up_down),
                label: Strings.navbarFriendlies,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events),
                label: Strings.navbarTournaments,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: Strings.navbarPlayers,
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
