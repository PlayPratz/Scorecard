import 'package:flutter/material.dart';
import 'package:scorecard/screens/quick_match/create_quick_match_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text("Quick Match"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onCreateQuickMatch(context),
          ),
        ],
      ),
    );
  }

  void onCreateQuickMatch(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CreateQuickMatchScreen()));
  }
}
