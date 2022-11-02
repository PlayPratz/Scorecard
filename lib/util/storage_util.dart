import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';

const String _playerBoxName = "players";
const int _playerTypeId = 101;

const String _teamBoxName = "teams";
const int _teamTypeId = 102;

const String _matchBoxName = "matches"; //lmao "matchbox"
const int _matchTypeId = 103;

const String _inningsBoxName = "innings";
const int _inningsTypeId = 104;

class StorageUtils {
  StorageUtils._();

  static late Box<Player> _playerBox;
  static late Box<Team> _teamBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    // Register Adapters
    Hive.registerAdapter(_PlayerAdapter());
    Hive.registerAdapter(_TeamAdapter());
    Hive.registerAdapter(_InningsAdapter());
    Hive.registerAdapter(_CricketMatchAdapter());

    // Open Boxes
    _playerBox = await Hive.openBox<Player>(_playerBoxName);
    _teamBox = await Hive.openBox<Team>(_teamBoxName);
  }

  // Player

  static List<Player> getAllPlayers() {
    return _playerBox.values.toList();
  }

  static Player getPlayerById(String id) {
    Player? player = _playerBox.get(id);
    if (player == null) {
      throw UnimplementedError("An non-existent Player was accessed");
    }
    return player;
  }

  static void savePlayer(Player player) {
    _playerBox.put(player.id, player);
  }

  static void deletePlayer(Player player) {
    _playerBox.delete(player.id);
  }

  // Team

  static List<Team> getAllTeams() {
    return _teamBox.values.toList();
  }

  static Team getTeamById(String id) {
    Team? team = _teamBox.get(id);
    if (team == null) {
      throw UnimplementedError("A non-existent Team was accessed");
    }
    return team;
  }

  static void saveTeam(Team team) {
    _teamBox.put(team.id, team);
  }

  static void deleteTeam(Team team) {
    _teamBox.delete(team);
  }
}

class _PlayerAdapter extends TypeAdapter<Player> {
  @override
  int get typeId => _playerTypeId;

  @override
  Player read(BinaryReader reader) {
    return Player(
      id: reader.readString(),
      name: reader.readString(),
      batArm: Arm.values[reader.readInt()],
      bowlArm: Arm.values[reader.readInt()],
      bowlStyle: BowlStyle.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, Player player) {
    writer.writeString(player.id);
    writer.writeString(player.name);
    writer.writeInt(player.batArm.index);
    writer.writeInt(player.bowlArm.index);
    writer.writeInt(player.bowlStyle.index);
  }
}

class _TeamAdapter extends TypeAdapter<Team> {
  @override
  int get typeId => _teamTypeId;

  @override
  Team read(BinaryReader reader) {
    return Team(
      id: reader.readString(),
      name: reader.readString(),
      shortName: reader.readString(),
      squad: reader
          .readStringList()
          .map((playerId) => StorageUtils.getPlayerById(playerId))
          .toList(),
      color: Color(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, Team team) {
    writer.writeString(team.id);
    writer.writeString(team.name);
    writer.writeString(team.shortName);
    writer.writeStringList(team.squad.map((player) => player.id).toList());
    writer.writeInt(team.color.value);
  }
}

class _InningsAdapter extends TypeAdapter<Innings> {
  @override
  int get typeId => _inningsTypeId;

  @override
  Innings read(BinaryReader reader) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  void write(BinaryWriter writer, Innings innings) {
    // TODO: implement write
  }
}

class _CricketMatchAdapter extends TypeAdapter<CricketMatch> {
  @override
  int get typeId => _matchTypeId;

  @override
  CricketMatch read(BinaryReader reader) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  void write(BinaryWriter writer, CricketMatch obj) {
    // TODO: implement write
  }
}
