import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/util/strings.dart';

import '../../util/elements.dart';
import '../../util/utils.dart';

class ItemList extends StatelessWidget {
  final List<Widget> itemList;
  final CreateItemEntry? createItem;
  final Icon? trailingIcon;

  const ItemList({
    Key? key,
    required this.itemList,
    this.createItem,
    this.trailingIcon = const Icon(Icons.chevron_right),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      // padding: const EdgeInsets.symmetric(horizontal: 12),

      children: [
        createItem != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GenericItemTile(
                    primaryHint: createItem!.string,
                    secondaryHint: Strings.empty,
                    leading: Elements.addIcon,
                    trailing: trailingIcon,
                    onSelect: () {
                      if (createItem!.onCreateItem != null) {
                        Utils.goToPage(createItem!.page, context)
                            .then((item) => createItem!.onCreateItem!(item));
                      } else {
                        Utils.goToPage(createItem!.page, context);
                      }
                    }),
              )
            : Container(),
        ...itemList
      ],
    );
  }
}

class CreateItemEntry {
  final Widget page;
  final String string;
  final void Function(dynamic item)? onCreateItem;

  CreateItemEntry(
      {required this.page, required this.string, this.onCreateItem});
}
