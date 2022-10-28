import 'package:flutter/material.dart';
import 'package:scorecard/models/wicket.dart';
import 'package:scorecard/screens/titledpage.dart';
import 'package:scorecard/screens/widgets/genericitem.dart';
import 'package:scorecard/screens/widgets/itemlist.dart';
import 'package:scorecard/styles/strings.dart';
import 'package:scorecard/util/utils.dart';

class ChooseWicket extends StatefulWidget {
  const ChooseWicket({Key? key}) : super(key: key);

  @override
  State<ChooseWicket> createState() => _ChooseWicketState();
}

class _ChooseWicketState extends State<ChooseWicket> {
  @override
  Widget build(BuildContext context) {
    return TitledPage(
      title: "Choose a wicket",
      child: ItemList(
        itemList: Dismissal.values
            .map((dismissal) => GenericItem(
                  primaryHint: Strings.getDismissalName(dismissal),
                  secondaryHint: "",
                  onSelect: () => _processDismissal(dismissal),
                ))
            .toList(),
      ),
    );
  }

  void _processDismissal(Dismissal dismissal) {
    Utils.goBack(context, dismissal);
  }
}
