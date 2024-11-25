import 'package:flutter/material.dart';
import 'package:scorecard/screens/cricket_match/create_cricket_match_screen.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HomeScreenTile(
              title: "New Match",
              onSelect: () => _goCreateMatch(context),
            ),
            _HomeScreenTile(title: "Load Match"),
            _HomeScreenTile(
              title: "Players",
              onSelect: () => _goPlayerList(context),
            ),
            _HomeScreenTile(title: "Venues"),
          ],
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: Row(
          children: [
            Icon(Icons.hearing),
            Icon(Icons.favorite),
            Icon(Icons.sports),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }

  void _goCreateMatch(BuildContext context) {
    final controller = CreateCricketMatchController();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateCricketMatchScreen(controller)),
    );
  }

  void _goPlayerList(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AllPlayersScreen()));
  }
}

class _HomeScreenTile extends StatelessWidget {
  final String title;
  final void Function()? onSelect;

  const _HomeScreenTile({super.key, required this.title, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: onSelect == null ? null : const Icon(Icons.chevron_right),
      onTap: onSelect,
    );
  }
}
