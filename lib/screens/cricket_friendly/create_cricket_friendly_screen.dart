import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/screens/cricket_match/create_cricket_match_screen.dart';

class CreateCricketFriendlyScreen extends StatelessWidget {
  const CreateCricketFriendlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameRulesController = LimitedOverGameRulesController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's create a new Friendly!"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LimitedOverGameRulesSection(gameRulesController),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => createCricketFriendly(gameRulesController.state),
              label: const Text("Toss"),
            ),
          ],
        ),
      ),
    );
  }

  void createCricketFriendly(GameRules gameRules) {}
}
