import 'package:flutter/material.dart';
import 'package:scorecard/screens/cricket_match/create_cricket_match_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.sports_baseball),
        onPressed: () => _createMatch(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: const BottomAppBar(
        child: Row(
          children: [
            Icon(Icons.hearing),
            Icon(Icons.favorite),
            Icon(Icons.sports),
          ],
        ),
      ),
    );
  }

  void _createMatch(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CreateCricketMatchScreen()));
  }
}
