import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/cache/player_cache.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/ui/stringify.dart';

class InningsTimelineScreen extends StatelessWidget {
  final QuickInnings innings;

  const InningsTimelineScreen(this.innings, {super.key});

  @override
  Widget build(BuildContext context) {
    final overs = context.read<QuickMatchService>().getOvers(innings);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeline"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: overs.length,
        reverse: true,
        itemBuilder: (context, index) {
          final overIndex = overs.length - index;
          final over = overs[overIndex]!;
          // TODO Find a better place for this
          final runs = over.whereType<Ball>().fold(0, (p, e) => p + e.runs);
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Over $overIndex",
                          style: Theme.of(context).textTheme.titleSmall),
                      Text("$runs Runs",
                          style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InningsPostsView(over),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomAppBar(),
    );
  }
}
//
// class BatterInningsTimelineScreen extends StatelessWidget {
//   final BatterInnings batterInnings;
//
//   const BatterInningsTimelineScreen(this.batterInnings, {super.key});
//
//   @override
//   Widget build(BuildContext context) => _PlayerInningsTimelineScreen(
//       playerName: batterInnings.player.fullName ?? batterInnings.player.name,
//       posts: batterInnings.posts);
// }
//
// class BowlerInningsTimelineScreen extends StatelessWidget {
//   final BowlerInnings bowlerInnings;
//
//   const BowlerInningsTimelineScreen(this.bowlerInnings, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return _PlayerInningsTimelineScreen(
//         playerName: bowlerInnings.player.fullName ?? bowlerInnings.player.name,
//         posts: bowlerInnings.posts);
//   }
// }

// class _PlayerInningsTimelineScreen extends StatelessWidget {
//   final String playerName;
//   final Iterable<InningsPost> posts;
//
//   const _PlayerInningsTimelineScreen(
//       {required this.playerName, required this.posts});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(playerName)),
//       body: ListView(
//         reverse: true,
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         children: [
//           const SizedBox(height: 32),
//           _InningsPostsView(posts, playerMap: ,),
//         ],
//       ),
//       bottomNavigationBar: const BottomAppBar(),
//     );
//   }
// }

class _InningsPostsView extends StatelessWidget {
  final Iterable<InningsPost> posts;
  const _InningsPostsView(this.posts);

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      columnWidths: const {0: FixedColumnWidth(56), 1: FlexColumnWidth()},
      children: [
        for (final post in posts)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Text(Stringify.postIndex(post.index),
                  textAlign: TextAlign.right),
            ),
            _InningsPostWidget(post),
          ])
      ],
    );
  }
}

class _InningsPostWidget extends StatelessWidget {
  final InningsPost post;

  const _InningsPostWidget(this.post);

  @override
  Widget build(BuildContext context) {
    // This allows for easier typecasting
    final post = this.post;
    final playerCache = PlayerCache();

    getPlayerName(String id) => playerCache.get(id).name;

    return switch (post) {
      BowlerRetire() => Text(
          "${playerCache.get(post.bowlerId).name.toUpperCase()} has retired"),
      NextBowler() =>
        Text("${playerCache.get(post.nextId).name.toUpperCase()} to bowl"),
      BatterRetire() => Text(
          "${playerCache.get(post.batterId).name.toUpperCase()} has retired (${Stringify.wicket(null, retired: post.retired, getPlayerName: getPlayerName)})"),
      NextBatter() => Text(
          "The next batter in is ${playerCache.get(post.nextId).name.toUpperCase()}"),
      RunoutBeforeDelivery() => Text(
          "${playerCache.get(post.batterId).name.toUpperCase()} has been run-out!"),
      Ball() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "${playerCache.get(post.bowlerId).name.toUpperCase()} to ${playerCache.get(post.bowlerId).name.toUpperCase()}, ${post.runs} runs"),
            if (post.isWicket)
              Text(
                  "Wicket: ${playerCache.get(post.bowlerId).name.toUpperCase()} (${Stringify.wicket(post.wicket!, getPlayerName: getPlayerName)})")
          ],
        ),
    };
  }
}
