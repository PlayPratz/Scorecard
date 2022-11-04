import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scorecard/models/ball.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/innings.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/models/wicket.dart';

const String _playerBoxName = "players";
const int _playerTypeId = 101;

const String _teamBoxName = "teams";
const int _teamTypeId = 102;

const String _matchBoxName = "matches"; //lmao "matchbox"
const int _matchTypeId = 103;

const int _inningsTypeId = 104;

const int _ballTypeId = 105;

const int _wicketTypeId = 106;

const int _tossTypeId = 107;

class StorageUtils {
  StorageUtils._();

  // Hive NoSQL DB
  static late final Box<Player> _playerBox;
  static late final Box<Team> _teamBox;
  static late final Box<CricketMatch> _matchBox; //lmao "matchbox"

  // AppData
  static late final Directory _appDataDirectory;

  static Future<void> init() async {
    // App Data directory
    _appDataDirectory = await getApplicationDocumentsDirectory();
    await Directory(pathPlayerPhotos).create(recursive: true);

    // Hive NoSQL DB
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(_PlayerAdapter());
    Hive.registerAdapter(_TeamAdapter());

    Hive.registerAdapter(_WicketAdapter());
    Hive.registerAdapter(_BallAdapter());
    Hive.registerAdapter(_InningsAdapter());
    Hive.registerAdapter(_TossAdapter());
    Hive.registerAdapter(_CricketMatchAdapter());

    // Open Boxes
    _playerBox = await Hive.openBox<Player>(_playerBoxName);
    _teamBox = await Hive.openBox<Team>(_teamBoxName);
    _matchBox = await Hive.openBox<CricketMatch>(_matchBoxName);
    _linkSuperOvers();
  }

  // Player

  static List<Player> getAllPlayers() {
    return _playerBox.values.toList();
  }

  static Player getPlayerById(String id) {
    Player? player = _playerBox.get(id);
    if (player == null) {
      throw UnimplementedError("An non-existent Player was accessed: " + id);
    }
    return player;
  }

  static void savePlayer(Player player) {
    _playerBox.put(player.id, player);
  }

  // static void deletePlayer(Player player) {
  //   _playerBox.delete(player.id);
  // }

  // Team

  static List<Team> getAllTeams() {
    return _teamBox.values.toList();
  }

  static Team getTeamById(String id) {
    Team? team = _teamBox.get(id);
    if (team == null) {
      throw UnimplementedError("A non-existent Team was accessed: " + id);
    }
    return team;
  }

  static void saveTeam(Team team) {
    _teamBox.put(team.id, team);
  }

  // static void deleteTeam(Team team) {
  //   _teamBox.delete(team);
  // }

  // Match
  static List<CricketMatch> getAllMatches() {
    return _matchBox.values
        .where((match) => !match.id.endsWith("_superover"))
        .toList();
  }

  static CricketMatch getMatchById(String id) {
    CricketMatch? match = _matchBox.get(id);
    if (match == null) {
      throw UnimplementedError("A non-existent Match was accessed: " + id);
    }
    return match;
  }

  static void saveMatch(CricketMatch match) {
    _matchBox.put(match.id, match);
  }

  // static void deleteMatch(Match match) {
  //   _teamBox.delete(team);
  // }

  static ImageProvider? getPlayerPhoto(Player player) {
    File photoFile = File(_getProfilePhotoPath(player.id));
    if (!photoFile.existsSync()) {
      return null;
    }
    return FileImage(photoFile);
  }

  static Future<void> savePlayerPhoto(
      String playerId, File profilePhoto) async {
    await profilePhoto.copy(_getProfilePhotoPath(playerId));
  }

  static void _linkSuperOvers() {
    for (CricketMatch match in _matchBox.values) {
      String superOverId = match.id + "_superover";
      if (_matchBox.containsKey(superOverId)) {
        match.superOver = getMatchById(superOverId);
        match.superOver!.parentMatch = match;
      }
    }
  }

  static String _getProfilePhotoPath(String playerId) =>
      pathPlayerPhotos + '/' + playerId;

  static String get pathPlayerPhotos =>
      _appDataDirectory.path + "/photos/players";
}

class _PlayerAdapter extends TypeAdapter<Player> {
  @override
  int get typeId => _playerTypeId;

  @override
  Player read(BinaryReader reader) {
    Player player = Player(
      id: reader.readString(),
      name: reader.readString(),
      batArm: Arm.values[reader.readInt()],
      bowlArm: Arm.values[reader.readInt()],
      bowlStyle: BowlStyle.values[reader.readInt()],
    );
    return player;
  }

