import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/screens/common/ball_widgets.dart';
import 'package:scorecard/ui/ball_colors.dart';

class RecentBallsSection extends StatelessWidget {
  final List<Ball> reversedBalls;

  final void Function()? onOpenTimeline;

  RecentBallsSection(List<Ball> balls,
      {super.key, required this.onOpenTimeline})
      : reversedBalls = balls.reversed.toList();

  @override
  Widget build(BuildContext context) {
    // final reversedBalls = balls.reversed.toList();
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(32))),
      child: SizedBox(
        height: 56, // TODO
        child: Row(
          children: [
            IconButton.filled(
                onPressed: onOpenTimeline, icon: const Icon(Icons.history)),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics:
                    const NeverScrollableScrollPhysics(), //TODO change to Row?
                reverse: true,
                itemCount: reversedBalls.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: BallMini(
                    reversedBalls[index],
                    isFirstBallOfOver: _isFirstBallOfOver(index),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFirstBallOfOver(int index) {
    if (index == reversedBalls.length - 1) return true;
    if (reversedBalls[index].index.over !=
        reversedBalls[index + 1].index.over) {
      return true;
    }

    return false;
  }
}
