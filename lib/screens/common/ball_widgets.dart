import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/ui/ball_colors.dart';

class BallMini extends StatelessWidget {
  final Ball ball;
  final bool isFirstBallOfOver;
  const BallMini(this.ball, {super.key, required this.isFirstBallOfOver});

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
            radius: 14,
            child: Center(
                child: Text(
              ball.runsScoredByBatter.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            )),
          ),
        ),
        Text(
          ball.index.toString(),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: isFirstBallOfOver ? BallColors.newOver : null),
        )
      ],
    );
  }

  Color get _ballColor {
    if (ball.runs == 4) {
      return BallColors.four;
    } else if (ball.runs == 6) {
      return BallColors.six;
    } else if (ball.isWicket) {
      return BallColors.wicket;
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
