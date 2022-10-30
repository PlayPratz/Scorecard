import 'package:flutter/material.dart';

// TODO Migrate PlayerTile and TeamTile/TeamDummyTile to this

class GenericItem extends StatefulWidget {
  final String primaryHint;
  final String secondaryHint;
  final Widget? leading;
  final Function? onSelect;
  final GenericItemVariant variant;
  final Widget? trailing;

  const GenericItem(
      {Key? key,
      required this.primaryHint,
      required this.secondaryHint,
      this.leading,
      this.onSelect,
      this.variant = GenericItemVariant.normal,
      this.trailing = const Icon(Icons.chevron_right)})
      : super(key: key);

  @override
  State<GenericItem> createState() => _GenericItemState();
}

class _GenericItemState extends State<GenericItem> {
  @override
  Widget build(BuildContext context) {
    final genericTile = ListTile(
      // TODO Minleadingwidth?
      minLeadingWidth: 0,
      title: FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(
            widget.primaryHint,
          )),
      subtitle: Text(
        widget.secondaryHint,
        maxLines: 1,
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

enum GenericItemVariant { normal, small }
