import 'package:flutter/material.dart';
import 'package:scorecard/styles/colorstyles.dart';

class Elements {
  Elements._();

  static const Icon addIcon = Icon(
    Icons.add_circle,
    color: ColorStyles.currentlyBatting,
  );

  static const Icon removeIcon = Icon(
    Icons.remove_circle,
    color: Colors.redAccent,
  );

  static const Icon forwardIcon = Icon(
    Icons.chevron_right,
  );

  static Widget getConfirmButton(
      {required String text, Function()? onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
            onPressed: onPressed,
            child: Text(
              text,
            )),
      ),
    );
  }
}
