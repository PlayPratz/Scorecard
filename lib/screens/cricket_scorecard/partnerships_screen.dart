import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';

class PartnershipScreen extends StatelessWidget {
  final Innings innings;
  const PartnershipScreen(this.innings, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${innings.battingTeam.short} Partnerships"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [Text("Coming Soon")],
      ),
      bottomNavigationBar: const BottomAppBar(),
    );
  }
}

class _PartnershipBar extends StatelessWidget {
  final int batter1Contribution;
  final int batter2Contribution;
  const _PartnershipBar(
      {required this.batter1Contribution, required this.batter2Contribution});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: batter1Contribution,
          child: const Divider(color: Colors.blue),
        ),
        Expanded(
          flex: batter2Contribution,
          child: const Divider(color: Colors.teal),
        ),
      ],
    );
  }
}

class _PartnershipContribution extends StatelessWidget {
  final int runs;
  final int balls;
  const _PartnershipContribution({required this.runs, required this.balls});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(runs.toString()),
        const SizedBox(width: 2),
        Text("($balls)"),
      ],
    );
  }
}
