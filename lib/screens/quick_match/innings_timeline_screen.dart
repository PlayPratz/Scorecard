import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/quick_match/post_ball_and_extras_model.dart';
import 'package:scorecard/modules/quick_match/quick_match_model.dart';
import 'package:scorecard/screens/quick_match/scorecard_screen.dart';
import 'package:scorecard/services/quick_match_service.dart';
import 'package:scorecard/ui/ball_colors.dart';
import 'package:scorecard/ui/stringify.dart';

class InningsTimelineScreen extends StatelessWidget {
  final QuickInnings innings;

  const InningsTimelineScreen(this.innings, {super.key});

  @override
  Widget build(BuildContext context) {
    final oversFuture = context.read<QuickMatchService>().getOvers(innings);
    return Scaffold(
      appBar: AppBar(
        title: Text(Stringify.quickInningsHeading(innings.inningsNumber)),
      ),
      body: FutureBuilder(
        future: oversFuture,
        builder: (context, asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final overs = asyncSnapshot.data!;
          return ListView.builder(
            itemCount: overs.length,
            reverse: true,
            itemBuilder: (context, index) {
              final overIndex = overs.length - index;
              final over = overs[overIndex]!;
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!innings.isSuperOver)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Over $overIndex",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              Stringify.score(over.scoreIn),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    _OverView(over),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              Stringify.score(innings.score),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Text(
              "${Stringify.ballCount(innings.balls, innings.ballsPerOver)}/${innings.ballLimit / innings.ballsPerOver}ov",
              style: Theme.of(context).textTheme.titleLarge,
            ),
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

class _OverView extends StatelessWidget {
  final Over over;
  const _OverView(this.over);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final post in over.posts) _InningsPostWidget(post)],
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

    const contentPadding = EdgeInsets.symmetric(horizontal: 8.0);
    final titleTextStyle = Theme.of(context).textTheme.bodyMedium;
    final subtitleTextStyle = Theme.of(context).textTheme.bodySmall;
    const minTileHeight = 64.0;

    return switch (post) {
      Ball() => ListTile(
        title: Text(
          "${getPlayerName(post.bowlerId!)} to ${getPlayerName(post.batterId!)}",
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${post.batterRuns} runs to ${getPlayerName(post.batterId!)}"),
            if (post.isWicket)
              Text(
                "${getPlayerName(post.wicket!.batterId)} (${Stringify.wicket(post.wicket, getPlayerName: getPlayerName)})",
              ),
          ],
        ),
        leading: wIndex(context, null),
        trailing: BallMini(
          post,
          isFirstBallOfOver: false,
          showPostIndex: false,
        ),
        titleTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        contentPadding: contentPadding,
        minTileHeight: minTileHeight,
      ),
      BowlerRetire() => ListTile(
        title: Text(getPlayerName(post.bowlerId!)),
        subtitle: const Text("Bowler has retired"),
        leading: wIndex(context, BallColors.wicket),
        titleTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        contentPadding: contentPadding,
        minTileHeight: minTileHeight,
      ),
      NextBowler() => ListTile(
        title: Text(getPlayerName(post.nextId)),
        subtitle: const Text("Next bowler"),
        leading: wIndex(context, BallColors.post),
        titleTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        contentPadding: contentPadding,
        minTileHeight: minTileHeight,
      ),
      BatterRetire() => ListTile(
        title: Text(getPlayerName(post.retired.batterId)),
        subtitle: const Text("Batter has retired"),
        leading: wIndex(context, BallColors.wicket),
        titleTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        contentPadding: contentPadding,
        minTileHeight: minTileHeight,
      ),
      NextBatter() => ListTile(
        title: Text(getPlayerName(post.nextId)),
        subtitle: const Text("Next batter"),
        leading: wIndex(context, BallColors.post),
        titleTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        contentPadding: contentPadding,
        minTileHeight: minTileHeight,
      ),
      WicketBeforeDelivery() => ListTile(
        title: Text(getPlayerName(post.batterId!)),
        subtitle: const Text("Run out before Delivery"),
        leading: wIndex(context, BallColors.wicket),
        titleTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        contentPadding: contentPadding,
        minTileHeight: minTileHeight,
      ),
      Penalty() => ListTile(
        title: Text("${post.penalties} runs"),
        subtitle: const Text("Penalty"),
        leading: wIndex(context, BallColors.noBall),
        titleTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        contentPadding: contentPadding,
        minTileHeight: minTileHeight,
      ),
      Break() => throw UnimplementedError(),
    };
  }

  Widget wIndex(BuildContext context, Color? color) => CircleAvatar(
    radius: 18,
    backgroundColor: color,
    child: Text(
      Stringify.postIndex(post.index),
      style: Theme.of(context).textTheme.labelSmall,
    ),
  );
}

class BallMini extends StatelessWidget {
  final Ball ball;
  final bool isFirstBallOfOver;
  final bool showPostIndex;
  const BallMini(
    this.ball, {
    super.key,
    required this.isFirstBallOfOver,
    this.showPostIndex = true,
  });

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
            ),
          ),
          child: CircleAvatar(
            backgroundColor: _ballColor,
            radius: 18,
            child: Center(
              child: Text(
                ball.totalRuns.toString(),
                // style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        if (showPostIndex)
          Text(
            ball.index.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isFirstBallOfOver ? BallColors.newOver : null,
            ),
          ),
      ],
    );
  }

  Color? get _ballColor {
    if (ball.isBoundary && ball.totalRuns == 4) {
      return BallColors.four;
    } else if (ball.isBoundary && ball.totalRuns == 6) {
      return BallColors.six;
    } else if (ball.isWicket) {
      return BallColors.wicket;
    } else if (ball.battingExtra is Bye) {
      return BallColors.bye;
    } else if (ball.battingExtra is LegBye) {
      return BallColors.legBye;
    } else {
      return null;
    }
  }

  Color get _borderColor => switch (ball.bowlingExtra) {
    NoBall() => BallColors.noBall,
    Wide() => BallColors.wide,
    // No border color if not an extra
    null => Colors.transparent,
  };
}
