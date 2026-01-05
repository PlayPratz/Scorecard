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

  final controller = LoadQuickMatchController();

  @override
  Widget build(BuildContext context) {
    final quickMatchFuture = controller.loadAllMatches(context);

    final showHandles = context.read<SettingsService>().getShowHandles();

    final dateFormat =
        DateFormat.yMMMd(Localizations.localeOf(context).languageCode).add_jm();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Load a quick match"),
        ),
        body: FutureBuilder(
          future: quickMatchFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error!");
            } else if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final matches = snapshot.data!;
              if (matches.isEmpty) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      "You don't have any matches! Head back to the main menu to start a new match."),
                ));
              }
              return ListView.builder(
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return ListTile(
                    title: Text(dateFormat.format(match.startsAt)),
                    subtitle: showHandles ? Text(match.handle) : null,
                    leading: wMatchIndicator(match),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => loadMatch(context, match.id!),
                  );
                },
                itemCount: matches.length,
              );
            }
          },
        ));
  }

  Widget wMatchIndicator(QuickMatch match) {
    if (match.stage == 9) {
      return const CircleAvatar(
        child: Icon(Icons.check),
      );
    } else {
      return const CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.pending_actions),
      );
    }
  }
}

class LoadQuickMatchController {
  Future<List<QuickMatch>> loadAllMatches(BuildContext context) async {
    final matches = await _service(context).getAllQuickMatches();
    return matches;
  }

  QuickMatchService _service(BuildContext context) =>
      context.read<QuickMatchService>();
}

Future<void> loadMatch(BuildContext context, int matchId) async {
  final service = context.read<QuickMatchService>();
  final match = await service.getMatch(matchId);
  if (!context.mounted) {
    return;
  }
  if (match.stage == 9) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ScorecardScreen(match.id!)));
  } else {
    final innings = await service.getAllInningsOf(match.id!);
    if (context.mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PlayQuickInningsScreen(innings.last.id!)));
    }
  }
}
