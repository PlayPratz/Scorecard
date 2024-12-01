class Player {
  final String id;
  final String name;
  final String? fullName;
  // final Gender gender;

  const Player({
    required this.id,
    required this.name,
    this.fullName,
    // required this.gender,
  });

  @override
  bool operator ==(Object other) {
    if (other is Player &&
        other.id == id &&
        other.name == name &&
        other.fullName == fullName) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;
}
//
// class Player extends PlayerDraft {
//   final int id;
//
//   Player({required this.id, required super.name});
//
//   Player.fromDraft(PlayerDraft draft, int id) : this(id: id, name: draft.name);
// }

enum Gender { female, male }
