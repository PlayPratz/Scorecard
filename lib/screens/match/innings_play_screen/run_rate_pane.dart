import 'package:flutter/material.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/util/strings.dart';

class RunRatePane extends StatelessWidget {
  final RunRatePaneStateController stateController;

  final bool showChaseRequirement;
  final Innings innings;

  const RunRatePane({
    super.key,
    required this.stateController,
    required this.showChaseRequirement,
    required this.innings,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stateController,
      builder: (context, _) => Row(
        children: [
          Expanded(
            child: stateController.showRequiredRunRate
                ? _wRunRateBox(
                    context: context,
                    color: innings.battingTeam.team.color,
                    heading: Strings.scoreRRR,
                    value: innings.requiredRunRate.toStringAsFixed(2),
                    onTap: _handleToggle)
                : _wRunRateBox(
                    context: context,
                    color: innings.battingTeam.team.color,
                    heading: Strings.scoreCRR,
                    value: innings.currentRunRate.toStringAsFixed(2),
                    onTap: showChaseRequirement ? _handleToggle : null),
          ),
          if (showChaseRequirement) ...<Widget>[
            Expanded(
              child: _wRunRateBox(
                  context: context,
                  color: innings.battingTeam.team.color,
                  heading: Strings.scoreRequire,
                  value: innings.requiredRuns.toString()),
            ),
            Expanded(
              child: _wRunRateBox(
                  context: context,
                  color: innings.bowlingTeam.team.color,
                  heading: Strings.scoreBalls,
                  value: innings.ballsLeft.toString()),
            ),
          ] else
            Expanded(
              child: _wRunRateBox(
                  context: context,
                  color: innings.battingTeam.team.color,
                  heading: Strings.scoreProjected,
                  value: innings.projectedRuns.toString()),
            ),
        ],
      ),
    );
  }

  Card _wRunRateBox({
    required BuildContext context,
    required Color color,
    required String heading,
    required String value,
    VoidCallback? onTap,
  }) =>
      Card(
        elevation: 2,
        color: color.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                FittedBox(
                  child: Text(
                    heading.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                )
              ],
            ),
          ),
        ),
      );

  void _handleToggle() {
    if (showChaseRequirement == true) {
      stateController.toggleRequiredRunRate();
    }
  }
}

class RunRatePaneStateController with ChangeNotifier {
  bool _showRequiredRunRate = false;
  bool get showRequiredRunRate => _showRequiredRunRate;

  void toggleRequiredRunRate() {
    _showRequiredRunRate = !_showRequiredRunRate;
    notifyListeners();
  }
}
