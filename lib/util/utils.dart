import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/cricketmatch.dart';
import '../models/player.dart';
import '../models/team.dart';

class Utils {
  Utils._(); // Private constructor

  static const _uuid = Uuid();

  static String generateUniqueId() => _uuid.v1();

  static Future<dynamic> goToPage(Widget page, BuildContext context) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static Future<dynamic> goToReplacementPage(
      Widget page, BuildContext context) {
    return Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static void goBack(BuildContext context, [result]) {
    Navigator.pop(context, result);
  }

  static List<Player> getAllPlayers() {
    return [..._playerList];
  }

  static void savePlayer(Player player) {
    if (!_playerList.contains(player)) _playerList.add(player);
  }

  static List<Team> getAllTeams() {
    return [..._teamList];
  }

  static void saveTeam(Team team) {
    if (!_teamList.contains(team)) _teamList.add(team);
  }

  static List<CricketMatch> getAllMatches() {
    return [..._matchList];
  }

  static void saveMatch(CricketMatch match) {
    // Check whether match exists in storage
    // If yes, update
    // Else, add to list
    _matchList.remove(match);
    _matchList.insert(0, match);
  }
}

final List<Player> _playerList = [
  Player(
    id: '1',
    name: "Pratik",
    imagePath: "assets/images/pratik.png",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player(
    id: '2',
    name: "Chaitanya",
    imagePath: "assets/images/chaitanya.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player(
    id: '3',
    name: "Rutash",
    imagePath: "assets/images/rutash.png",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.fast,
  ),
  Player(
    id: '4',
    name: "Calden",
    imagePath: "assets/images/calden.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player(
    id: '5',
    name: "Noah",
    imagePath: "assets/images/noah.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player(
    id: '6',
    name: "Roshan",
    imagePath: "assets/images/roshan.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player(
    id: '7',
    name: "Kyle",
    imagePath: "assets/images/kyle.jpg",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player(
    id: '8',
    name: "Darren",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
  Player(
    id: '9',
    name: "arjun",
    batArm: Arm.right,
    bowlArm: Arm.right,
    bowlStyle: BowlStyle.spin,
  ),
];

final List<Team> _teamList = [];

final List<CricketMatch> _matchList = [];
