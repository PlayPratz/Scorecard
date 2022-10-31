import 'package:flutter/material.dart';

// TODO Migrate PlayerTile and TeamTile/TeamDummyTile to this

class GenericItemTile extends StatefulWidget {
  final String primaryHint;
  final String secondaryHint;
  final Widget? leading;
  final Function? onSelect;
  final ItemSize? size;
  final Widget? trailing;

  const GenericItemTile(
      {Key? key,
      required this.primaryHint,
      required this.secondaryHint,
      this.leading,
      this.onSelect,
      this.size = ItemSize.normal,
      this.trailing = const Icon(Icons.chevron_right)})
      : super(key: key);

  @override
  State<GenericItemTile> createState() => _GenericItemTileState();
}

class _GenericItemTileState extends State<GenericItemTile> {
  @override
  Widget build(BuildContext context) {
    final genericTile = ListTile(
      // TODO Minleadingwidth?
      // minLeadingWidth: 32,
      title: FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(
            widget.primaryHint,
          )),
      subtitle: Text(
        widget.secondaryHint,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      leading: widget.leading,
      trailing: widget.trailing,
    );

    if (widget.onSelect == null) {
      return genericTile;
    }

    return InkWell(
        onTap: () {
          widget.onSelect!();
        },
        child: genericTile);
  }
}

enum ItemSize { normal, small }
