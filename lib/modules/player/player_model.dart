class Player {
  final String id;
  final String name;
  // final Gender gender;

  const Player({
    required this.id,
    required this.name,
    // required this.gender,
  });
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
