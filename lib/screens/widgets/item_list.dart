import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/util/strings.dart';

import '../../util/elements.dart';
import '../../util/utils.dart';

class ItemList extends StatelessWidget {
  final List<Widget> itemList;
  final CreateItemEntry? createItem;
  final Icon? trailingIcon;
  final bool alignToBottom;

  const ItemList({
    Key? key,
    required this.itemList,
    this.createItem,
    this.trailingIcon = const Icon(Icons.chevron_right),
    this.alignToBottom = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = alignToBottom ? itemList.reversed.toList() : itemList;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => items[index],
            separatorBuilder: (context, index) => const Divider(
              indent: 8,
              endIndent: 8,
              height: 8,
              thickness: 0,
            ),
            itemCount: itemList.length,
            reverse: alignToBottom,
          ),
        ),
        if (createItem != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
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
          ),
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

class SelectableItemList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) onBuild;
  final Widget Function(T item) onBuildSelected;
  final SelectableItemController<T> controller;

  const SelectableItemList({
    super.key,
    required this.items,
    required this.controller,
    required this.onBuild,
    required this.onBuildSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return ListView.builder(
          itemBuilder: (context, index) {
            if (controller.selectedItems.contains(items[index])) {
              return onBuildSelected(items[index]);
            }
            return onBuild(items[index]);
          },
          itemCount: items.length,
        );
      },
    );
  }
}

class SelectableItemController<T> with ChangeNotifier {
  final int? maxItems;

  SelectableItemController({this.maxItems});

  final List<T> selectedItems = [];

  void selectItem(T item) {
    if (selectedItems.contains(item)) {
      // Remove Item
      selectedItems.remove(item);
    } else {
      // Check if there is space
      if (maxItems != null && selectedItems.length >= maxItems!) {
        // Remove the oldest item
        selectedItems.removeAt(0);
      }
      // Add item
      selectedItems.add(item);
    }
    notifyListeners();
  }
}
