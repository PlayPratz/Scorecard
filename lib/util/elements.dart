import 'package:flutter/material.dart';

import '../styles/colorstyles.dart';

class Elements {
  Elements._();

  static const Icon addIcon = Icon(
    Icons.add_circle,
    color: ColorStyles.currentlyBatting,
  );

  static const Icon removeIcon = Icon(
    Icons.remove_circle,
    color: ColorStyles.remove,
  );

  static const Icon forwardIcon = Icon(
    Icons.chevron_right,
  );

  static const Icon onlineIcon = Icon(
    Icons.fiber_manual_record,
    size: 12,
    color: ColorStyles.currentlyBatting,
  );

  static Widget getOnlineIndicator(bool isOnline) {
    return SizedBox(
      height: 18,
      width: 18,
      child: isOnline ? Elements.onlineIcon : null,
    );
  }

  static Widget getConfirmButton(
      {required String text, void Function()? onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }

  static Widget getTextInput(String label, String hint, String? initialValue,
      void Function(String value) onChangeValue) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, hintText: hint),
      initialValue: initialValue,
      onChanged: onChangeValue,
    );
  }

  static Widget noBallIndicator = Icon(
    Icons.fiber_manual_record,
    size: 12,
    color: ColorStyles.ballNoBall,
  );

  static Widget wideBallIndicator = Icon(
    Icons.fiber_manual_record,
    size: 12,
    color: ColorStyles.ballWide,
  );

  static const Widget blankIndicator = Icon(
    Icons.fiber_manual_record,
    size: 12,
    color: Colors.transparent,
  );
}
