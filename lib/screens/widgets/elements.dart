import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/services/player_service.dart';
import 'package:scorecard/styles/color_styles.dart';

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

  static const Icon teamIcon = Icon(Icons.groups);

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
        child: getButton(text: text, onPressed: onPressed),
      ),
    );
  }

  static Widget getButton({
    required String text,
    void Function()? onPressed,
    Color? foreground,
    Color? background,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: background?.withOpacity(0.1),
        foregroundColor: foreground,
      ),
      onPressed: onPressed,
      child: Text(
        text,
      ),
    );
  }

  static Widget getTextInput(
      String label, String hint, void Function(String value) onChangeValue,
      [String? initialValue,
      TextInputType? textInputType,
      TextCapitalization? textCapitalization]) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, hintText: hint),
      initialValue: initialValue,
      onChanged: onChangeValue,
      keyboardType: textInputType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
    );
  }

  static Widget getPlayerIcon(
      BuildContext context, Player player, double size) {
    // Attempt to get from cache
    final photoFile = context.read<PlayerService>().getPhotoFromCache(player);
    if (photoFile != null) {
      return CircleAvatar(
        backgroundColor: ColorStyles.card,
        // foregroundColor: Colors.white,
        radius: (size / 2),
        child: FittedBox(
          fit: BoxFit.contain,
          child: CircleAvatar(
            foregroundImage: FileImage(photoFile),
            backgroundColor: Colors.transparent,
            radius: size / 2 - 1,
          ),
        ),
      );
    }

    final playerPhotoFileFuture =
        context.read<PlayerService>().getPhotoFromStorage(player);

    final colorIndex =
        (player.name.codeUnits.fold(0, (sum, element) => element + sum)) %
            ColorStyles.teamColors.length;

    return CircleAvatar(
      backgroundColor: ColorStyles.teamColors[colorIndex],
      // foregroundColor: Colors.white,
      radius: (size / 2),
      child: FutureBuilder(
          future: playerPhotoFileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return FittedBox(
                fit: BoxFit.contain,
                child: CircleAvatar(
                  foregroundImage: FileImage(snapshot.data!),
                  backgroundColor: Colors.transparent,
                  radius: size / 2 - 1,
                ),
              );
            }
            return Icon(
              Icons.person_outline,
              size: size / 2,
              color: Colors.white,
            );
          }),
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

  static void showSnackBar(BuildContext context, {required String text}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Colors.white)),
        backgroundColor: ColorStyles.card,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
