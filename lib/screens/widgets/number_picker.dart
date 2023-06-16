import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget {
  final int min;
  final int max;
  final void Function(int value)? onChange;
  const NumberPicker({super.key, this.min = 0, this.max = 128, this.onChange});

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  int number = 0;
  @override
  void initState() {
    super.initState();
    number = widget.min;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onChange != null) widget.onChange!(number);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onLongPress: () => setState(() {
            number = widget.min;
          }),
          child: IconButton(
              onPressed: () => setState(() {
                    if (number > widget.min) number--;
                  }),
              icon: const Icon(
                Icons.remove_circle,
                color: Colors.redAccent,
              )),
        ),
        // PageView(),
        Text(
          number.toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
        InkWell(
          onLongPress: () => setState(() {
            number = widget.max;
          }),
          child: IconButton(
              onPressed: () => setState(() {
                    if (number < widget.max) number++;
                  }),
              icon: const Icon(
                Icons.add_circle,
                color: Colors.greenAccent,
              )),
        ),
      ],
    );
  }
}
