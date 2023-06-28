import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

final recentBallsViewKey = GlobalKey<AnimatedListState>();

class RecentBallsPane extends StatelessWidget {
  const RecentBallsPane({super.key});

  @override
  Widget build(BuildContext context) {
    // final innings = context.read<InningsManager>();
    return Selector<InningsManager, int>(
      selector: (context, inningsManager) =>
          inningsManager.innings.balls.length,
      builder: (context, ballCount, child) => Card(
        surfaceTintColor: Colors.deepPurple,
        child: InkWell(
          onTap: ballCount == 0
              ? null
              : () => Utils.goToPage(
                  InningsTimelineScreen(
                    innings: context.read<InningsManager>().innings,
                  ),
                  context),
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 56,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ballCount,
                      itemBuilder: (context, index) {
                        final innings = context.read<InningsManager>().innings;
                        final ballsReversed = innings.balls.reversed.toList();
                        final currentBall = ballsReversed[index];
                        Color? ballIndexColor;
                        if (index < ballCount - 2) {
                          // At least two balls exist
                          final previousBall = ballsReversed[index + 1];
                          if (previousBall.overIndex != currentBall.overIndex) {
                            ballIndexColor = innings.bowlingTeam.color;
                          }
                        }
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: RecentBall(
                              ball: currentBall,
                              highlightBallIndex: ballIndexColor,
                            ));
                      },
                    ),
                  ),
                  // Expanded(
                  //   child: AnimatedList(
                  //     key: recentBallsViewKey,
                  //     reverse: true,
                  //     initialItemCount: ballCount,
                  //     scrollDirection: Axis.horizontal,
                  //     itemBuilder: (context, index, animation) {
                  //       final innings = context.read<InningsManager>().innings;
                  //       final ballsReversed = innings.balls.reversed.toList();
                  //       final currentBall = ballsReversed[index];
                  //       Color? ballIndexColor;
                  //       if (index > 0) {
                  //         // At least two balls exist
                  //         final previousBall = ballsReversed[index - 1];
                  //         if (previousBall.overIndex != currentBall.overIndex) {
                  //           ballIndexColor = innings.bowlingTeam.color;
                  //         }
                  //       }
                  //       return SlideTransition(
                  //         position: animation.drive(
                  //           Tween<Offset>(
                  //             begin: const Offset(1, 0),
                  //             end: const Offset(0, 0),
                  //           ),
                  //         ),
                  //         child: RecentBall(
                  //           ball: currentBall,
                  //           highlightBallIndex: ballIndexColor,
                  //         ),
                  //       );
                  //     },
                  //     },
                  //   ),
                  // ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.timeline),
                    disabledColor: Colors.white,
                    style: IconButton.styleFrom(
                      disabledBackgroundColor:
                          Colors.deepPurple.shade900.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecentBall extends StatelessWidget {
  final Ball ball;
  final Color? highlightBallIndex;
  const RecentBall({super.key, required this.ball, this.highlightBallIndex});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = ColorStyles.card;
    Color foregroundColor = Colors.white;

    if (ball.isWicket) {
      backgroundColor = ColorStyles.wicket;
      foregroundColor = Colors.white;
    } else if (ball.runsScored == 4) {
      backgroundColor = ColorStyles.ballFour;
      foregroundColor = Colors.white;
    } else if (ball.runsScored == 6) {
      backgroundColor = ColorStyles.ballSix;
      foregroundColor = Colors.white;
    }

    Color indicatorColor = backgroundColor;
    if (ball.bowlingExtra == BowlingExtra.noBall) {
      indicatorColor = ColorStyles.ballNoBall;
    } else if (ball.bowlingExtra == BowlingExtra.wide) {
      indicatorColor = ColorStyles.ballWide;
    } else if (ball.isEventOnly) {
      indicatorColor = ColorStyles.ballEvent;
    }

    return SizedBox(
      height: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            child: CircleAvatar(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              radius: 16,
              child: Text(ball.runsScored.toString()),
            ),
            radius: 18,
            backgroundColor: indicatorColor,
          ),
          Text(
            "${ball.overIndex}.${ball.ballIndex}",
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: highlightBallIndex),
          ),
        ],
      ),
    );
  }
}

class InningsTimelineScreen extends StatelessWidget {
  final Innings innings;

  const InningsTimelineScreen({super.key, required this.innings});

  @override
  Widget build(BuildContext context) {
    final balls = innings.balls;

    return TitledPage(
      title: Strings.inningsTimelineTitle,
      child: ListView.separated(
        itemCount: balls.length + 1,
        itemBuilder: (context, index) {
          if (index == balls.length) return const SizedBox();
          final ball = balls[balls.length - index - 1];
          return Row(
            children: [
              Material(
                textStyle: Theme.of(context).textTheme.bodySmall,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(DateFormat('h:m').format(ball.timestamp.toLocal())),
                    Text(DateFormat('a').format(ball.timestamp.toLocal())),
                  ],
                ),
              ),
              Expanded(
                child: GenericItemTile(
                  // contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  leading: RecentBall(ball: ball),
                  primaryHint: "${ball.bowler.name} to ${ball.batter.name}",
                  secondaryHint: ball.isWicket
                      ? " ${Strings.getWicketDescription(ball.wicket)}"
                      : " ",
                  trailing: null,
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) {
          if (index == balls.length - 1) {
            return _wOverHeader(balls.first);
          }
          if (index > 1) {
            final currentBall = balls[balls.length - index - 1];
            final previousBall = balls[balls.length - index];
            if (currentBall.overIndex != previousBall.overIndex) {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _wOverHeader(previousBall),
                ],
              );
            }
          }
          return const SizedBox();
        },
        // shrinkWrap: true,
        reverse: true,
      ),
    );
  }

  Widget _wOverHeader(Ball ball) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 36.0, bottom: 8),
          child: Chip(
            label: Text("Over ${ball.overIndex + 1}"),
            backgroundColor: innings.bowlingTeam.color,
            side: const BorderSide(),
          ),
        ),
      );
}
