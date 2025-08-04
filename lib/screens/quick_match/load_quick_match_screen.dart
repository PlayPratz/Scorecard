import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/screens/quick_match/play_quick_match_screen.dart';
import 'package:scorecard/services/quick_match_service.dart';

class LoadQuickMatchScreen extends StatelessWidget {
  const LoadQuickMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LoadQuickMatchController();
    final quickMatchFuture = controller.loadAllMatches(context);
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
              return ListView.builder(
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return ListTile(
                    title: Text(match.startsAt.toString()),
                    subtitle: Text(match.id),
                    // leading: const CircleAvatar(child: Text('1')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => controller.loadMatch(context, match),
                  );
                },
                itemCount: matches.length,
              );
            }
          },
        ));
  }
}

class LoadQuickMatchController {
  Future<List<QuickMatch>> loadAllMatches(BuildContext context) async {
    final matches = await _service(context).loadAllQuickMatches();
    return matches;
  }

  void loadMatch(BuildContext context, QuickMatch match) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => PlayQuickMatchScreen(match)));
  }

  QuickMatchService _service(BuildContext context) =>
      context.read<QuickMatchService>();
}
