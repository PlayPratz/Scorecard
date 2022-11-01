import 'package:flutter/material.dart';

// TODO Migrate PlayerTile and TeamTile/TeamDummyTile to this

class GenericItemTile extends StatefulWidget {
  final String primaryHint;
  final String secondaryHint;
  final Widget? leading;

  // final ItemSize? size;
  final Widget? trailing;

  final void Function()? onSelect;
  final void Function()? onLongPress;

  const GenericItemTile(
      {Key? key,
      required this.primaryHint,
      required this.secondaryHint,
      this.leading,
      this.onSelect,
      this.onLongPress,
      // this.size = ItemSize.normal,
      this.trailing = const Icon(Icons.chevron_right)})
      : super(key: key);

  @override
  State<GenericItemTile> createState() => _GenericItemTileState();
}

class _GenericItemTileState extends State<GenericItemTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      leading: SizedBox(
        height: widget.secondaryHint.isNotEmpty ? double.infinity : null,
        child: widget.leading,
      ),
      trailing: widget.trailing,
      onTap: widget.onSelect,
      onLongPress: widget.onLongPress,
    );
  }
}

enum ItemSize { normal, small }
