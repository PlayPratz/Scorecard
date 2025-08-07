import 'package:flutter/material.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';
import 'package:scorecard/screens/quick_match/create_quick_match_screen.dart';
import 'package:scorecard/screens/quick_match/load_quick_match_screen.dart';
import 'package:scorecard/screens/settings_screen.dart';

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
            onTap: () => onNewQuickMatch(context),
          ),
          wMenuItem(
            "Load Quick Match",
            // "Resume or view a previously created match",
            icon: Icons.storage,
            onTap: () => onLoadQuickMatch(context),
          ),
          const SizedBox(height: 32),
          wMenuItem(
            "Players",
            // "Manage the sportsmen on the field",
            icon: Icons.people,
            onTap: () => onPlayerList(context),
          ),
          wMenuItem(
            "Settings",
            // "Manage the sportsmen on the field",
            icon: Icons.settings,
            onTap: () => onSettings(context),
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

  void onNewQuickMatch(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateQuickMatchScreen()));
  }

  void onLoadQuickMatch(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadQuickMatchScreen(),
        ));
  }

  void onPlayerList(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AllPlayersScreen()));
  }

  void onSettings(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }
}
