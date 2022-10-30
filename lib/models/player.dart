class Player {
  int id;
  String name;
  String? imagePath;

  Arm batArm;
  Arm? bowlArm;
  BowlStyle? bowlStyle;

  Player(
      {required this.id,
      required this.name,
      required this.batArm,
      this.bowlArm,
      this.bowlStyle});

  Player.withPhoto(
      {required this.id,
      required this.name,
      required this.batArm,
      this.bowlArm,
      this.bowlStyle,
      this.imagePath});
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
