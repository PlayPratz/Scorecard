import 'package:flutter/material.dart';
import '../models/wicket.dart';
import 'titledpage.dart';
import 'widgets/genericitem.dart';
import 'widgets/itemlist.dart';
import '../styles/strings.dart';
import '../util/utils.dart';

class ChooseWicket extends StatefulWidget {
  const ChooseWicket({Key? key}) : super(key: key);

  @override
  State<ChooseWicket> createState() => _ChooseWicketState();
}

class _ChooseWicketState extends State<ChooseWicket> {
  @override
  Widget build(BuildContext context) {
    return TitledPage(
      title: Strings.chooseWicket,
      child: ItemList(
        itemList: Dismissal.values
            .map((dismissal) => GenericItem(
                  primaryHint: Strings.getDismissalName(dismissal),
                  secondaryHint: Strings.empty,
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
