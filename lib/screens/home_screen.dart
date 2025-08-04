import 'package:flutter/material.dart';
import 'package:scorecard/screens/quick_match/create_quick_match_screen.dart';
import 'package:scorecard/screens/quick_match/load_quick_match_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scorecard"),
        toolbarHeight: 256,
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("New Quick Match"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onNewQuickMatch(context),
          ),
          ListTile(
            title: const Text("Load Quick Match"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onLoadQuickMatch(context),
          ),
        ],
      ),
    );
  }

  void onNewQuickMatch(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CreateQuickMatchScreen()));
  }

  void onLoadQuickMatch(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoadQuickMatchScreen(),
        ));
  }
}
