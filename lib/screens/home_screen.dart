import 'package:flutter/material.dart';
import 'package:scorecard/screens/cricket_match/create_cricket_match_screen.dart';

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
              onSelect: () => _createMatch(context),
            ),
            _HomeScreenTile(title: "Load Match"),
            _HomeScreenTile(title: "Players"),
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

  void _createMatch(BuildContext context) {
    final controller = CreateCricketMatchController();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateCricketMatchScreen(controller)),
    );
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
