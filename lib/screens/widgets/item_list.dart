import 'package:flutter/material.dart';
import 'package:scorecard/screens/widgets/generic_item_tile.dart';
import 'package:scorecard/screens/widgets/elements.dart';
import 'package:scorecard/util/strings.dart';
import 'package:scorecard/util/utils.dart';

class ItemList<T> extends StatelessWidget {
  final List<Widget> itemList;
  final CreateItemEntry<T>? createItem;
  final Icon? trailingIcon;
  final bool alignToBottom;

  const ItemList({
    super.key,
    required this.itemList,
    this.createItem,
    this.trailingIcon = const Icon(Icons.chevron_right),
    this.alignToBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = alignToBottom ? itemList.reversed.toList() : itemList;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
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
              onSelect: () async {
                final item = await Utils.goToPage(createItem!.form, context);
                createItem!.onCreate(item);
              },
            ),
          ),
      ],
    );
  }
}

class CreateItemEntry<T> {
  final Widget form;
  final String string;
  final void Function(T item) onCreate;

  CreateItemEntry({
    required this.form,
    required this.string,
    required this.onCreate,
  });
}

class SelectableItemList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) onBuild;
  final Widget Function(T item)
      onBuildSelected; // TODO Add "isSelected" param to onBuild instead
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              if (controller.selectedItems.contains(item))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: onBuildSelected(item),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: onBuild(item),
                )
          ],
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
