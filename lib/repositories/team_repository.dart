import 'package:hive_flutter/adapters.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/repositories/generic_repository.dart';
import 'package:scorecard/repositories/hive_constants.dart';

class TeamRepository implements IRepository<Team> {
  late final Box<TeamDTO> _teamBox;

  final Map<String, Team> _cache = {};

  @override
  Future<void> initialize() async {
    // Register the TypeAdapter
    Hive.registerAdapter(_TeamAdapter());

    // Open the Hive Box
    _teamBox = await Hive.openBox(teamBoxName);
  }

  @override
  Future<void> add(Team team) async {
    final teamDTO = TeamDTO.of(team);
    await _teamBox.put(teamDTO.id, teamDTO);
    _cache[team.id] = team;
  }

  @override
  Future<Team> get(String id) async {
    if (_cache.containsKey(id)) {
      return _cache[id]!;
    }

    final teamDTO = _teamBox.get(id);
    if (teamDTO == null) {
      throw StateError("Team not found in the Database! (id: $id)");
    }
    final team = teamDTO.toTeam();

    _cache[id] = team;

    return team;
  }

  @override
  Future<List<Team>> getAll() async {
    final teamDTOs = _teamBox.values;
    final teams = [for (final teamDTO in teamDTOs) teamDTO.toTeam()];
    return teams;
  }

  @override
  Future<void> update(Team team) async {
    // Ensure that a team of the same ID exists in the database.
    // This is just to ensure that update() is called intentionally.
    // If a new player is to be added, add() should be called instead.
    if (!_teamBox.containsKey(team.id)) {
      throw StateError("Team not found in the Database! (id: ${team.id})");
    }
    // Since the ID is not generated by the database, adding is essentially the
    // same as updating.
    await add(team);
  }

  @override
  Future<void> delete(String id) async {
    await _teamBox.delete(id);
  }
}

/// Represents a [Team] as it is stored in the database.
class TeamDTO {
  final String id;
  final String name;
  final String shortName;
  final int color;

  TeamDTO._({
    required this.id,
    required this.name,
    required this.shortName,
    required this.color,
  });

  Team toTeam() => Team(
        id: id,
        name: name,
        shortName: shortName,
        color: color,
      );

  factory TeamDTO.of(Team team) => TeamDTO._(
        id: team.id,
        name: team.name,
        shortName: team.shortName,
        color: team.color,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "shortName": shortName,
        "color": color,
      };

  factory TeamDTO.fromMap(Map<String, dynamic> map) => TeamDTO._(
        id: map["id"],
        name: map["name"],
        shortName: map["shortName"],
        color: map["color"],
      );
}

class _TeamAdapter extends TypeAdapter<TeamDTO> {
  @override
  int get typeId => teamTypeId;

  @override
  TeamDTO read(BinaryReader reader) => TeamDTO.fromMap(reader.readMap().cast());

  @override
  void write(BinaryWriter writer, TeamDTO obj) {
    writer.writeMap(obj.toMap());
  }
}
