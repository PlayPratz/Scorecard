import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/cache/player_cache.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/ui/ball_colors.dart';
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(Stringify.score(innings.score),
                style: Theme.of(context).textTheme.displaySmall),
            Text(
                "${Stringify.ballCount(innings.numBalls, innings.rules.ballsPerOver)}/${innings.rules.ballsPerInnings / innings.rules.ballsPerOver}ov",
                style: Theme.of(context).textTheme.titleLarge)
          ],
        ),
      ),
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
    return Column(
      children: [for (final post in posts) _InningsPostWidget(post)],
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

    getPlayerName(String id) => playerCache.get(id).name.toUpperCase();

    return switch (post) {
      Ball() => ListTile(
          leading: wIndex(post.isWicket ? BallColors.wicket : null),
          title: Text(
              "${getPlayerName(post.bowlerId)} to ${getPlayerName(post.batterId)}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "${post.batterRuns} runs to ${getPlayerName(post.batterId)}"),
              if (post.isWicket)
                Text(
                    "${getPlayerName(post.wicket!.batterId)} (${Stringify.wicket(post.wicket, getPlayerName: getPlayerName)})")
            ],
          ),
          trailing:
              BallMini(post, isFirstBallOfOver: false, showPostIndex: false),
        ),
      BowlerRetire() => ListTile(
          title: Text(getPlayerName(post.bowlerId)),
          subtitle: const Text("Bowler has retired"),
          leading: wIndex(BallColors.wicket),
        ),
      NextBowler() => ListTile(
          title: Text(getPlayerName(post.nextId)),
          subtitle: const Text("Next bowler"),
          leading: wIndex(BallColors.post),
        ),
      BatterRetire() => ListTile(
          title: Text(getPlayerName(post.batterId)),
          subtitle: const Text("Batter has retired"),
          leading: wIndex(BallColors.wicket),
        ),
      NextBatter() => ListTile(
          title: Text(getPlayerName(post.nextId)),
          subtitle: const Text("Next batter"),
          leading: wIndex(BallColors.post),
        ),
      RunoutBeforeDelivery() => ListTile(
          title: Text(getPlayerName(post.batterId)),
          subtitle: const Text("Next bowler"),
          leading: wIndex(BallColors.wicket),
        ),
    };

    // return switch (post) {
    //   BowlerRetire() => Text(
    //       "${playerCache.get(post.bowlerId).name.toUpperCase()} has retired"),
    //   NextBowler() =>
    //     Text("${playerCache.get(post.nextId).name.toUpperCase()} to bowl"),
    //   BatterRetire() => Text(
    //       "${playerCache.get(post.batterId).name.toUpperCase()} has retired (${Stringify.wicket(null, retired: post.retired, getPlayerName: getPlayerName)})"),
    //   NextBatter() => Text(
    //       "The next batter in is ${playerCache.get(post.nextId).name.toUpperCase()}"),
    //   RunoutBeforeDelivery() => Text(
    //       "${playerCache.get(post.batterId).name.toUpperCase()} has been run-out!"),
    //   Ball() => Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //             "${playerCache.get(post.bowlerId).name.toUpperCase()} to ${playerCache.get(post.batterId).name.toUpperCase()}, ${post.runs} runs"),
    //         if (post.isWicket)
    //           Text(
    //               "Wicket: ${playerCache.get(post.bowlerId).name.toUpperCase()} (${Stringify.wicket(post.wicket!, getPlayerName: getPlayerName)})")
    //       ],
    //     ),
    // };
  }

  Widget wIndex(Color? color) => CircleAvatar(
        backgroundColor: color,
        child: Text(Stringify.postIndex(post.index)),
      );
}

class BallMini extends StatelessWidget {
  final Ball ball;
  final bool isFirstBallOfOver;
  final bool showPostIndex;
  const BallMini(this.ball,
      {super.key, required this.isFirstBallOfOver, this.showPostIndex = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: ShapeDecoration(
              shape: CircleBorder(
            side: BorderSide(color: _borderColor, width: 2.5),
          )),
          child: CircleAvatar(
            backgroundColor: _ballColor,
            radius: 18,
            child: Center(
                child: Text(
              ball.runs.toString(),
              // style: Theme.of(context).textTheme.bodyMedium,
            )),
          ),
        ),
        if (showPostIndex)
          Text(
            ball.index.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isFirstBallOfOver ? BallColors.newOver : null),
          )
      ],
    );
  }

  Color get _ballColor {
    if (ball.isBoundary && ball.runs == 4) {
      return BallColors.four;
    } else if (ball.isBoundary && ball.runs == 6) {
      return BallColors.six;
    } else if (ball.isWicket) {
      return BallColors.wicket;
    } else if (ball.battingExtra is Bye) {
      return BallColors.bye;
    } else if (ball.battingExtra is LegBye) {
      return BallColors.legBye;
    } else {
      return BallColors.post;
    }
  }

  Color get _borderColor => switch (ball.bowlingExtra) {
        NoBall() => BallColors.noBall,
        Wide() => BallColors.wide,
        // No border color if not an extra
        null => Colors.transparent,
      };
}
