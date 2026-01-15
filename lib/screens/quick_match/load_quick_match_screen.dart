import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/screens/quick_match/play_quick_match_screen.dart';
import 'package:scorecard/screens/quick_match/scorecard_screen.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/services/settings_service.dart';

class LoadQuickMatchScreen extends StatelessWidget {
  LoadQuickMatchScreen({super.key});

  final controller = _LoadQuickMatchController();

  @override
  Widget build(BuildContext context) {
    final quickMatchFuture = controller.loadAllMatches(context);
    final showHandles = context.read<SettingsService>().getShowHandles();
    final dateFormat = DateFormat.yMMMd("en_IN").add_jm();
    // DateFormat.yMMMd(Localizations.localeOf(context).languageCode).add_jm();
    return Scaffold(
      appBar: AppBar(title: const Text("Load a quick match")),
      body: StreamBuilder<_LoadQuickMatchScreenState>(
        stream: controller.stateStream,
        initialData: _LoadingState(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error!");
          }
          final state = snapshot.data!;
          switch (state) {
            case _LoadingState():
              return const Center(child: CircularProgressIndicator());
            case _LoadedState():
              final matches = state.matches;
              if (matches.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "You don't have any matches! Head back to the main menu to start a new match.",
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(dateFormat.format(match.startsAt)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${match.rules.ballsPerOver} overs"),
                                if (showHandles) Text("#${match.handle}"),
                              ],
                            ),
                            isThreeLine: true,
                            leading: wMatchIndicator(match),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => loadMatch(context, match.id!),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.delete_forever),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                ),
                                label: const Text("Delete"),
                                onPressed: () =>
                                    controller.deleteMatch(context, match),
                              ),

                              if (match.isEnded)
                                TextButton.icon(
                                  icon: const Icon(Icons.list_alt),
                                  label: const Text("Scorecard"),
                                  onPressed: () =>
                                      loadMatch(context, match.id!),
                                ),
                              if (!match.isEnded)
                                TextButton.icon(
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text("Resume"),
                                  onPressed: () =>
                                      loadMatch(context, match.id!),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: matches.length,
              );
          }
        },
      ),
    );
  }

  Widget wMatchIndicator(QuickMatch match) {
    if (match.isEnded) {
      return const CircleAvatar(child: Icon(Icons.check));
    } else {
      return const CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.pending_actions),
      );
    }
  }
}

class _LoadQuickMatchController {
  final streamController = StreamController<_LoadQuickMatchScreenState>();
  Stream<_LoadQuickMatchScreenState> get stateStream => streamController.stream;

  Future<void> loadAllMatches(BuildContext context) async {
    streamController.add(_LoadingState());
    final matches = await _service(context).getAllQuickMatches();
    streamController.add(_LoadedState(matches));
  }

  Future<void> deleteMatch(BuildContext context, QuickMatch match) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete this match?"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("It will be gone for a really long time!"),
            SizedBox(height: 16),
            Text(
              "Deleting this match will result in the reversal of stats of all players that participated in it.",
            ),
          ],
        ),

        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            label: const Text("Nope!"),
            icon: const Icon(Icons.cancel),
          ),

          FilledButton.icon(
            label: const Text("Delete!"),
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await _service(context).deleteQuickMatch(match);
              if (context.mounted) {
                Navigator.pop(context);
                await loadAllMatches(context);
              }
            },
          ),
        ],
      ),
    );
  }

  QuickMatchService _service(BuildContext context) =>
      context.read<QuickMatchService>();
}

sealed class _LoadQuickMatchScreenState {}

class _LoadingState extends _LoadQuickMatchScreenState {}

class _LoadedState extends _LoadQuickMatchScreenState {
  List<QuickMatch> matches;
  _LoadedState(this.matches);
}

Future<void> loadMatch(BuildContext context, int matchId) async {
  final service = context.read<QuickMatchService>();
  final match = await service.getMatch(matchId);
  if (!context.mounted) {
    return;
  }
  if (match.isEnded) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScorecardScreen(match.id!, exitToHome: true),
      ),
    );
  } else {
    final innings = await service.getAllInningsOf(match.id!);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlayQuickInningsScreen(innings.last.id!),
        ),
      );
    }
  }
}