  @override
  void write(BinaryWriter writer, Player player) {
    writer
      ..writeString(player.id)
      ..writeString(player.name)
      ..writeInt(player.batArm.index)
      ..writeInt(player.bowlArm.index)
      ..writeInt(player.bowlStyle.index);
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
    writer
      ..writeString(team.id)
      ..writeString(team.name)
      ..writeString(team.shortName)
      ..writeStringList(team.squad.map((player) => player.id).toList())
      ..writeInt(team.color.value);
  }
}

class _InningsAdapter extends TypeAdapter<Innings> {
  @override
  int get typeId => _inningsTypeId;

  @override
  Innings read(BinaryReader reader) {
    Innings innings = Innings(
        battingTeam: StorageUtils.getTeamById(reader.readString()),
        bowlingTeam: StorageUtils.getTeamById(reader.readString()),
        maxOvers: reader.readInt(),
        target: reader.readInt())
      ..isInPlay = reader.readBool()
      ..isAbandoned = reader.readBool();
    if (innings.target == -1) innings.target = null;
    List<dynamic> ballList = reader.readList();
    for (Ball ball in ballList) {
      innings.addBall(ball);
    }
    return innings;
  }

  @override
  void write(BinaryWriter writer, Innings innings) {
    writer
      ..writeString(innings.battingTeam.id)
      ..writeString(innings.bowlingTeam.id)
      ..writeInt(innings.maxOvers)
      ..writeInt(innings.target ?? -1)
      ..writeBool(innings.isInPlay)
      ..writeBool(innings.isAbandoned)
      ..writeList(innings.allBalls);
  }
}

class _WicketAdapter extends TypeAdapter<Wicket> {
  @override
  int get typeId => _wicketTypeId;

  @override
  Wicket read(BinaryReader reader) {
    Player batter = StorageUtils.getPlayerById(reader.readString());
    String id = reader.readString();
    Player? bowler = id == "" ? null : StorageUtils.getPlayerById(id);
    id = reader.readString();
    Player? fielder = id == "" ? null : StorageUtils.getPlayerById(id);
    Dismissal dismissal = Dismissal.values[reader.readInt()];
    return Wicket(
      batter: batter,
      bowler: bowler,
      fielder: fielder,
      dismissal: dismissal,
    );
  }

  @override
  void write(BinaryWriter writer, Wicket wicket) {
    writer
      ..writeString(wicket.batter.id)
      ..writeString(wicket.bowler?.id ?? "")
      ..writeString(wicket.fielder?.id ?? "")
      ..writeInt(wicket.dismissal.index);
  }
}

class _BallAdapter extends TypeAdapter<Ball> {
  @override
  int get typeId => _ballTypeId;

  @override
  Ball read(BinaryReader reader) {
    Ball ball = Ball(
      bowler: StorageUtils.getPlayerById(reader.readString()),
      batter: StorageUtils.getPlayerById(reader.readString()),
      runsScored: reader.readInt(),
    );
    int index = reader.readInt();
    if (index > -1) {
      ball.bowlingExtra = BowlingExtra.values[index];
    }
    index = reader.readInt();
    if (index > -1) {
      ball.battingExtra = BattingExtra.values[index];
    }
    ball.wicket = reader.read();
    return ball;
  }

  @override
  void write(BinaryWriter writer, Ball ball) {
    writer
      ..writeString(ball.bowler.id)
      ..writeString(ball.batter.id)
      ..writeInt(ball.runsScored)
      ..writeInt(ball.bowlingExtra?.index ?? -1)
      ..writeInt(ball.battingExtra?.index ?? -1)
      ..write(ball.wicket);
  }
}

class _TossAdapter extends TypeAdapter<Toss> {
  @override
  int get typeId => _tossTypeId;

  @override
  Toss read(BinaryReader reader) {
    return Toss(
      StorageUtils.getTeamById(reader.readString()),
      TossChoice.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, Toss toss) {
    writer
      ..writeString(toss.winningTeam.id)
      ..writeInt(toss.choice.index);
  }
}

class _CricketMatchAdapter extends TypeAdapter<CricketMatch> {
  @override
  int get typeId => _matchTypeId;

  @override
  CricketMatch read(BinaryReader reader) {
    CricketMatch match = CricketMatch.load(
      id: reader.readString(),
      maxOvers: reader.readInt(),
      homeInnings: reader.read(),
      awayInnings: reader.read(),
    );

    // Toss
    Toss? toss = reader.read();
    if (toss != null) {
      match.startMatch(toss);
    }

    return match;
  }

  @override
  void write(BinaryWriter writer, CricketMatch match) {
    writer
      ..writeString(match.id)
      ..writeInt(match.maxOvers)
      // Innings
      ..write(match.homeInnings)
      ..write(match.awayInnings)
      // Toss
      ..write(match.toss);
    // Super Overs are handled in _linkSuperOvers()
  }
}
