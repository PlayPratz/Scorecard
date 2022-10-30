import 'package:flutter/material.dart';
import 'creatematch.dart';
import 'widgets/itemlist.dart';
import 'widgets/matchtile.dart';
import '../styles/strings.dart';
import '../util/utils.dart';

class MatchList extends StatelessWidget {
  MatchList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemList(
        itemList: getMatchList(),
        createItem: CreateItemEntry(
          page: const CreateMatchForm(),
          string: Strings.matchlistCreateNewMatch,
        ));
  }

  List<Widget> getMatchList() {
    return Utils.getAllMatches()
        .map((match) => MatchTile(match: match))
        .toList();
  }
}
