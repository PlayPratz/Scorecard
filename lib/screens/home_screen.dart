import 'package:flutter/material.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/team_model.dart';
import 'package:scorecard/screens/cricket_match/create_cricket_match_screen.dart';
import 'package:scorecard/screens/player/player_list_screen.dart';
import 'package:scorecard/screens/team/team_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            _HomeScreenSection(
              title: "Players",
              children: [
                PlayerTile(
                  Player(name: "Pratik Nerurkar"),
                  onSelect: () {},
                ),
                PlayerTile(
                  Player(name: "Rutash Joshipura"),
                  onSelect: () {},
                ),
                ListTile(
                  leading: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {},
                  title: Text("Add"),
                  trailing: Icon(Icons.chevron_right),
                )
              ],
            ),
            _HomeScreenSection(title: "Teams", children: [
              TeamTile(
                Team(name: "Mumbai Indians", color: Colors.blueAccent.value),
                onSelect: () {},
              ),
              TeamTile(
                Team(
                    name: "Chennai Super Kings",
                    color: Colors.yellowAccent.value),
                onSelect: () {},
              ),
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: () {},
                title: Text("Add"),
                trailing: Icon(Icons.chevron_right),
              )
            ])
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.sports_baseball),
        onPressed: () => _createMatch(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }

  void _createMatch(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateCricketMatchScreen()));
  }
}

class _HomeScreenSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _HomeScreenSection(
      {super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        ...children
      ],
    );
  }
}
