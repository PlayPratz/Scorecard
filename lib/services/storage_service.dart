import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/player.dart';
import 'package:scorecard/models/series.dart';
import 'package:scorecard/models/team.dart';

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

const int _seriesTypeId = 108;
const String _seriesBoxName = "series";

class HiveStorageService {
  // HiveStorageService._();

  // Hive NoSQL DB
  late final Box<Player> _playerBox;
  late final Box<Team> _teamBox;
  late final Box<CricketMatch> _matchBox; //lmao "matchbox"
  late final Box<Series> _seriesBox;

  // AppData
  late final Directory _appDataDirectory;

  Future<void> init() async {
    // App Data directory
    // _appDataDirectory = await getApplicationDocumentsDirectory();
    // await Directory(pathPlayerPhotos).create(recursive: true);

    // Hive NoSQL DB
    await Hive.initFlutter();

    // Hive.deleteBoxFromDisk(_matchBoxName); // TODO Remove before commit

    // Register Adapters
    Hive.registerAdapter(_PlayerAdapter());
    Hive.registerAdapter(_TeamAdapter());

    // Hive.registerAdapter(_WicketAdapter());
    // Hive.registerAdapter(_BallAdapter());
    // Hive.registerAdapter(_InningsAdapter());
    // Hive.registerAdapter(_TossAdapter());
    // Hive.registerAdapter(_CricketMatchAdapter());
    // Hive.registerAdapter(_SeriesAdapter());

    // Open Boxes
    _playerBox = await Hive.openBox<Player>(_playerBoxName);
    _teamBox = await Hive.openBox<Team>(_teamBoxName);

    // _matchBox = await Hive.openBox<CricketMatch>(_matchBoxName);
    // _linkSuperOvers();
    // _seriesBox = await Hive.openBox<Series>(_seriesBoxName);
  }

  // Player

  List<Player> getAllPlayers() {
    return _playerBox.values.toList();
  }

  Player getPlayerById(String id) {
    Player? player = _playerBox.get(id);
    if (player == null) {
      throw UnimplementedError("A non-existent Player [$id] was accessed.");
    }
    return player;
  }

  void savePlayer(Player player) {
    _playerBox.put(player.id, player);
  }

  // static void deletePlayer(Player player) {
  //   _playerBox.delete(player.id);
  // }

  ImageProvider? getPlayerPhoto(Player player) {
    File photoFile = File(_getProfilePhotoPath(player.id));
    if (!photoFile.existsSync()) {
      return null;
    }
    return FileImage(photoFile);
  }

  Future<void> savePlayerPhoto(String playerId, File profilePhoto) async {
    await profilePhoto.copy(_getProfilePhotoPath(playerId));
  }

  // Team

  List<Team> getAllTeams() {
    return _teamBox.values.toList();
  }

  Team getTeamById(String id) {
    Team? team = _teamBox.get(id);
    if (team == null) {
      throw UnimplementedError("A non-existent Team [$id] was accessed.");
    }
    return team;
  }

  void saveTeam(Team team) {
    _teamBox.put(team.id, team);
  }

  // static void deleteTeam(Team team) {
  //   _teamBox.delete(team);
  // }

  // Match
  List<CricketMatch> getAllMatches() {
    return _matchBox.values
        .where((match) => !match.id.endsWith("_superover"))
        .toList();
  }

  List<CricketMatch> getOngoingMatches() {
    return _matchBox.values
        .where((match) =>
            !match.id.endsWith("_superover") &&
            match.matchState != MatchState.completed)
        .toList();
  }

  List<CricketMatch> getCompletedMatches() {
    return _matchBox.values
        .where((match) =>
            !match.id.endsWith("_superover") &&
            match.matchState == MatchState.completed)
        .toList();
  }

  CricketMatch getMatchById(String id) {
    CricketMatch? match = _matchBox.get(id);
    if (match == null) {
      throw UnimplementedError("A non-existent Match was accessed: " + id);
    }
    return match;
  }

  void saveMatch(CricketMatch match) {
    _matchBox.put(match.id, match);
  }

  void deleteMatch(CricketMatch match) {
    _matchBox.delete(match.id);
  }

  // Series
  List<Series> getAllSeries() {
    return _seriesBox.values.toList();
  }

