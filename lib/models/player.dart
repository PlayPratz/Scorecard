import '../util/utils.dart';

class Player {
  final String id;
  String name;
  String? imagePath;

  Arm batArm;
  Arm bowlArm;
  BowlStyle bowlStyle;

  Player.create(
      {required this.name,
      required this.batArm,
      required this.bowlArm,
      required this.bowlStyle,
      this.imagePath})
      : id = Utils.generateUniqueId();

  Player(
      {required this.id,
      required this.name,
      required this.batArm,
      required this.bowlArm,
      required this.bowlStyle,
      this.imagePath});

  bool get hasProfilePhoto => imagePath != null;
}

enum Arm {
  left,
  right,
}

enum BowlStyle {
  spin,
  medium,
  fast,
}
