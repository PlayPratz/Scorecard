import 'package:flutter/material.dart';
import 'package:scorecard/util/elements.dart';
import 'package:scorecard/util/utils.dart';

class ItemList extends StatelessWidget {
  final List<Widget> itemList;
  final Widget? createItemPage;
  final String? createItemString;
  final Icon? trailingIcon;

  const ItemList({
    Key? key,
    required this.itemList,
    this.createItemPage,
    this.createItemString,
    this.trailingIcon = const Icon(Icons.chevron_right),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        createItemPage != null && createItemString != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                    title: Text(createItemString!),
                    leading: Elements.addIcon,
                    trailing: trailingIcon,
                    onTap: () {
                      Utils.goToPage(createItemPage!, context);
                    }),
              )
            : Container(),
        ...itemList
      ],
    );
  }
}
