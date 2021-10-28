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
}
