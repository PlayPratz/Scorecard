import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/ui/stringify.dart';

class InningsTimelineScreen extends StatelessWidget {
  final Innings innings;

  const InningsTimelineScreen(this.innings, {super.key});

  @override
  Widget build(BuildContext context) {
    final overs = innings.overs;
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        reverse: true,
        itemCount: overs.length,
        itemBuilder: (context, i) {
          final index = overs.length - 1 - i;
          final over = overs[index]!;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Over ${index + 1}",
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Table(
                    defaultVerticalAlignment:
                        TableCellVerticalAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    columnWidths: const {
                      0: FixedColumnWidth(56),
                      1: FlexColumnWidth()
                    },
                    children: [
                      for (final post in over)
                        TableRow(children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 8.0, top: 8.0),
                            child: Text(Stringify.inningsIndex(post.index),
                                textAlign: TextAlign.right),
                          ),
                          widget(post),
                        ])
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomAppBar(),
    );
  }

  Widget widget(InningsPost post) => switch (post) {
        BowlerRetire() => Text("${post.bowler.name.toUpperCase()} has retired"),
        NextBowler() => Text("${post.next.name.toUpperCase()} to bowl"),
        BatterRetire() => Text(
            "${post.batter.name.toUpperCase()} has retired (${Stringify.wicket(null, retired: post.retired)})"),
        NextBatter() =>
          Text("The next batter in is ${post.next.name.toUpperCase()}"),
        RunoutBeforeDelivery() =>
          Text("${post.wicket.batter.name.toUpperCase()} has been run-out!"),
        // TODO: Handle this case.
        Ball() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "${post.bowler.name.toUpperCase()} to ${post.batter.name.toUpperCase()}, ${post.runs} runs"),
              if (post.isWicket) Text(Stringify.wicket(post.wicket))
            ],
          ),
      };
}
