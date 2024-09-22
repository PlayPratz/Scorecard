import 'package:flutter/cupertino.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';

class InningsTimelineScreen extends StatelessWidget {
  final Innings innings;

  const InningsTimelineScreen({super.key, required this.innings});

  @override
  Widget build(BuildContext context) {
    final posts = innings.posts;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemBuilder: (context, index) {
          final post = posts[index];
          late final Widget widget;
          // TODO Abstract Text
          switch (post) {
            case NextBowler():
              widget = Text("${post.next.name} is going to bowl the next over");
            case BatterRetire():
              widget = Text("${post.batter.name} has retired");
            case NonStrikerRunout():
              widget = Text(
                  "${post.wicket.batter} has been run-out at the non-striker's end!");
            case NextBatter():
              widget = Text("The next batter in is ${post.next.name}");
            case Ball():
              widget = Text(
                  "${post.bowler.name} to ${post.batter.name}, ${post.runs} runs");
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget,
          );
        },
      ),
    );
  }
}
