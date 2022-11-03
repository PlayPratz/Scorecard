import 'package:flutter/material.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/util/storage_util.dart';

import '../styles/color_styles.dart';

class Elements {
  Elements._();

  static const Icon addIcon = Icon(
    Icons.add_circle,
    color: ColorStyles.online,
  );

  static const Icon removeIcon = Icon(
    Icons.remove_circle,
    color: ColorStyles.remove,
  );

  static const Icon forwardIcon = Icon(
    Icons.chevron_right,
  );

  static const Icon onlineIcon = Icon(
    Icons.play_arrow,
    size: 16,
    color: ColorStyles.online,
  );

  static Widget getOnlineIndicator(bool isOnline) {
    return SizedBox(
      height: 8,
      width: 8,
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

  static Widget getTextInput(
      String label, String hint, void Function(String value) onChangeValue,
      [String? initialValue, TextInputType? textInputType]) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, hintText: hint),
      initialValue: initialValue,
      onChanged: onChangeValue,
      keyboardType: textInputType,
    );
  }

  static Widget getPlayerIcon(Player player, double size) {
    ImageProvider? _profilePhoto = StorageUtils.getPlayerPhoto(player);

    return SizedBox(
      width: size,
      height: size,
      child: _profilePhoto != null
          ? FittedBox(
              fit: BoxFit.none,
              child: CircleAvatar(
                foregroundImage: _profilePhoto,
                radius: size / 2,
              ),
            )
          : Icon(
              Icons.person_outline,
              size: size / 2,
            ),
    );
  }

  static const Widget noBallIndicator = Icon(
    Icons.fiber_manual_record,
    size: 12,
    color: ColorStyles.ballNoBall,
  );

  static const Widget wideBallIndicator = Icon(
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
