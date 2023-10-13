import 'package:flutter/material.dart';
import 'package:scorecard/screens/match/create_match.dart';
import 'package:scorecard/screens/match/match_list.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/statistics/statistics_screen.dart';
import 'package:scorecard/screens/templates/base_screen.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

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
      body: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
        child: screens[_index],
      ),
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
            label: "Completed", //TODO Abstract
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
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Utils.goToPage(
                const CreateQuickMatchForm(),
                context,
              ),
              icon: const Icon(Icons.add),
            ),
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: Strings.navbarPlayers,
          ),
          const NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: Strings.navbarStats,
          ),
        ],
        onDestinationSelected: (selectedIndex) => setState(() {
          _index = selectedIndex;
        }),
      ),
    ));
  }

  List<Widget> get screens => [
        const OngoingCricketMatches(),
        const CompletedCricketMatches(),
        const CreateQuickMatchForm(),
        const AllPlayersList(),
        const StatisticsScreen()
      ];
}
