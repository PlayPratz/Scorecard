import 'package:flutter/material.dart';

// TODO Migrate PlayerTile and TeamTile/TeamDummyTile to this

class GenericItemTile extends StatefulWidget {
  final String primaryHint;
  final String secondaryHint; // TODO Convert to nullable
  final Widget? leading;

  // final ItemSize? size;
  final Widget? trailing;

  final void Function()? onSelect;
  final void Function()? onLongPress;

  final Color? color;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? contentPadding;

  const GenericItemTile({
    Key? key,
    required this.primaryHint,
    this.secondaryHint = "",
    this.leading,
    this.onSelect,
    this.onLongPress,
    this.color,
    this.shape,
    this.contentPadding,
    // this.size = ItemSize.normal,
    this.trailing = const Icon(Icons.chevron_right),
  }) : super(key: key);

  @override
  State<GenericItemTile> createState() => _GenericItemTileState();
}

class _GenericItemTileState extends State<GenericItemTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(
          widget.primaryHint,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      subtitle: widget.secondaryHint.isNotEmpty
          ? Text(
              widget.secondaryHint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              // style: Theme.of(context).textTheme.bodyMedium,
            )
          : null,
      leading: SizedBox(
        height: widget.secondaryHint.isNotEmpty ? double.infinity : null,
        child: widget.leading,
      ),
      trailing: widget.trailing,
      onTap: widget.onSelect,
      onLongPress: widget.onLongPress,
      tileColor: widget.color,
      shape: widget.shape,
      contentPadding: widget.contentPadding,
    );
  }
}

enum ItemSize { normal, small }
