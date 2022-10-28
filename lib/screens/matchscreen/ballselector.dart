import 'package:flutter/material.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/choosewicket.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class BallSelector extends StatefulWidget {
  final Function(int runs, Wicket? _wicket) onSelectBall;
  const BallSelector({Key? key, required this.onSelectBall}) : super(key: key);

  @override
  State<BallSelector> createState() => _BallSelectorState();
}

class _BallSelectorState extends State<BallSelector> {
  final _RunSelection _runSelection = _RunSelection();
  Wicket? _wicketSelection;

  BowlingExtra? _bowlingExtra;
  BattingExtra? _battingExtra;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _wExtraChooser(),
        _wWicketChooser(),
        SizedBox(height: 16),
        _wRunChooser(),
        Elements.getConfirmButton(
            text: "Next", onPressed: _validate() ? _processBall : null)
      ],
    );
  }

  Widget _wExtraChooser() {
    // return Row(
    //   children: [
    //     DropdownButton(
    //       // value: ,
    //       // hint: Text("Bowling Extra"),
    //       items: [1, 2,],
    //       onChanged: (selectedItem) {},
    //     )
    //   ],
    // );

    return Container();
  }

  Widget _wRunChooser() {
    return Column(
      children: [
        Text("Runs"),
        SizedBox(height: 12),
        ToggleButtons(
          onPressed: (int index) {
            setState(() {
              // The button that is tapped is set to true, and the others to false.
              _runSelection.runIndex = index;
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          selectedBorderColor: Colors.green[700],
          selectedColor: Colors.white,
          fillColor: Colors.green[200],
          // color: Colors.red[400],
          // constraints: const BoxConstraints(
          //   minHeight: 40.0,
          //   minWidth: 80.0,
          // ),
          isSelected: _runSelection.booleans,
          children: _runSelection.widgets,
        ),
      ],
    );
  }

  Widget _wWicketChooser() {
    return _wicketSelection == null
        ? ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.sports_cricket),
            ),
            title: const Text(Strings.addWicket),
            isThreeLine: true,
            subtitle: const Text(
              Strings.addWicketHint,
            ),
            trailing: Elements.forwardIcon,
            onTap: _processWicket,
          )
        : Container();
  }

  Future<void> _processWicket() async {
    Dismissal? selectedDimissal =
        await Utils.goToPage(const ChooseWicket(), context);

    // switch (selectedDimissal) {
    //   case Dismissal.bowled:
    //     _wicketSelection = BowledWicket(_striker, _bowler);
    //     return;

    //   case Dismissal.caught:
    //   case Dismissal.stumped:
    //     _wicketSelection = CatchWicket(_striker, _bowler, catcher)
    // }
  }

  void _processBall() {
    widget.onSelectBall(_runSelection.runs, _wicketSelection);
  }

  bool _validate() {
    return true;
  }
}

class _RunSelection {
  static const List<int> runList = [0, 1, 2, 3, 4, 5, 6];
  int _selectedRuns = 0;

  List<bool> get booleans =>
      runList.map((run) => run == _selectedRuns).toList();

  List<Widget> get widgets =>
      runList.map((run) => Text(Strings.getRunText(run))).toList();

  int get runs => _selectedRuns;
  set runIndex(int index) => _selectedRuns = runList[index];
}
