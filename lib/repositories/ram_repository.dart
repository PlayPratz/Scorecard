import 'package:scorecard/modules/cricket_match/models/cricket_match_model.dart';
import 'package:scorecard/modules/player/player_model.dart';
import 'package:scorecard/modules/team/models/team_model.dart';
import 'package:scorecard/repositories/generic_repository.dart';

class RAMPlayerRepository implements IRepository<Player> {
  final _database = <String, Player>{
    "2cool4school": const Player(id: "2cool4school", name: "Pratik Nerurkar"),
    "3cool4school": const Player(id: "3cool4school", name: "Rutash Joshipura"),
  };

  @override
  Future<void> create(Player player) async {
    if (_database.containsKey(player.id)) {
      throw StateError(
          "Attempted to create a player that already exists! ID: ${player.id}");
    }
    _database[player.id] = player;
  }

  @override
  Future<Player?> read(String id) async {
    return _database[id];
  }

  @override
  Future<Iterable<Player>> readAll() async {
    return _database.values;
  }

  @override
  Future<Iterable<Player>> search(String query) async {
    final players = await readAll();
    return players.where(
        (player) => player.name.toLowerCase().contains(query.toLowerCase()));
  }

  @override
  Future<void> update(Player player) async {
    if (!_database.containsKey(player.id)) {
      throw StateError(
          "Attempted to update a player that does not exist! ID: ${player.id}");
    }
    _database[player.id] = player;
  }

  @override
  Future<void> delete(String id) async {
    if (!_database.containsKey(id)) {
      throw StateError(
          "Attempted to delete a player that does not exist! ID: $id");
    }
    _database.remove(id);
  }
}

class RAMTeamRepository implements IRepository<Team> {
  final _database = <String, Team>{};

  @override
  Future<void> create(Team team) async {
    if (_database.containsKey(team.id)) {
      throw StateError(
          "Attempted to create a team that already exists! ID: ${team.id}");
    }
    _database[team.id] = team;
  }

  @override
  Future<Team?> read(String id) async {
    return _database[id];
  }

  @override
  Future<Iterable<Team>> readAll() async {
    return _database.values;
  }

  @override
  Future<Iterable<Team>> search(String query) async {
    final teams = await readAll();
    return teams.where((team) => team.name.toLowerCase().contains(query));
  }

  @override
  Future<void> update(Team team) async {
    if (!_database.containsKey(team.id)) {
      throw StateError(
          "Attempted to update a team that does not exist! ID: ${team.id}");
    }
    _database[team.id] = team;
  }

  @override
  Future<void> delete(String id) async {
    if (!_database.containsKey(id)) {
      throw StateError(
          "Attempted to delete a team that does not exist! ID: $id");
    }
    _database.remove(id);
  }
}

class RAMCricketMatchRepository implements IRepository<CricketMatch> {
  final _database = <String, CricketMatch>{};

  @override
  Future<void> create(CricketMatch match) async {
    if (_database.containsKey(match.id)) {
      throw StateError(
          "Attempted to create a cricket match that already exists! ID: ${match.id}");
    }
    _database[match.id] = match;
  }

  @override
  Future<CricketMatch?> read(String id) async {
    return _database[id];
  }

  @override
  Future<Iterable<CricketMatch>> readAll() async {
    return _database.values;
  }

  @override
  Future<Iterable<CricketMatch>> search(String query) async {
    final matches = await readAll();
    return matches.where((match) {
      if (match is ScheduledCricketMatch) {
        if (match.team1.name.toLowerCase().contains(query) ||
            match.team2.name.toLowerCase().contains(query)) {
          return true;
        }
      }
      return false;
    });
  }

  @override
  Future<void> update(CricketMatch match) async {
    if (!_database.containsKey(match.id)) {
      throw StateError(
          "Attempted to update a cricket match that does not exist! ID: ${match.id}");
    }
    _database[match.id] = match;
  }

  @override
  Future<void> delete(String id) async {
    if (!_database.containsKey(id)) {
      throw StateError(
          "Attempted to delete a cricket match that does not exist! ID: $id");
    }
    _database.remove(id);
  }
}
