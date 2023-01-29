import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/state_managers/innings_manager.dart';
import 'package:scorecard/styles/color_styles.dart';

class RecentBallsView extends StatelessWidget {
  const RecentBallsView({super.key});

  @override
  Widget build(BuildContext context) {
    final inningsManager = context.watch<InningsManager>();
    final listBallsInInnings = inningsManager.listBalls;
    return SizedBox(
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorStyles.highlight),
            // color: Colors.red,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: ListView.separated(
              reverse: true,
              scrollDirection: Axis.horizontal,
              itemCount: listBallsInInnings.length,
              itemBuilder: ((context, index) {
                Ball currentBall =
                    listBallsInInnings[listBallsInInnings.length - 1 - index];
                CircleAvatar currentBallWidget;
                if (currentBall.isWicket) {
                  currentBallWidget = CircleAvatar(
                    backgroundColor: ColorStyles.wicket,
                    foregroundColor: Colors.white,
                    radius: 18,
                    child: Text(currentBall.runsScored.toString()),
                  );
                } else if (currentBall.runsScored == 4) {
                  currentBallWidget = CircleAvatar(
                    backgroundColor: ColorStyles.ballFour,
                    foregroundColor: Colors.white,
                    radius: 18,
                    child: Text(currentBall.runsScored.toString()),
                  );
                } else if (currentBall.runsScored == 6) {
                  currentBallWidget = CircleAvatar(
                    backgroundColor: ColorStyles.ballSix,
                    foregroundColor: Colors.white,
                    radius: 18,
                    child: Text(currentBall.runsScored.toString()),
                  );
                } else {
                  currentBallWidget = CircleAvatar(
                      backgroundColor: ColorStyles.card,
                      foregroundColor: Colors.white,
                      radius: 18,
                      child: Text(currentBall.runsScored.toString()));
                }

                Color? indicatorColor = currentBallWidget.backgroundColor;

                if (currentBall.bowlingExtra == BowlingExtra.noBall) {
                  indicatorColor = ColorStyles.ballNoBall;
                } else if (currentBall.bowlingExtra == BowlingExtra.wide) {
                  indicatorColor = ColorStyles.ballWide;
                } else if (currentBall.shouldCount == false) {
                  indicatorColor = ColorStyles.ballEvent;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: CircleAvatar(
                    child: currentBallWidget,
                    radius: 20,
                    backgroundColor: indicatorColor,
                  ),
                );
              }),
              separatorBuilder: (context, index) {
                int realIndex = listBallsInInnings.length - 1 - index;
                if (realIndex + 1 < listBallsInInnings.length &&
                    listBallsInInnings[realIndex + 1].isFirstBallOfOver) {
                  return const SizedBox(
                    height: 32,
                    child: VerticalDivider(color: Colors.amber),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ));
  }
}
