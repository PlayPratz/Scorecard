import 'package:flutter/material.dart';
import 'package:scorecard/modules/cricket_match/models/innings_model.dart';
import 'package:scorecard/ui/ball_colors.dart';

class RecentBallsSection extends StatelessWidget {
  final List<Ball> balls;

  const RecentBallsSection(this.balls, {super.key});

  @override
  Widget build(BuildContext context) {
    final reversedBalls = balls.reversed.toList();
    return Card(
      child: SizedBox(
        height: 64, // TODO
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(), //TODO change to Row?
          reverse: true,
          itemCount: balls.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _BallPreview(reversedBalls[index]),
          ),
        ),
      ),
    );
  }
}

class _BallPreview extends StatelessWidget {
  final Ball ball;
  const _BallPreview(this.ball, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: ShapeDecoration(
            shape: CircleBorder(side: BorderSide(color: borderColor)),
            color: ballColor,
          ),
          height: 24,
          child: Text(ball.runs.toString()),
        ),
        const SizedBox(height: 4),
        Text(
          ball.index.toString(),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: BallColors.newOver),
        )
      ],
    );
  }

  Color get ballColor {
    if (ball.runs == 4) {
      return BallColors.four;
    } else if (ball.runs == 6) {
      return BallColors.six;
    } else {
      return BallColors.post;
    }
  }

  Color get borderColor => switch (ball.bowlingExtra) {
        BowlingExtra.noBall => BallColors.noBall,
        BowlingExtra.wide => BallColors.wide,
        // No border color if not an extra
        null => Colors.transparent,
      };
}
