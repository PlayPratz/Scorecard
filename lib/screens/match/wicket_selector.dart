import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/screens/player/player_list.dart';
import 'package:scorecard/screens/player/player_tile.dart';
import 'package:scorecard/util/elements.dart';
import '../../models/wicket.dart';
import '../templates/titled_page.dart';
import '../widgets/generic_item_tile.dart';
import '../templates/item_list.dart';
import '../../util/strings.dart';
import '../../util/utils.dart';

class WicketSelector extends StatefulWidget {
  final Player bowler;
  final Player striker;
  final Team battingTeam;
  final Team fieldingTeam;
  const WicketSelector({
    Key? key,
    required this.bowler,
    required this.striker,
    required this.battingTeam,
    required this.fieldingTeam,
  }) : super(key: key);

  @override
  State<WicketSelector> createState() => _WicketSelectorState();
}

class _WicketSelectorState extends State<WicketSelector> {
  Dismissal? _dismissal;
  Player? _fielder;
  Player? _batter;

  bool _isDimissalSelected = false;
  bool _isBatterSelected = false;
  bool _isFielderSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _batter = widget.striker;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> options = [];

    _isDimissalSelected = false;
    _isBatterSelected = false;
    _isFielderSelected = false;

    if (_dismissal == null) {
      options.add(_wDismissalChooser());
    } else {
      _isDimissalSelected = true;
      options.add(_wDismissalViewer());

      if (_requiresBatter(_dismissal)) {
        if (_batter == null) {
          options.add(_wBatterChooser());
        } else {
          _isBatterSelected = true;
          options.add(PlayerTile(
            _batter!,
            onSelect: (_) => _onSelectBatter(),
          ));
        }
      } else {
        _isBatterSelected = true;
      }

      if (_requiresFielder(_dismissal)) {
        if (_fielder == null) {
          options.add(_wFielderChooser());
        } else {
          _isFielderSelected = true;
          options
              .add(PlayerTile(_fielder!, onSelect: (_) => _onSelectFielder()));
        }
      } else {
        _isFielderSelected = true;
      }
    }

    options.addAll([
      const Spacer(),
      Elements.getConfirmButton(
          text: "Add Wicket", onPressed: canAddWicket ? _processWicket : null)
    ]);

    return TitledPage(
      title: Strings.chooseWicket,
      child: Column(
        children: options,
      ),
    );
  }

  void _processWicket() async {
    switch (_dismissal) {
      case Dismissal.retired:
        _sendWicketToParent(Wicket.runout(batter: _batter!, fielder: _fielder));
        return;

      case Dismissal.runout:
        _sendWicketToParent(Wicket.runout(batter: _batter!, fielder: _fielder));
        return;

      case Dismissal.caught:
        _sendWicketToParent(Wicket.caught(
            batter: widget.striker, bowler: widget.bowler, fielder: _fielder));
        return;
      case Dismissal.stumped:
        _sendWicketToParent(Wicket.stumped(
            batter: widget.striker, bowler: widget.bowler, fielder: _fielder));
        return;

      case Dismissal.hitWicket:
        _sendWicketToParent(
            Wicket.hitWicket(batter: widget.striker, bowler: widget.bowler));
        return;
      case Dismissal.lbw:
        _sendWicketToParent(
            Wicket.lbw(batter: widget.striker, bowler: widget.bowler));
        return;
      case Dismissal.bowled:
      default:
        _sendWicketToParent(
            Wicket.bowled(batter: widget.striker, bowler: widget.bowler));
        return;
    }
  }

  void _sendWicketToParent(Wicket wicket) {
    Utils.goBack(context, wicket);
  }

  bool get canAddWicket =>
      _isDimissalSelected && _isFielderSelected && _isBatterSelected;

  Future<Player?> _chooseFielder(BuildContext context) async {
    return await Utils.goToPage(
      TitledPage(
        title: "Choose Fielder",
        child: PlayerList(
          playerList: widget.fieldingTeam.squad,
          showAddButton: false,
          onSelectPlayer: (player) => Utils.goBack(context, player),
        ),
      ),
      context,
    );
  }

  bool _requiresBatter(Dismissal? dismissal) {
    if (dismissal == Dismissal.runout || dismissal == Dismissal.retired) {
      // Wickets where non-striker can get run-out
      return true;
    }
    return false;
  }

  bool _requiresFielder(Dismissal? dismissal) {
    if (dismissal == Dismissal.caught ||
        dismissal == Dismissal.runout ||
        dismissal == Dismissal.stumped) {
      return true;
    }
    return false;
  }

  Widget _wDismissalViewer() => GenericItemTile(
        primaryHint: Strings.getDismissalName(_dismissal!),
        secondaryHint: Strings.empty,
        onSelect: _onSelectDismissal,
      );

  Widget _wDismissalChooser() => GenericItemTile(
        primaryHint: "Select a Dismissal",
        secondaryHint: "How did the batter get out?",
        onSelect: _onSelectDismissal,
      );

  void _onSelectDismissal() => Utils.goToPage(
      TitledPage(
        title: "Select a Dismissal",
        child: ItemList(itemList: [
          ...Dismissal.values.map(
            (dismissal) => GenericItemTile(
              primaryHint: Strings.getDismissalName(dismissal),
              secondaryHint: Strings.empty,
              onSelect: () => setState(() {
                _dismissal = dismissal;
                _batter = null;
                _fielder = null;
                Utils.goBack(context);
              }),
            ),
          )
        ]),
      ),
      context);

  Widget _wBatterChooser() => GenericItemTile(
        primaryHint: "Select a Batter",
        secondaryHint: "Which batter got out?",
        onSelect: _onSelectBatter,
      );

  void _onSelectBatter() => Utils.goToPage(
      TitledPage(
          title: Strings.choosePlayer,
          child: PlayerList(
            playerList: widget.battingTeam.squad,
            showAddButton: false,
            onSelectPlayer: (batter) => setState(() {
              _batter = batter;
              Utils.goBack(context);
            }),
          )),
      context);

  Widget _wFielderChooser() => GenericItemTile(
      primaryHint: "Select a Fielder",
      secondaryHint: "Which Fielder gave their hand?",
      onSelect: _onSelectFielder);

  void _onSelectFielder() => Utils.goToPage(
      TitledPage(
          title: Strings.choosePlayer,
          child: PlayerList(
            playerList: widget.fieldingTeam.squad,
            showAddButton: false,
            onSelectPlayer: (fielder) => setState(() {
              _fielder = fielder;
              Utils.goBack(context);
            }),
          )),
      context);
}
