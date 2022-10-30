import 'package:flutter/material.dart';
import '../../models/ball.dart';
import '../../models/wicket.dart';
import '../choosewicket.dart';
import '../../styles/strings.dart';
import '../../util/elements.dart';
import 'package:scorecard/util/utils.dart';

class BallSelector extends StatefulWidget {
  final Function(int runs, Wicket? wicket, BowlingExtra? bowlingExtra,
      BattingExtra? battingExtra) onSelectBall;
  const BallSelector({Key? key, required this.onSelectBall}) : super(key: key);

  @override
  State<BallSelector> createState() => _BallSelectorState();
}

class _BallSelectorState extends State<BallSelector> {
  _RunSelection _runSelection = _RunSelection();
  _SingleToggleSelection<BowlingExtra> _bowlingExtraSelection =
      _SingleToggleSelection(
          dataList: BowlingExtra.values, stringifier: Strings.getBowlingExtra);
  _SingleToggleSelection<BattingExtra> _battingExtraSelection =
      _SingleToggleSelection(
    dataList: BattingExtra.values,
    stringifier: Strings.getBattingExtra,
  );
  Wicket? _wicketSelection;

  // BattingExtra? _battingExtra;

  @override
  void didUpdateWidget(covariant BallSelector oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    _wicketSelection = null;

    _runSelection = _RunSelection();

    _bowlingExtraSelection = _SingleToggleSelection(
        dataList: BowlingExtra.values, stringifier: Strings.getBowlingExtra);

    _battingExtraSelection = _SingleToggleSelection(
      dataList: BattingExtra.values,
      stringifier: Strings.getBattingExtra,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _wExtraChooser(),
        const SizedBox(height: 16),
        _wWicketChooser(),
        const SizedBox(height: 16),
        _wRunChooser(),
        Elements.getConfirmButton(
            text: "Next", onPressed: _validate() ? _processBall : null)
      ],
    );
  }

  Widget _wExtraChooser() {
    return Row(children: [
      ToggleButtons(
          onPressed: (index) => setState(() {
                if (index == _battingExtraSelection.index) {
                  _battingExtraSelection.clear();
                } else {
                  _battingExtraSelection.index = index;
                }
              }),
          children: _battingExtraSelection.widgets,
          isSelected: _battingExtraSelection.booleans,
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          )),
      Spacer(),
      ToggleButtons(
          onPressed: (index) => setState(() {
                if (index == _bowlingExtraSelection.index) {
                  _bowlingExtraSelection.clear();
                } else {
                  _bowlingExtraSelection.index = index;
                }
              }),
          children: _bowlingExtraSelection.widgets,
          isSelected: _bowlingExtraSelection.booleans,
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          )),
    ]);
  }

  Widget _wRunChooser() {
    return Column(
      children: [
        Text("Runs"),
        SizedBox(height: 12),
        ToggleButtons(
          onPressed: (int index) => setState(() {
            // The button that is tapped is set to true, and the others to false.
            _runSelection.runIndex = index;
          }),
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
    widget.onSelectBall(
      _runSelection.runs,
      _wicketSelection,
      _bowlingExtraSelection.selection,
      _battingExtraSelection.selection,
    );
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

class _SingleToggleSelection<T> {
  final List<T> dataList;
  final String Function(T) stringifier;

  _SingleToggleSelection({required this.dataList, required this.stringifier});

  int index = -1;

  T? get selection => index == -1 ? null : dataList[index];

  List<Widget> get widgets =>
      dataList.map((data) => Text(stringifier(data))).toList();

  List<bool> get booleans => dataList.map((data) => data == selection).toList();

  void clear() {
    index = -1;
  }
}
