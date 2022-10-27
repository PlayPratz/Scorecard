import 'package:flutter/material.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/choosewicket.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class BallSelector extends StatefulWidget {
  const BallSelector({Key? key}) : super(key: key);

  @override
  State<BallSelector> createState() => _BallSelectorState();
}

class _BallSelectorState extends State<BallSelector> {
  final _RunSelection _runSelection = _RunSelection();
  Wicket? _wicket;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _wRunChooser(),
        const Spacer(),
        _wWicketChooser(),
      ],
    );
  }

  Widget _wRunChooser() {
    return ToggleButtons(
      onPressed: (int index) {
        setState(() {
          // The button that is tapped is set to true, and the others to false.
          _runSelection.runs = index;
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
    );
  }

  Widget _wWicketChooser() {
    return _wicket == null
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
            onTap: () => Utils.goToPage(const ChooseWicket(), context),
          )
        : Container();
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
  set runs(int index) => _selectedRuns = runList[index];
}
