import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/screens/templates/titled_page.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/styles/color_styles.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class RecentBallsPane extends StatelessWidget {
  final Innings innings;

  const RecentBallsPane({super.key, required this.innings});

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: innings.battingTeam.color,
      surfaceTintColor: innings.battingTeam.team.color,
      child: InkWell(
        onTap: innings.balls.isEmpty
            ? null
            : () => Utils.goToPage(
                InningsTimelineScreen(
                  innings: innings,
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
                    itemCount: innings.balls.length,
                    itemBuilder: (context, index) {
                      final ballsReversed = innings.balls.reversed.toList();
                      final currentBall = ballsReversed[index];
                      Color? ballIndexColor;
                      if (index < ballsReversed.length - 2) {
                        // At least two balls exist
                        final previousBall = ballsReversed[index + 1];
                        if (previousBall.overIndex != currentBall.overIndex) {
                          ballIndexColor =
                              innings.bowlingTeam.team.color.withOpacity(1);
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        child: RecentBall(
                          ball: currentBall,
                          highlightBallIndex: ballIndexColor,
                        ),
                      );
                    },
                  ),
                ),
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
        mainAxisAlignment: MainAxisAlignment.center,
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
    final overs = innings.overs.reversed.toList();
    return TitledPage(
      title: Strings.inningsTimelineTitle,
      child: ListView.builder(
        itemCount: overs.length,
        itemBuilder: (context, overIndex) => Card(
          color: innings.battingTeam.team.color.withOpacity(0.1),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                _wOverHeader(overs[overIndex]),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, ballIndex) {
                    final ball = overs[overIndex].balls[ballIndex];
                    return Row(
                      children: [
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.bodySmall!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(DateFormat('hh:mm')
                                  .format(ball.timestamp.toLocal())),
                              Text(DateFormat('a')
                                  .format(ball.timestamp.toLocal())),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GenericItemTile(
                            // contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            leading: RecentBall(ball: ball),
                            primaryHint: Strings.getDeliveryHeadline(ball),
                            secondaryHint: ball.isWicket
                                ? " ${Strings.getWicketDescription(ball.wicket)}"
                                : " ",
                            trailing: null,
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: overs[overIndex].balls.length,
                ),
              ],
            ),
          ),
        ),
        reverse: true,
      ),
    );
  }

  Widget _wOverHeader(Over over) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // const SizedBox(width: 40),
              Chip(
                label: Text("Over ${over.balls.first.overIndex + 1}"),
                backgroundColor:
                    innings.bowlingTeam.team.color.withOpacity(0.7),
                side: const BorderSide(color: Colors.white10, width: 0),
              ),
              const Spacer(),
              Text(Strings.getOverSummary(over))
            ],
          ),
        ),
      );
}
