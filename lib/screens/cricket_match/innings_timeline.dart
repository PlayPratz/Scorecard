import 'package:flutter/cupertino.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';

class InningsTimelineScreen extends StatelessWidget {
  final Innings innings;

  const InningsTimelineScreen(this.innings, {super.key});

  @override
  Widget build(BuildContext context) {
    final posts = innings.posts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget(post),
          );
        },
      ),
    );
  }

  Widget widget(InningsPost post) => switch (post) {
        BowlerRetire() => Text("${post.bowler.name} has retired"),
        NextBowler() =>
          Text("${post.next.name} is going to bowl the next over"),
        BatterRetire() => Text("${post.batter.name} has retired"),
        NextBatter() => Text("The next batter in is ${post.next.name}"),
        RunoutBeforeDelivery() => Text(
            "${post.wicket.batter} has been run-out at the non-striker's end!"),
        // TODO: Handle this case.
        Ball() =>
          Text("${post.bowler.name} to ${post.batter.name}, ${post.runs} runs"),
      };
}
