import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/cricket_match/services/cricket_match_service.dart';
import 'package:scorecard/screens/cricket_match/cricket_match_screen_switcher.dart';

class CricketMatchListScreen extends StatelessWidget {
  const CricketMatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _CMLSController();
    controller._fetchAll();
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Cricket Matches")),
      body: StreamBuilder(
          stream: controller.stream,
          initialData: _CMLLoadingState(),
          builder: (context, snapshot) => switch (snapshot.data!) {
                _CMLLoadingState() =>
                  const Center(child: CircularProgressIndicator()),
                _CMLLoadedState() => ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    children: [
                      const ListTile(
                        subtitle: Text(
                            "This page is under development. Kindly excuse the incomplete UI."),
                      ),
                      for (final cricketMatch
                          in (snapshot.data as _CMLLoadedState).cricketMatches)
                        _CricketMatchTile(
                          cricketMatch,
                          onSelectMatch: () => controller.openCricketMatch(
                              context, cricketMatch),
                        )
                    ],
                  ),
              }),
    );
  }
}

sealed class _CMLState {}

class _CMLLoadingState extends _CMLState {}

class _CMLLoadedState extends _CMLState {
  final Iterable<ScheduledCricketMatch> cricketMatches;

  _CMLLoadedState(this.cricketMatches);
}

class _CMLSController {
  final _streamController = StreamController<_CMLState>();
  Stream<_CMLState> get stream => _streamController.stream;

  Future<void> _fetchAll() async {
    _streamController.add(_CMLLoadingState());
    final cricketMatches = await CricketMatchService().getAllMatches();
    _streamController.add(_CMLLoadedState(cricketMatches));
  }

  void openCricketMatch(BuildContext context, CricketMatch cricketMatch) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CricketMatchScreenSwitcher(cricketMatch),
        ));
  }
}

class _CricketMatchTile extends StatelessWidget {
  final ScheduledCricketMatch cricketMatch;
  final void Function() onSelectMatch;
  const _CricketMatchTile(this.cricketMatch,
      {super.key, required this.onSelectMatch});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("${cricketMatch.team1.short} vs ${cricketMatch.team2.short}"),
      onTap: onSelectMatch,
      trailing: const Icon(Icons.chevron_right),
      subtitle: Text(cricketMatch.startsAt.toString()),
    );
  }
}
