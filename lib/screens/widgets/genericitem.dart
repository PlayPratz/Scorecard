import 'package:flutter/material.dart';

// TODO Migrate PlayerTile and TeamTile/TeamDummyTile to this

class GenericItem extends StatefulWidget {
  final String primaryHint;
  final String secondaryHint;
  final Icon? leading;
  final Function? onSelect;

  const GenericItem({
    Key? key,
    required this.primaryHint,
    required this.secondaryHint,
    this.leading,
    this.onSelect,
  }) : super(key: key);

  @override
  State<GenericItem> createState() => _GenericItemState();
}

class _GenericItemState extends State<GenericItem> {
  @override
  Widget build(BuildContext context) {
    final teamDummyTile = ListTile(
      title: Text(widget.primaryHint),
      subtitle: Text(widget.secondaryHint),
      leading: widget.leading,
      trailing: const Icon(Icons.chevron_right),
    );

    if (widget.onSelect == null) {
      return teamDummyTile;
    }

    return InkWell(
        onTap: () {
          widget.onSelect!();
        },
        child: teamDummyTile);
  }
}
