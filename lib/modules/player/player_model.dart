/// Represents a Player that bats, bowls or fields in a match.
class Player {
  /// The ID of this player as in the database
  final int? id;

  /// The globally unique key of a player
  /// ex: #01KC1WCW1W6RZ00D3M7KBREYC9 ('#' is not a part of the handle)
  final String handle;

  /// The name of this player as on the scorecard
  final String name;

  /// The full name of this player
  final String? fullName;

  Player({
    this.id,
    required this.handle,
    required this.name,
    this.fullName,
  });
}