  void saveSeries(Series series) {
    _seriesBox.put(series.id, series);
  }

  // Misc

  void _linkSuperOvers() {
    for (CricketMatch match in _matchBox.values) {
      String superOverId = match.id + "_superover";
      if (_matchBox.containsKey(superOverId)) {
        match.superOver = getMatchById(superOverId);
        match.superOver!.parentMatch = match;
      }
    }
  }

  String _getProfilePhotoPath(String playerId) =>
      pathPlayerPhotos + '/' + playerId;

  String get pathPlayerPhotos => _appDataDirectory.path + "/photos/players";
}

// class StorageServiceDummy implements StorageService {
final StorageService = StorageServiceDummy();

class StorageServiceDummy {
  final matches = <String, CricketMatch>{};
  final players = <String, Player>{};
  final teams = <String, Team>{};
  final series = <String, Series>{};

  late final HiveStorageService hive;

  Future<void> init() async {
    hive = HiveStorageService();
    await hive.init();
  }

  void deleteMatch(CricketMatch match) {
    matches.remove(match.id);
  }

  List<CricketMatch> getAllMatches() {
    return matches.values.toList();
  }

  List<Player> getAllPlayers({bool sortAlphabetically = true}) {
    // final playerList = players.values.toList();
    final playerList = hive.getAllPlayers();
    if (sortAlphabetically) {
      playerList.sort((a, b) => a.name.compareTo(b.name));
    }
    return playerList;
  }

  List<Series> getAllSeries() {
    return series.values.toList();
  }

  List<Team> getAllTeams() {
    return teams.values.toList();
  }

  List<CricketMatch> getCompletedMatches() {
    return matches.values
        .where((match) => match.matchState == MatchState.completed)
        .toList();
  }

  CricketMatch getMatchById(String id) {
    return matches[id]!;
  }

  List<CricketMatch> getOngoingMatches() {
    return matches.values
        .where((match) => match.matchState != MatchState.completed)
        .toList();
  }

  Player getPlayerById(String id) {
    return hive.getPlayerById(id);
    // return players[id]!;
  }

  ImageProvider<Object>? getPlayerPhoto(Player player) {
    return null;
  }

  Team getTeamById(String id) {
    return hive.getTeamById(id);
    // return teams[id]!;
  }

  // TODO: implement pathPlayerPhotos
  String get pathPlayerPhotos => throw UnimplementedError();

  void saveMatch(CricketMatch match) {
    matches[match.id] = match;
  }

  void savePlayer(Player player) {
    // players[player.id] = player;
    hive.savePlayer(player);
  }

  Future<void> savePlayerPhoto(String playerId, File profilePhoto) async {}

  void saveSeries(Series series) {
    this.series[series.id] = series;
  }

