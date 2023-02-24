import 'package:scorecard/models/cricket_match.dart';
import 'package:scorecard/models/team.dart';
import 'package:scorecard/util/utils.dart';

class Series {
  final String id;
  final List<Team> teams = [];
  final List<CricketMatch> matches = [];

  Series.create(
      {required List<Team> teams, required List<CricketMatch> matches})
      : id = Utils.generateUniqueId() {
    this.teams.addAll(teams);
    this.matches.addAll(matches);
  }

  Series(
      {required this.id,
      required List<Team> teams,
      required List<CricketMatch> matches}) {
    this.teams.addAll(teams);
    this.matches.addAll(matches);
  }
  // Series.empty();

  void addTeam(Team team) {
    teams.add(team);
  }

  void addMatch(CricketMatch match) {
    matches.add(match);
  }

  // int getWinsForTeam(Team team) {
  //   return matches
  //       .where((match) =>
  //           match.matchState == MatchState.completed &&
  //           match.result.winner == team)
  //       .length;
  // }
}
