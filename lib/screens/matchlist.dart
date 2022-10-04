import 'package:flutter/material.dart';
import 'package:scorecard/screens/creatematch.dart';
import 'package:scorecard/screens/widgets/itemlist.dart';
import 'package:scorecard/screens/widgets/matchtile.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/utils.dart';

class MatchList extends StatelessWidget {
  MatchList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
      itemList: getMatchList(),
      createItemPage: CreateMatchForm(),
      createItemString: Strings.matchlistCreateNewMatch,
    );
  }

  List<Widget> getMatchList() {
    return Utils.getAllMatches()
        .map((match) => MatchTile(match: match))
        .toList();
  }
}
