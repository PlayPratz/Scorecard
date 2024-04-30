class Player {
  final String id;
  String name;
  Arm batArm;
  Arm bowlArm;
  BowlStyle bowlStyle;

  // Player.create({
  //   required this.name,
  //   required this.batArm,
  //   required this.bowlArm,
  //   required this.bowlStyle,
  // }) : id = Utils.generateUniqueId();

  Player({
    required this.id,
    required this.name,
    required this.batArm,
    required this.bowlArm,
    required this.bowlStyle,
  });
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

class PlayerGroup {
  final String id;
  final String name;
  final int color;

  PlayerGroup({required this.id, required this.name, required this.color});
}
