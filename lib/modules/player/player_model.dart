/// Represents a Player that bats, bowls or fields in a match.
class Player {
  /// The ID of this player as in the database
  final String id;

  /// The name of this player
  final String name;

  Player(this.id, {required this.name});
}