  void saveTeam(Team team) {
    // teams[team.id] = team;
    hive.saveTeam(team);
  }
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
          .map((playerId) => StorageService.getPlayerById(playerId))
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
//
// class _InningsAdapter extends TypeAdapter<Innings> {
//   @override
//   int get typeId => _inningsTypeId;
//   // TODO REDO with Map
//
//   @override
//   Innings read(BinaryReader reader) {
//     Innings innings = Innings(
//         battingTeam: StorageService.getTeamById(reader.readString()),
//         bowlingTeam: StorageService.getTeamById(reader.readString()),
//         maxOvers: reader.readInt());
//     List ballList = reader.readList();
//     // final inningsstateController = InningsstateController(innings);
//     for (Ball ball in ballList) {
//       // inningsstateController.loadBallIntoInnings(ball);
//     }
//     final target = reader.readInt();
//     if (target > -1) {
//       innings.target = target;
//     }
//     return innings;
//   }
//
//   @override
//   void write(BinaryWriter writer, Innings innings) {
//     writer
//       ..writeString(innings.battingTeam.id)
//       ..writeString(innings.bowlingTeam.id)
//       ..writeInt(innings.maxOvers)
//       ..writeList(innings.balls)
//       ..writeInt(innings.target ?? -1);
//   }
// }
//
// class _WicketAdapter extends TypeAdapter<Wicket> {
//   @override
//   int get typeId => _wicketTypeId;
//
//   @override
//   Wicket read(BinaryReader reader) {
//     Player batter = StorageService.getPlayerById(reader.readString());
//     String id = reader.readString();
//     Player? bowler = id == "" ? null : StorageService.getPlayerById(id);
//     id = reader.readString();
//     Player? fielder = id == "" ? null : StorageService.getPlayerById(id);
//     Dismissal dismissal = Dismissal.values[reader.readInt()];
//     return Wicket(
//       batter: batter,
//       bowler: bowler,
//       fielder: fielder,
//       dismissal: dismissal,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Wicket wicket) {
//     writer
//       ..writeString(wicket.batter.id)
//       ..writeString(wicket.bowler?.id ?? "")
//       ..writeString(wicket.fielder?.id ?? "")
//       ..writeInt(wicket.dismissal.index);
//   }
// }
//
// class _BallAdapter extends TypeAdapter<Ball> {
//   @override
//   int get typeId => _ballTypeId;
//
//   @override
//   Ball read(BinaryReader reader) {
//     Ball ball = Ball(
//       bowler: StorageService.getPlayerById(reader.readString()),
//       batter: StorageService.getPlayerById(reader.readString()),
//       runsScored: reader.readInt(),
//     );
//     int index = reader.readInt();
//     if (index > -1) {
//       // ball.bowlingExtra = BowlingExtra.values[index]; TODO
//     }
//     index = reader.readInt();
//     if (index > -1) {
//       // ball.battingExtra = BattingExtra.values[index]; TODO
//     }
//     // ball.wicket = reader.read(); TODO
//     return ball;
//   }
//
//   @override
//   void write(BinaryWriter writer, Ball ball) {
//     writer
//       ..writeString(ball.bowler.id)
//       ..writeString(ball.batter.id)
//       ..writeInt(ball.runsScored)
//       ..writeInt(ball.bowlingExtra?.index ?? -1)
//       ..writeInt(ball.battingExtra?.index ?? -1)
//       ..write(ball.wicket);
//   }
// }
//
// class _TossAdapter extends TypeAdapter<Toss> {
//   @override
//   int get typeId => _tossTypeId;
//
//   @override
//   Toss read(BinaryReader reader) {
//     return Toss(
//       StorageService.getTeamById(reader.readString()),
//       TossChoice.values[reader.readInt()],
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Toss toss) {
//     writer
//       ..writeString(toss.winningTeam.id)
//       ..writeInt(toss.choice.index);
//   }
// }
//
// class _CricketMatchAdapter extends TypeAdapter<CricketMatch> {
//   @override
//   int get typeId => _matchTypeId;
//
//   @override
//   CricketMatch read(BinaryReader reader) {
//     CricketMatch match = CricketMatch.load(
//       id: reader.readString(),
//       maxOvers: reader.readInt(),
//       homeTeam: StorageService.getTeamById(reader.readString()),
//       awayTeam: StorageService.getTeamById(reader.readString()),
//       inningsList: reader.readList().cast(),
//     );
//
//     // Toss
//     Toss? toss = reader.read();
//     if (toss != null) {
//       match.toss = toss;
//     }
//
//     return match;
//   }
//
//   @override
//   void write(BinaryWriter writer, CricketMatch match) {
//     writer
//       ..writeString(match.id)
//       ..writeInt(match.maxOvers)
//       // Teams
//       ..writeString(match.homeTeam.id)
//       ..writeString(match.awayTeam.id)
//       //Innings
//       ..writeList(match.inningsList)
//       // Toss
//       ..write(match.toss);
//     // Super Overs are handled in _linkSuperOvers()
//   }
// }
//
// class _SeriesAdapter extends TypeAdapter<Series> {
//   @override
//   int get typeId => _seriesTypeId;
//
//   @override
//   Series read(BinaryReader reader) {
//     return Series(
//       id: reader.readString(),
//       teams: reader
//           .readStringList()
//           .map((id) => StorageService.getTeamById(id))
//           .toList(),
//       matches: reader
//           .readStringList()
//           .map((id) => StorageService.getMatchById(id))
//           .toList(),
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Series series) {
//     writer
//       ..writeString(series.id)
//       ..writeStringList(series.teams.map((team) => team.id).toList())
//       ..writeStringList(series.matches.map((match) => match.id).toList());
//   }
// }
