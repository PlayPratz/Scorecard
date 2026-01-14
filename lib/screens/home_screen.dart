import 'package:flutter/material.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';
import 'package:scorecard/screens/quick_match/create_quick_match_screen.dart';
import 'package:scorecard/screens/quick_match/load_quick_match_screen.dart';
import 'package:scorecard/screens/settings_screen.dart';
import 'package:scorecard/screens/statistics/statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scorecard"),
        toolbarHeight: 256,
        elevation: 4,
      ),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          wMenuItem(
            "New Quick Match",
            // "Start a quick match right away!",
            icon: Icons.sports_cricket,
            onTap: () => goNewQuickMatch(context),
          ),
          wMenuItem(
            "Load Quick Match",
            // "Resume or view a previously created match",
            icon: Icons.storage,
            onTap: () => goLoadQuickMatch(context),
          ),
          const SizedBox(height: 32),
          wMenuItem(
            "Players",
            // "Manage the sportsmen on the field",
            icon: Icons.people,
            onTap: () => goPlayerList(context),
          ),
          wMenuItem(
            "Statistics",
            // "Manage the sportsmen on the field",
            icon: Icons.auto_graph,
            onTap: () => goStatistics(context),
          ),
          const SizedBox(height: 32),
          wMenuItem(
            "Settings",
            // "Manage the sportsmen on the field",
            icon: Icons.settings,
            onTap: () => goSettings(context),
          ),
        ],
      ),
    );
  }

  Widget wMenuItem(
    String title,
    // String description,
    {
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      ListTile(
        title: Text(title),
        // subtitle: Text(description),
        leading: Icon(icon),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );

  void goNewQuickMatch(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateQuickMatchScreen()));
  }

  void goLoadQuickMatch(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadQuickMatchScreen(),
        ));
  }

  void goPlayerList(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AllPlayersScreen()));
  }

  void goStatistics(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const AllPlayerStatisticsScreen()));
  }

  void goSettings(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }
}
