import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_rules_model.dart';
import 'package:scorecard/modules/cricket_match/services/cricket_match_service.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_screen_switcher.dart';

class ReviewCricketGameScreen extends StatelessWidget {
  final ReviewCricketGameScreenController controller;
  const ReviewCricketGameScreen(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final cricketMatch = controller.cricketMatch;
    final game = cricketMatch.game;
    return StreamBuilder(
        stream: controller._stream,
        initialData: _ReviewScreenState(cricketMatch),
        builder: (context, snapshot) {
          final state = snapshot.data!;
          switch (state) {
            case _ReviewScreenState():
              return Scaffold(
                appBar: AppBar(),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    children: [
                      _TossPreviewSection(cricketMatch.toss),
                      const SizedBox(height: 16),
                      _MatchupPreviewSection(
                        team1: game.team1,
                        lineup1: game.lineup1,
                        team2: game.team2,
                        lineup2: game.lineup2,
                      ),
                      const SizedBox(height: 16),
                      _GameRulesPreviewSection(game.rules),
                    ],
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () => controller.onCommenceMatch(context),
                        label: const Text("Start!"),
                        icon: const Icon(Icons.sports_cricket),
                      )
                    ],
                  ),
                ),
              );
            case _LoadingNextScreenState():
              return Scaffold(
                appBar: AppBar(),
                body: const Center(child: CircularProgressIndicator()),
                bottomNavigationBar: const BottomAppBar(),
              );
          }
        });
  }
}

sealed class _ScreenState {}

class _ReviewScreenState extends _ScreenState {
  final InitializedCricketMatch cricketMatch;

  _ReviewScreenState(this.cricketMatch);
}

class _LoadingNextScreenState extends _ScreenState {}

class ReviewCricketGameScreenController {
  final InitializedCricketMatch cricketMatch;
  ReviewCricketGameScreenController(this.cricketMatch);

  final _streamController = StreamController<_ScreenState>();
  Stream<_ScreenState> get _stream => _streamController.stream;

  Future<void> onCommenceMatch(BuildContext context) async {
    _streamController.add(_LoadingNextScreenState());
    try {
      final ongoingCricketMatch =
          await _service.commenceCricketMatch(cricketMatch);
      if (context.mounted) {
        goNextScreen(context, ongoingCricketMatch);
      }
    } catch (e) {
      _streamController.add(_LoadingNextScreenState());
    }
  }

  void goNextScreen(BuildContext context, OngoingCricketMatch cricketMatch) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CricketMatchScreenSwitcher(cricketMatch)));
  }

  CricketMatchService get _service => CricketMatchService();
}

class _MatchupPreviewSection extends StatelessWidget {
  final Team team1;
  final Lineup lineup1;
  final Team team2;
  final Lineup lineup2;

  const _MatchupPreviewSection({
    super.key,
    required this.team1,
    required this.team2,
    required this.lineup1,
    required this.lineup2,
  });

  @override
  Widget build(BuildContext context) {
    final playerList1 = lineup1.players;
    final playerList2 = lineup2.players;
    final rowCount = max(playerList1.length, playerList2.length);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lineups", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {1: FlexColumnWidth(0.2)},
              border: const TableBorder(horizontalInside: BorderSide(width: 0)),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(team1.name.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  const Center(child: Text('v')),
                  Text(team2.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall),
                ]),
                for (int i = 0; i < rowCount; i++)
                  TableRow(
                    children: [
                      i < playerList1.length
                          ? Text(
                              _wPlayerName(playerList1[i], lineup1.captain),
                              textAlign: TextAlign.right,
                            )
                          : const SizedBox(),
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((i + 1).toString()),
                      )),
                      i < playerList2.length
                          ? Text(_wPlayerName(playerList2[i], lineup2.captain))
                          : const SizedBox(),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _wPlayerName(Player player, Player captain) {
    final name = player.name.toUpperCase();
    if (player == captain) {
      return '$name (c)';
    } else {
      return name;
    }
  }
}

class _GameRulesPreviewSection extends StatelessWidget {
  final GameRules rules;
  const _GameRulesPreviewSection(this.rules, {super.key});

  @override
  Widget build(BuildContext context) {
    final rules = this.rules;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rules", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
              },
              border: const TableBorder(
                horizontalInside: BorderSide(width: 0),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                ...switch (rules) {
                  LimitedOversRules() => [
                      TableRow(children: [
                        _wLabelWidget("Overs per Bowler"),
                        Text(rules.oversPerInnings.toString())
                      ]),
                      TableRow(children: [
                        _wLabelWidget("Overs per Bowler"),
                        Text(rules.oversPerBowler.toString())
                      ]),
                    ],
                  UnlimitedOversRules() => [
                      TableRow(children: [
                        _wLabelWidget("Overs per Bowler"),
                        Text(rules.daysOfPlay.toString())
                      ]),
                      TableRow(children: [
                        _wLabelWidget("Overs per Bowler"),
                        Text(rules.inningsPerSide.toString())
                      ])
                    ],
                },
                TableRow(children: [
                  _wLabelWidget("Overs per Bowler"),
                  Text(rules.ballsPerOver.toString())
                ]),
                TableRow(children: [
                  _wLabelWidget("Overs per Bowler"),
                  Text(rules.noBallPenalty.toString())
                ]),
                TableRow(children: [
                  _wLabelWidget("Wide penalty"),
                  Text(rules.widePenalty.toString())
                ]),
                TableRow(children: [
                  _wLabelWidget("Only Single Batter"),
                  Text(rules.onlySingleBatter.toString())
                ]),
                TableRow(children: [
                  _wLabelWidget("Allow Last Man"),
                  Text(rules.lastWicketBatter.toString())
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _wLabelWidget(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(label, textAlign: TextAlign.right),
      );
}

class _TossPreviewSection extends StatelessWidget {
  final Toss toss;
  const _TossPreviewSection(this.toss, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
        "${toss.winner.short} won the toss and chose to ${toss.choice.name}");
  }
}
