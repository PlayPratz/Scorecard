import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/modules/quick_match/match_rules_model.dart';
import 'package:scorecard/screens/quick_match/play_quick_innings_screen.dart';
import 'package:scorecard/services/quick_match_service.dart';

class CreateQuickMatchScreen extends StatelessWidget {
  const CreateQuickMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = QuickMatchRulesController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's create a quick match!"),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              final rules = controller._deduceState();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Game Rules",
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    "These can't be edited once the match is created. Make sure everything is right!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  // Overs
                  const Center(child: Text("Overs")),
                  const SizedBox(height: 4),
                  _NumberChooser(
                      value: controller._oversPerInnings,
                      min: 1,
                      onChange: (x) => controller.oversPerInnings = x),
                  Center(
                      child: Text(
                    "${controller._maxBalls} balls",
                    style: Theme.of(context).textTheme.bodySmall,
                  )),
                  const SizedBox(height: 32),
                  // Balls Per Over
                  const Center(child: Text("Balls Per Over")),
                  const SizedBox(height: 4),
                  _NumberChooser(
                      value: rules.ballsPerOver,
                      min: 1,
                      onChange: (x) => controller.ballsPerOver = x),
                  const SizedBox(height: 32),
                  // No Ball Penalty
                  const Center(child: Text("No Ball Penalty")),
                  const SizedBox(height: 4),
                  _NumberChooser(
                      value: rules.noBallPenalty,
                      min: 1,
                      onChange: (x) => controller.noBallPenalty = x),
                  const SizedBox(height: 32),
                  // Wide Penalty
                  const Center(child: Text("Wide Penalty")),
                  const SizedBox(height: 4),
                  _NumberChooser(
                      value: rules.widePenalty,
                      min: 1,
                      onChange: (x) => controller.widePenalty = x),

                  const SizedBox(height: 64),
                ],
              );
            },
          )),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () =>
                scheduleMatch(context, rules: controller._deduceState()),
            label: const Text("Start"),
            icon: const Icon(Icons.sports_cricket),
          ),
        ],
      )),
    );
  }

  void scheduleMatch(BuildContext context,
      {required QuickMatchRules rules}) async {
    final match = await _service(context).createQuickMatch(rules);
    if (context.mounted) {
      final innings = await _service(context).createInnings(match);
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlayQuickInningsScreen(innings)));
      }
    }
  }

  QuickMatchService _service(BuildContext context) =>
      context.read<QuickMatchService>();
}

class _NumberChooser extends StatelessWidget {
  final int value;

  final int min;
  final int max;

  final void Function(int value) onChange;

  const _NumberChooser({
    super.key,
    required this.value,
    required this.onChange,
    this.min = 0,
    this.max = 256,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _changeButton(context, -10, "-10"),
        _changeButton(context, -5, "-5"),
        _changeButton(context, -1, "-1"),
        Expanded(
          child: Center(
            child: Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        _changeButton(context, 1, "+1"),
        _changeButton(context, 5, "+5"),
        _changeButton(context, 10, "+10"),
      ],
    );
  }

  Widget _changeButton(BuildContext context, int diff, String label) =>
      IconButton.filledTonal(
        onPressed: () => _changeBy(diff),
        icon: Text(label),
      );

  void _changeBy(int diff) {
    final newValue = value + diff;
    if (newValue < min) {
      onChange(min);
    } else if (newValue > max) {
      onChange(max);
    } else {
      onChange(newValue);
    }
  }
}

class QuickMatchRulesController with ChangeNotifier {
  int _ballsPerOver = 6;
  int _oversPerInnings = 4;
  int _noBallPenalty = 1;
  int _widePenalty = 1;
  bool _lastWicketBatter = false;
  bool _onlySingleBatter = false;

  int get _maxBalls => _ballsPerOver * _oversPerInnings;

  QuickMatchRules _deduceState() => QuickMatchRules(
        ballsPerOver: _ballsPerOver,
        maxBalls: _maxBalls,
        noBallPenalty: _noBallPenalty,
        widePenalty: _widePenalty,
        onlySingleBatter: _onlySingleBatter,
        lastWicketBatter: _lastWicketBatter,
      );

  void _dispatchState() {
    notifyListeners();
  }

  set oversPerInnings(int x) {
    _oversPerInnings = x;
    _dispatchState();
  }

  set ballsPerOver(int x) {
    _ballsPerOver = x;
    _dispatchState();
  }

  set noBallPenalty(int x) {
    _noBallPenalty = x;
    _dispatchState();
  }

  set widePenalty(int x) {
    _widePenalty = x;
    _dispatchState();
  }

  set lastWicketBatter(bool x) {
    _lastWicketBatter = x;
    _dispatchState();
  }

  set onlySingleBatter(bool x) {
    _onlySingleBatter = x;
    _lastWicketBatter = _lastWicketBatter || _onlySingleBatter;
    _dispatchState();
  }
}
